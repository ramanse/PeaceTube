INCLUDEPATH += $$PWD
INCLUDEPATH += $$PWD/models
DEPENDPATH += $$PWD/models

SOURCES += \
        $$PWD/models/peacetubecontrol.cpp \
        $$PWD/main.cpp \

HEADERS += \
    $$PWD/models/peacetubecontrol.h

RESOURCES += $$PWD/ui/qml.qrc
#RESOURCES += $$PWD/assets/assets.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH += $$PWD/../
