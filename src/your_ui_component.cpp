#include "your_ui_component.h"
#include "your_module.h"

#include <QQuickWidget>
#include <QQmlContext>

QWidget* YourUIComponent::createWidget(LogosAPI* logosAPI) {
    auto* quickWidget = new QQuickWidget();
    quickWidget->setMinimumSize(800, 600);
    quickWidget->setResizeMode(QQuickWidget::SizeRootObjectToView);

    // Create the C++ backend and parent it to the widget (auto-cleanup)
    auto* backend = new YourModule();
    backend->setParent(quickWidget);

#ifdef LOGOS_CORE_AVAILABLE
    if (logosAPI) {
        backend->initLogos(logosAPI);
    }
#endif

    // Expose the backend to QML as "yourModule"
    // TODO: Change "yourModule" to match your module's name
    quickWidget->rootContext()->setContextProperty("yourModule", backend);

    // Load the main QML file from the embedded resource
    // TODO: Update the resource path prefix to match your_ui.qrc
    quickWidget->setSource(QUrl("qrc:/your_module/MainView.qml"));

    return quickWidget;
}

void YourUIComponent::destroyWidget(QWidget* widget) {
    delete widget;
}
