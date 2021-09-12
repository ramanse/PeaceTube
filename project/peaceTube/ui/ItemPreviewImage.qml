import QtQuick 2.14
import QtGraphicalEffects 1.13


Image {
    id: _image
    cache: true
    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            width: _image.width
            height: _image.height
            radius: 9
        }
    }
}
