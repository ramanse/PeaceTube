import QtQuick 2.0

Item {

    property alias title: txtName.text
    property alias duration: txtDuration.text
    width: parent.width
    height: 45
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.45; color: "black" }
            GradientStop { position: 1.0; color: "black" }
        }
    }

    Column{
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.fill: parent
        anchors.topMargin: 10
        Text {
            id: txtName
            width: parent.width - 10
            anchors.horizontalCenter: parent.horizontalCenter
            color: "white"
            elide: Text.ElideRight
        }

        Text {
            id: txtDuration
            anchors.horizontalCenter: txtName.horizontalCenter
            color: "white"
        }
    }

}
