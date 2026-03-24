{
  description = "TODO: Your module description — Logos UI plugin";

  inputs = {
    logos-module-builder.url = "github:logos-co/logos-module-builder";
    nixpkgs.follows = "logos-module-builder/nixpkgs";
    logos-cpp-sdk = {
      url = "github:logos-co/logos-cpp-sdk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    logos-liblogos = {
      url = "github:logos-co/logos-liblogos";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.logos-cpp-sdk.follows = "logos-cpp-sdk";
    };
    nix-bundle-lgx = {
      url = "github:AstraProtocol/nix-bundle-lgx";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, logos-module-builder, nixpkgs, logos-cpp-sdk, logos-liblogos, nix-bundle-lgx, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f {
        pkgs = import nixpkgs { inherit system; };
        logosSdk = logos-cpp-sdk.packages.${system}.default;
        logosLiblogos = logos-liblogos.packages.${system}.default;
        lgx = nix-bundle-lgx.packages.${system}.default;
      });
    in
    {
      packages = forAllSystems ({ pkgs, logosSdk, logosLiblogos, lgx }:
        let
          ext = pkgs.stdenv.hostPlatform.extensions.sharedLibrary;
          kernel = pkgs.stdenv.hostPlatform.parsed.kernel.name;
          cpu = pkgs.stdenv.hostPlatform.parsed.cpu.name;
          variant = "${kernel}-${cpu}";
          variantDev = "${variant}-dev";

          # ── Core module (headless logoscore plugin) ──────────────────────────
          core-module = pkgs.stdenv.mkDerivation {
            pname = "your-module-plugin";
            version = "0.1.0";
            src = ./.;

            nativeBuildInputs = [
              pkgs.cmake
              pkgs.ninja
              pkgs.pkg-config
              pkgs.qt6.wrapQtAppsHook
            ];

            buildInputs = [
              pkgs.qt6.qtbase
              pkgs.qt6.qtdeclarative
              pkgs.qt6.qtremoteobjects
            ];

            cmakeFlags = [
              "-DBUILD_MODULE=ON"
              "-DLOGOS_CPP_SDK_ROOT=${logosSdk}"
              "-DLOGOS_LIBLOGOS_ROOT=${logosLiblogos}"
            ];

            buildPhase = ''
              runHook preBuild
              cmake --build . --target your_module_plugin -j''${NIX_BUILD_CORES:-1}
              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              mkdir -p $out/lib
              cp your_module_plugin${ext} $out/lib/
              runHook postInstall
            '';

            dontWrapQtApps = true;

            meta = with pkgs.lib; {
              description = "YourModule headless logoscore plugin";
              platforms = platforms.unix;
            };
          };

          # ── UI plugin (IComponent for logos-app) ─────────────────────────────
          ui-plugin = pkgs.stdenv.mkDerivation {
            pname = "your-ui-plugin";
            version = "0.1.0";
            src = ./.;

            nativeBuildInputs = [
              pkgs.cmake
              pkgs.ninja
              pkgs.pkg-config
              pkgs.qt6.wrapQtAppsHook
            ];

            buildInputs = [
              pkgs.qt6.qtbase
              pkgs.qt6.qtdeclarative
              pkgs.qt6.qtremoteobjects
            ];

            cmakeFlags = [
              "-DBUILD_UI_PLUGIN=ON"
              "-DLOGOS_CPP_SDK_ROOT=${logosSdk}"
              "-DLOGOS_LIBLOGOS_ROOT=${logosLiblogos}"
            ];

            buildPhase = ''
              runHook preBuild
              cmake --build . --target your_ui -j''${NIX_BUILD_CORES:-1}
              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              mkdir -p $out/lib
              cp libyour_ui${ext} $out/lib/
              runHook postInstall
            '';

            dontWrapQtApps = true;

            meta = with pkgs.lib; {
              description = "YourModule UI plugin (IComponent) for logos-app";
              platforms = platforms.unix;
            };
          };

          # ── patchManifest: strip -dev suffix from main keys ──────────────────
          patchManifest = src: pkgs.runCommand "patched-manifest" {
            nativeBuildInputs = [ pkgs.jq ];
          } ''
            jq '.main |= with_entries(.key |= rtrimstr("-dev"))' ${src} > $out
          '';

          # ── lgx packages (one per type: core modules vs UI plugins) ──────────
          lgx-core = pkgs.runCommand "your-module-lgx-core" {
            nativeBuildInputs = [ lgx ];
          } ''
            mkdir -p staging/${variantDev}
            cp ${core-module}/lib/your_module_plugin${ext} staging/${variantDev}/
            cp ${patchManifest ./manifest.json} staging/manifest.json
            mkdir -p $out
            lgx pack staging -o $out/your_module.lgx
          '';

          lgx-ui = pkgs.runCommand "your-module-lgx-ui" {
            nativeBuildInputs = [ lgx ];
          } ''
            mkdir -p staging/${variantDev}
            cp ${ui-plugin}/lib/libyour_ui${ext} staging/${variantDev}/your_ui${ext}
            cp ${patchManifest ./ui_manifest.json} staging/manifest.json
            mkdir -p $out
            lgx pack staging -o $out/your_ui.lgx
          '';
        in
        {
          inherit core-module ui-plugin lgx-core lgx-ui;
          default = ui-plugin;
        }
      );
    };
}
