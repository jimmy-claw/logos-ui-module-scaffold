# Logos UI Module Scaffold

Generic template for building **IComponent UI plugins** for [logos-app](https://github.com/logos-co/logos-app-poc).

This scaffold produces two build targets:

| Target | Output | Purpose |
|--------|--------|---------|
| `your_ui` | `libyour_ui.so` | IComponent UI plugin loaded by logos-app |
| `your_module_plugin` | `your_module_plugin.so` | Headless logoscore module (optional) |

## Architecture

> **logos-app requires a backend module to load any UI plugin.**
> The UI plugin declares the backend module as a dependency in .
> logos-app spins up the backend module in a separate process, then loads the UI.
> Even if your app has no persistent state, you still need the backend module stub.

## Quick Start

```bash
# 1. Clone this scaffold
git clone <this-repo> my_module
cd my_module

# 2. Rename everything (find-and-replace)
#    your_module  → my_module
#    YourModule   → MyModule
#    your_ui      → my_ui
#    yourModule   → myModule   (QML context property)
#    your_module_plugin → my_module_plugin
#    YourModulePlugin   → MyModulePlugin
#    YourUIComponent    → MyUIComponent

# 3. Build the UI plugin
make build-ui-plugin

# 4. Install to logos-app
make install

# 5. Run logos-app
cd ~/logos-workspace && nix run .#logos-app-poc
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
5. **`ui_metadata.json`** — Update name, description, author

### Optional (for advanced integration)

6. **`src/your_module_plugin.h/cpp`** — Add forwarding methods if you add new methods to YourModule
7. **`qml/your_ui.qrc`** — Add additional QML files to the resource bundle
8. **`flake.nix`** — Update description and pname

## Architecture

```
logos-app loads your_ui.so (IComponent)
    └── YourUIComponent::createWidget()
        ├── Creates QQuickWidget
        ├── Creates YourModule (C++ backend)
        ├── Exposes backend to QML: setContextProperty("yourModule", backend)
        └── Loads QML: qrc:/your_module/MainView.qml
```

### File Overview

```
├── CMakeLists.txt              # Build config (BUILD_UI_PLUGIN / BUILD_MODULE)
├── Makefile                    # Convenience targets
├── metadata.json               # Module manifest (for logoscore)
├── ui_metadata.json            # UI plugin manifest (for logos-app)
├── flake.nix                   # Nix packaging
├── interfaces/
│   └── IComponent.h            # Plugin interface (from logos-app)
├── src/
│   ├── your_module.h/cpp       # ★ YOUR CODE HERE — module business logic
│   ├── your_module_plugin.h/cpp # Headless logoscore wrapper
│   ├── your_ui_component.h/cpp  # IComponent entry point (complete)
└── qml/
    ├── MainView.qml            # ★ YOUR QML HERE — main UI
    └── your_ui.qrc             # QML resource bundle
```

## Build Targets

```bash
make build-ui-plugin   # Build IComponent UI plugin (libyour_ui.so)
make install           # Install UI plugin to ~/.local/share/Logos/LogosAppNix/plugins/your_ui/
make build-module      # Build headless logoscore plugin (your_module_plugin.so)
make install-module    # Install module to ~/.local/share/Logos/LogosAppNix/modules/your_module/
make install-all       # Install both UI plugin and module
make setup-nix-merged  # Create merged SDK dirs from split nix packages
make clean             # Remove all build directories
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

### C++ ↔ QML Bridge

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

## Nix Build

```bash
nix build .#ui-plugin
```
