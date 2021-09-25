#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "models/peacetubecontrol.h"
#include "dpihandling.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    qmlRegisterSingletonType<DisplayHandler>("sdk.widgets.display", 1,
                                             0, "Display", DisplayHandler::createInstance);
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    qmlRegisterType<PeaceTubeControl>("peace", 1,0, "PeaceTube");
    qRegisterMetaType<ResultObject*>("ResultObject*");
    qmlRegisterType<ResultListModel>("peace", 1, 0, "ResultListModel");
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.addImportPath("qrc:///"); //Also includes sdk.widgets
    engine.load(url);

    return app.exec();
}
