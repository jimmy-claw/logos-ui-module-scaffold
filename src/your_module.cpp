#include "your_module.h"

#include <QDebug>

// TODO: Add additional includes as needed (QJsonDocument, QUuid, etc.)

YourModule::YourModule(QObject *parent)
    : QObject(parent)
{
    // TODO: Initialize your module state here.
    qDebug() << "YourModule: initialized";
}

QString YourModule::hello() const {
    // TODO: Remove this placeholder and add your real methods.
    return QStringLiteral("Hello from YourModule!");
}

void YourModule::initLogos(LogosAPI *logosAPIInstance) {
#ifdef LOGOS_CORE_AVAILABLE
    // TODO: Store the LogosAPI pointer and use it to access Logos Core services
    // (KV store, messaging, identity, etc.)
    //
    // Example:
    //   m_kvClient = logosAPIInstance->getClient("kv_module");
    //   m_deliveryClient = logosAPIInstance->getClient("delivery_module");
    Q_UNUSED(logosAPIInstance)
    qDebug() << "YourModule: initLogos called";
#else
    // When compiled into UI plugin (LOGOS_CORE_AVAILABLE not defined), logos_core
    // symbols (logos_kv_get, logos_kv_free, logos_request_complete) are NOT available.
    // Use dlsym to load them optionally:
    //
    // #include <dlfcn.h>
    // void* lib = dlopen(nullptr, RTLD_NOW);
    // auto kv_get = lib ? (bool(*)(void*,const char*,char**))dlsym(lib, "logos_kv_get") : nullptr;
    // if (lib) dlclose(lib);
    // if (kv_get && m_kv) kv_get(m_kv, key, &value);
    Q_UNUSED(logosAPIInstance)
#endif
}
