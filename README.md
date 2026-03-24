# Logos UI Module Scaffold

Generic template for building **IComponent UI plugins** for [logos-app](https://github.com/logos-co/logos-app-poc).

This scaffold produces two build targets:

| Target | Output | Purpose |
|--------|--------|---------|
| `your_ui` | `libyour_ui.so` | IComponent UI plugin loaded by logos-app |
| `your_module_plugin` | `your_module_plugin.so` | Headless logoscore module (required) |

## Architecture

> **logos-app requires a backend module to load any UI plugin.**
> The UI plugin declares the backend module as a dependency in `ui_metadata.json`.
> logos-app spins up the backend module in a separate process, then loads the UI.
> Even if your app has no persistent state, you still need the backend module stub.

## Quick Start

```bash
# 1. Clone this scaffold
git clone <this-repo> my_module
cd my_module

# 2. Rename everything (find-and-replace)
#    your_module  -> my_module
#    YourModule   -> MyModule
#    your_ui      -> my_ui
#    yourModule   -> myModule   (QML context property)
#    your_module_plugin -> my_module_plugin
#    YourModulePlugin   -> MyModulePlugin
#    YourUIComponent    -> MyUIComponent

# 3. Build lgx packages and install
make install-lgx

# 4. Run logos-app
cd ~/logos-workspace && nix run .#logos-app-poc
```

## Installing with lgx

The recommended way to build and install is via lgx packages:

```bash
# Build both lgx packages (core module + UI plugin)
make build

# Install via lgpm
make install-lgx

# Or with a custom data dir:
make install-lgx LOGOS_DATA_DIR=/path/to/LogosAppNix
```

`make build` runs `nix build .#lgx-core -o result-core` and `nix build .#lgx-ui -o result-ui`.
`make install-lgx` installs the resulting `.lgx` files via `lgpm`.

You need one lgx per type: **core modules and UI plugins cannot share one lgx**.
- `lgx-core` packages the headless logoscore module
- `lgx-ui` packages the IComponent UI plugin

## metadata.json vs manifest.json

This scaffold uses two JSON files per component that must be kept consistent:

| File | Purpose | Consumed by |
|------|---------|-------------|
| `metadata.json` | Compiled into `.so` via `Q_PLUGIN_METADATA` | Qt plugin loader, runtime dependency resolution |
| `manifest.json` | Packaging manifest for lgpm | `lgpm install`, lgx packaging |

**`metadata.json` is the authoritative source for runtime dependency resolution.**
It is embedded in the shared library at compile time and is what logoscore / logos-app
reads to resolve module dependencies at runtime.

**`manifest.json` is only used by lgpm for packaging.** It goes into the lgx archive
and tells lgpm how to install the module.

Both files must agree on `name`, `version`, `dependencies`, and `main` entries.

Similarly for the UI plugin: `ui_metadata.json` (compiled in) and `ui_manifest.json` (lgpm).

### Dependency resolution

The `dependencies` array uses the **`name` field from the dependency's manifest** — not
the directory name, not the repo name, not the flake output name. For example, if your
module depends on a module whose `metadata.json` contains `"name": "kv_module"`, then:

```json
"dependencies": ["kv_module"]
```

## Testing

The scaffold includes a UI test framework powered by [logos-qt-mcp](https://github.com/logos-co/logos-qt-mcp) — the same tool used for Logos App's own CI.

### Quick start

```bash
# Build logos-qt-mcp from logos-basecamp (one-time)
cd ~/logos-basecamp && nix build .#x86_64-linux.logosQtMcp -o result-mcp

# Run tests (app must be running)
./tests/run-tests.sh
```

### CI / headless mode

```bash
# Launches Xvfb, starts app with inspector, runs tests, cleans up
./tests/ci-test.sh
```

### Writing tests

Edit `tests/ui-tests.mjs`:

```javascript
test("my_module: verify UI loads", async (app) => {
  await app.click("my_module");           // click sidebar item
  await app.expectTexts(["expected text"]); // assert visible
  await app.screenshot();                 // PNG screenshot
});
```

Available assertions: `app.expectTexts()`, `app.expectAbsent()`
Available actions: `app.click()`, `app.type()`, `app.findByType()`, `app.screenshot()`, `app.evaluate()`

## What to Fill In

### Required (your module won't do anything without these)

1. **`src/your_module.h`** — Add your Q_INVOKABLE methods and Q_PROPERTY declarations
2. **`src/your_module.cpp`** — Implement your module logic
3. **`qml/MainView.qml`** — Build your QML UI (backend available as `yourModule`)
4. **`metadata.json`** — Update name, description, author, dependencies
5. **`manifest.json`** — Update to match metadata.json (used by lgpm)
6. **`ui_metadata.json`** — Update name, description, author
7. **`ui_manifest.json`** — Update to match ui_metadata.json (used by lgpm)

### Optional (for advanced integration)

8. **`src/your_module_plugin.h/cpp`** — Add forwarding methods if you add new methods to YourModule
9. **`qml/your_ui.qrc`** — Add additional QML files to the resource bundle
10. **`flake.nix`** — Update description and pname

## Architecture

```
logos-app loads your_ui.so (IComponent)
    +-- YourUIComponent::createWidget()
        |-- Creates QQuickWidget
        |-- Creates YourModule (C++ backend)
        |-- Exposes backend to QML: setContextProperty("yourModule", backend)
        +-- Loads QML: qrc:/your_module/MainView.qml
```

### File Overview

```
|-- CMakeLists.txt              # Build config (BUILD_UI_PLUGIN / BUILD_MODULE)
|-- Makefile                    # build / install-lgx (lgx) + dev targets (cmake)
|-- metadata.json               # Core module metadata (compiled into .so)
|-- manifest.json               # Core module lgpm manifest (packaging only)
|-- ui_metadata.json            # UI plugin metadata (compiled into .so)
|-- ui_manifest.json            # UI plugin lgpm manifest (packaging only)
|-- flake.nix                   # Nix packaging (lgx-core, lgx-ui outputs)
|-- interfaces/
|   +-- IComponent.h            # Plugin interface (from logos-app)
|-- src/
|   |-- your_module.h/cpp       # YOUR CODE HERE -- module business logic
|   |-- your_module_plugin.h/cpp # Headless logoscore wrapper
|   +-- your_ui_component.h/cpp  # IComponent entry point (complete)
+-- qml/
    |-- MainView.qml            # YOUR QML HERE -- main UI
    +-- your_ui.qrc             # QML resource bundle
```

## Build Targets

```bash
# lgx packaging (production)
make build             # nix build .#lgx-core + .#lgx-ui
make install-lgx       # lgpm install both lgx packages

# Local CMake development
make cmake-build       # CMake build (default config)
make build-ui-plugin   # Build IComponent UI plugin (libyour_ui.so)
make install           # Install UI plugin to ~/.local/share/Logos/LogosAppNix/plugins/your_ui/
make build-module      # Build headless logoscore plugin (your_module_plugin.so)
make install-module    # Install module to ~/.local/share/Logos/LogosAppNix/modules/your_module/
make install-all       # Install both UI plugin and module
make setup-nix-merged  # Create merged SDK dirs from split nix packages
make clean             # Remove all build directories and result symlinks
```

## How It Works

### IComponent Interface

logos-app discovers plugins by loading `.so` files from the plugins directory. Each plugin implements `IComponent`:

```cpp
class IComponent {
public:
    virtual QWidget* createWidget(LogosAPI* logosAPI = nullptr) = 0;
    virtual void destroyWidget(QWidget* widget) = 0;
};
```

Your plugin's `createWidget()` returns a `QQuickWidget` containing your QML UI.

### C++ / QML Bridge

Expose your C++ backend to QML via context properties:

```cpp
// In your_ui_component.cpp
quickWidget->rootContext()->setContextProperty("yourModule", backend);
```

Then call methods from QML:

```qml
// In MainView.qml
var result = yourModule.hello()
var items = JSON.parse(yourModule.listItems())
```

### Logos Core Integration (Optional)

If `LogosAPI*` is provided by logos-app, you can access Logos Core services:

```cpp
#ifdef LOGOS_CORE_AVAILABLE
void YourModule::initLogos(LogosAPI *api) {
    m_kvClient = api->getClient("kv_module");        // KV persistence
    m_deliveryClient = api->getClient("delivery_module"); // P2P messaging
}
#endif
```

## Adding QML Files

1. Create the `.qml` file in `qml/`
2. Add it to `qml/your_ui.qrc`:
   ```xml
   <qresource prefix="/your_module">
       <file>MainView.qml</file>
       <file>MyNewView.qml</file>
   </qresource>
   ```
3. Reference it from QML: `source: "qrc:/your_module/MyNewView.qml"`

## Common Gotchas

Lessons learned from building real modules (yolo-ng, logos-zone-sequencer-module):

### 1. Missing IComponent constructor -> "undefined symbol" at dlopen

`YourUIComponent` must have an explicit constructor declared and defined:

```cpp
// your_ui_component.h
explicit YourUIComponent(QObject *parent = nullptr);

// your_ui_component.cpp
YourUIComponent::YourUIComponent(QObject *parent) : QObject(parent) {}
```

Without this, logos-app fails with an "undefined symbol" error when loading the plugin.

### 2. Do NOT define `LOGOS_CORE_AVAILABLE` for the UI plugin

The UI plugin (`your_ui`) is loaded by logos-app via `dlopen`. If you compile it with
`LOGOS_CORE_AVAILABLE`, it will try to link logos_core symbols directly, causing
"undefined symbol" at load time. The headless module (`your_module_plugin`) can safely
define `LOGOS_CORE_AVAILABLE` because it runs inside logoscore where the symbols exist.

In `CMakeLists.txt`, the UI target should link logos_core headers but **not** define
the compile flag. Use `dlsym` at runtime instead (see below).

### 3. Use `dlsym` for logos_core symbols in the UI plugin

Since the UI plugin cannot link logos_core symbols directly, use `dlsym` to load them
at runtime when they happen to be available:

```cpp
#include <dlfcn.h>
void* lib = dlopen(nullptr, RTLD_NOW);
auto kv_get = lib ? (bool(*)(void*,const char*,char**))dlsym(lib, "logos_kv_get") : nullptr;
if (lib) dlclose(lib);
if (kv_get && m_kv) kv_get(m_kv, key, &value);
```

### 4. `initLogos` must be `Q_INVOKABLE`

`logos_host` dispatches `initLogos` via the Qt meta-object system. If the method is not
marked `Q_INVOKABLE`, the call silently fails and your module never receives the LogosAPI.

### 5. Do NOT shadow the C++ context property in QML

Do **not** add `property var yourModule: null` in your QML root item. This shadows the
C++ context property injected by `setContextProperty()`, and `yourModule` will always
be `null` in QML. Just reference `yourModule` directly.

### 6. `metadata.json` must include the `main` field

Without the `main` -> platform -> `.so` mapping, LogosApp cannot auto-load your module:

```json
{
  "main": {
    "linux-x86_64": "your_module_plugin.so",
    "linux-aarch64": "your_module_plugin.so"
  }
}
```

### 7. lgx variant dirs use `-dev` suffix, manifest keys do not

Inside an lgx archive, the platform variant directory is named with a `-dev` suffix
(e.g. `linux-x86_64-dev/`), but the `main` keys in `manifest.json` must **not** include
`-dev` (e.g. `"linux-x86_64": "your_module_plugin.so"`). The Nix `patchManifest` step
strips `-dev` from manifest keys automatically.

### 8. Dependency name = `name` field in the dependency's manifest

When listing dependencies, use the value of the `"name"` field in the dependency's
`metadata.json` / `manifest.json` — not the directory name, not the git repo name.

## Nix Build

```bash
# Build lgx packages
nix build .#lgx-core    # -> result-core/your_module.lgx
nix build .#lgx-ui      # -> result-ui/your_ui.lgx

# Build individual Nix derivations
nix build .#core-module  # Headless logoscore plugin
nix build .#ui-plugin    # IComponent UI plugin
```
