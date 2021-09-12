import QtQuick 2.14
import QtQuick.Controls 2.12
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.12
import QtQuick.Window 2.14
import QtWebView 1.14
import QtWebEngine 1.10

import peace 1.0

ApplicationWindow {
    id: root
    visible: true
    width: 390
    height: 844
    title: qsTr("Hello World")
    property var webViewObj
    ListModel {
        id: _testModel
        ListElement {
            name: "Bill Smith"
            number: "555 3264"
        }
        ListElement {
            name: "John Brown"
            number: "555 8426"
        }
        ListElement {
            name: "Sam Wise"
            number: "555 0473"
        }
        ListElement {
            name: "Bill Smith"
            number: "555 3264"
        }
        ListElement {
            name: "John Brown"
            number: "555 8426"
        }
        ListElement {
            name: "Sam Wise"
            number: "555 0473"
        }
        ListElement {
            name: "Bill Smith"
            number: "555 3264"
        }
        ListElement {
            name: "John Brown"
            number: "555 8426"
        }
        ListElement {
            name: "Sam Wise"
            number: "555 0473"
        }
        ListElement {
            name: "Bill Smith"
            number: "555 3264"
        }
        ListElement {
            name: "John Brown"
            number: "555 8426"
        }
        ListElement {
            name: "Sam Wise"
            number: "555 0473"
        }
    }

    StackView {
        id: view
        anchors.fill: parent
        initialItem: mainBoard
        function createItem(qmlComponentName, properties) {
            var obj = qmlComponentName.createObject(view, properties);
            return obj;
        }
    }
    Component {
        id: mainBoard
        Item {
            id: searchTube
            anchors.fill: parent
            visible: _peace.isAuthorized
            Rectangle {
                id: inputField
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 15
                height: 40
                color: "transparent"
                border.color: "black"
                border.width: 2
                radius: 10
                TextEdit {
                    id: _editField
                    font.pixelSize: 20
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.right: _goBtn.left
                    anchors.rightMargin: 10
                    height: parent.height - 10
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    id: _goBtn
                    radius: 25
                    width: goText.contentWidth + 30
                    height: parent.height - 10
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    color: "black"
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        id: goText
                        text: "Go"
                        font.pixelSize: 20
                        color: "white"
                        anchors.centerIn: parent
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            _peace.searchText = _editField.text
                        }
                    }
                }
            }

            Flickable {
                flickableDirection: Flickable.VerticalFlick
                boundsBehavior: Flickable.StopAtBounds
                width: parent.width
                anchors.top: inputField.bottom
                anchors.bottom: parent.bottom
                anchors.margins: 15
                anchors.horizontalCenter: parent.horizontalCenter
                clip: true
                contentHeight: _peace.resultListModel.count * 100

                ScrollBar.vertical: ScrollBar { active: true}

                GridLayout {
                    id: gLayout
                    width: parent.width - 30
                    height: parent.height
                    anchors.centerIn: parent
                    columns: 2
                    rowSpacing: 10
                    columnSpacing:10
                    Repeater {
                        model: _peace.resultListModel.count
                        ItemPreviewImage {
                            id: _container
                            Layout.fillWidth: true
                            height:175
                            Layout.preferredWidth: Layout.columnSpan
                            Layout.preferredHeight: 200
                            Layout.maximumHeight: 200
                            source: _container.resultItem.preview
                            property var resultItem: _peace.resultListModel.fetchResultAtIndex(index);
                            Behavior on scale {
                                SmoothedAnimation {
                                    duration: 250
                                }
                            }

                            VideoDescription {
                                title: _container.resultItem.name
                                duration: root.ytDurationToSeconds(_container.resultItem.duration)
                                anchors.bottom: parent.bottom

                            }


                            MouseArea {
                                id: _mArea
                                anchors.fill: parent
                                onPressed: {
                                    _container.scale = 0.9;
                                }
                                onReleased: {
                                    _container.scale = 1.0;
                                }

                                onClicked: {
                                    console.error("Here it is ", "https://www.youtube.com/embed/"+_container.resultItem.videoId)
                                    webViewObj = view.createItem(_ytviewer,{url: "https://www.youtube.com/embed/"+_container.resultItem.videoId+"?autoplay=1&rel=0"});
                                    view.push(webViewObj)

                                }
                            }

                        }
                    }
                }
            }
        }
    }
    PeaceTube {
        id: _peace
        anchors.fill: parent
        visible: !_peace.isAuthorized

    }
    Component {
        id: _ytviewer
        WebEngineView {
            id: webOutput
            anchors.fill: parent

        }
    }

    onClosing: {
        if(view.depth > 1){
            close.accepted = false;
            view.pop();
            gcTimer.start();

        }else{
            return;
        }
    }

    Timer {
        id: gcTimer
        interval: 500
        running: false
        repeat: false
        onTriggered: {
            webViewObj.destroy();
        }
    }


    function ytDurationToSeconds(duration) {
        var durationString = duration.replace("PT","");
        durationString = durationString.replace('H','H:');
        durationString = durationString.replace('M','M:');
        return durationString;
    }
}
