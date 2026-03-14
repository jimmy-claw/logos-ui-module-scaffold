#pragma once

#include <QObject>
#include <QString>
#include <QVariantList>

#include "your_module.h"

#include <interface.h>
#include <logos_api.h>

/**
 * YourModulePlugin — Headless logoscore plugin wrapper.
 *
 * Loaded by logos_host as a shared library. Wraps YourModule and exposes its
 * methods via QtRO (Qt Remote Objects) for other modules and the QML UI to call.
 *
 * Must NOT use Qt Quick, QML engine, or any GUI classes — only Qt Core/Qml/RemoteObjects.
 */
class YourModulePlugin : public QObject, public PluginInterface {
    Q_OBJECT
#ifndef YOUR_MODULE_UI_BUILD
    Q_PLUGIN_METADATA(IID PluginInterface_iid FILE "metadata.json")
#endif
    Q_INTERFACES(PluginInterface)

public:
    explicit YourModulePlugin(QObject *parent = nullptr);

    // ── PluginInterface ─────────────────────────────────────────────────────
    [[nodiscard]] QString name() const override { return QStringLiteral("your_module"); }
    Q_INVOKABLE QString version() const override { return QStringLiteral("0.1.0"); }
    Q_INVOKABLE void initLogos(LogosAPI *api);

    // TODO: Add Q_INVOKABLE forwarding methods that delegate to m_module.
    // Every public method on YourModule should have a corresponding forwarding
    // method here so logoscore can expose it via QtRO.
    //
    // Example:
    //   Q_INVOKABLE QString listItems() { return m_module->listItems(); }
    //   Q_INVOKABLE QString createItem(const QString &name) { return m_module->createItem(name); }

    Q_INVOKABLE QString hello() const;

signals:
    void eventResponse(const QString &eventName, const QVariantList &args);

private:
    YourModule *m_module = nullptr;
    LogosAPI *m_logosAPI = nullptr;
};
