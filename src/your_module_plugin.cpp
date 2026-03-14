#include "your_module_plugin.h"

#include <QDebug>

YourModulePlugin::YourModulePlugin(QObject *parent)
    : QObject(parent)
    , m_module(new YourModule(this))
{
    connect(m_module, &YourModule::eventResponse,
            this, &YourModulePlugin::eventResponse);
}

void YourModulePlugin::initLogos(LogosAPI *api) {
    m_logosAPI = api;
    logosAPI = api;  // PluginInterface base-class field

    if (!m_logosAPI) {
        qWarning() << "YourModulePlugin: initLogos called with null LogosAPI";
        return;
    }

    qInfo() << "YourModulePlugin: initLogos done. version:" << version();
}

QString YourModulePlugin::hello() const {
    return m_module->hello();
}
