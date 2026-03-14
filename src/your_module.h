#pragma once

#include <QObject>
#include <QString>
#include <QVariantList>

class LogosAPI;  // Forward declaration — always available

/**
 * YourModule — Core business logic for your Logos module.
 *
 * TODO: Replace this stub with your actual module logic.
 *
 * This class is exposed to QML via setContextProperty() in the UI component.
 * All public Q_INVOKABLE methods are callable from QML.
 *
 * Patterns:
 *   - Return JSON strings (QString) for complex data
 *   - Use Q_INVOKABLE for methods callable from QML
 *   - Use Q_PROPERTY for properties bindable in QML
 *   - Emit signals to notify QML of state changes
 */
class YourModule : public QObject {
    Q_OBJECT

    // TODO: Add Q_PROPERTY declarations for QML-bindable state
    // Example:
    // Q_PROPERTY(QString status READ status NOTIFY statusChanged)

public:
    explicit YourModule(QObject *parent = nullptr);

    // TODO: Add your Q_INVOKABLE methods here.
    // These will be callable from QML via the context property.
    //
    // Examples:
    //   Q_INVOKABLE QString listItems();
    //   Q_INVOKABLE QString createItem(const QString &name);
    //   Q_INVOKABLE bool deleteItem(const QString &id);

    /// Placeholder method — returns a greeting. Remove once you add real methods.
    Q_INVOKABLE QString hello() const;

    /// Initialize with Logos Core API (optional — only when running inside logos-app
    /// with logoscore providing KV, messaging, etc.)
    /// Does nothing unless LOGOS_CORE_AVAILABLE is defined at build time.
    Q_INVOKABLE void initLogos(LogosAPI *logosAPIInstance);

signals:
    // TODO: Add signals for QML to react to state changes.
    // Examples:
    //   void itemCreated(const QString &id);
    //   void statusChanged();
    void eventResponse(const QString &eventName, const QVariantList &args);
};
