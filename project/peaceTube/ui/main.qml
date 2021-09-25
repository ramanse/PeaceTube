import QtQuick 2.14
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.14
import QtWebView 1.14
import QtWebEngine 1.10
import QtGraphicalEffects 1.14

import peace 1.0
import sdk.widgets.qml 1.0
import sdk.widgets.display 1.0

ApplicationWindow {
    id: root
    visible: true
    title: qsTr("PeaceTube")
    width: Display.screenWidth
    height: Display.screenHeight
    property var webViewObj

    ListModel {
        id: categoriesModel

        ListElement {
            name: "Comedy"
            icon: "icon_comedy"
            searchText: "Comedy Shows"
        }
        ListElement {
            name: "News"
            icon: "icon_news"
            searchText: "News channels"
        }
        ListElement {
            name: "Meditation"
            icon: "icon_meditation"
            searchText: "Calm Meditation music"
        }
        ListElement {
            name: "Podcasts"
            icon: "icon_podcasts"
            searchText: "Science podcasts"
        }
        ListElement {
            name: "Cartoons"
            icon: "icon_kidsshow"
            searchText: "Cartoon Shows"
        }
        ListElement {
            name: "Music"
            icon: "icon_music"
            searchText: "Latest Trending music"
        }
        ListElement {
            name: "Cooking"
            icon: "icon_cooking"
            searchText: "Cooking Shows"
        }
        ListElement {
            name: "Movies"
            icon: "icon_movies"
            searchText: "Youtube movies"
        }
        ListElement {
            name: "Dramas"
            icon: "icon_drama"
            searchText: "Indian Daramas"
        }
        ListElement {
            name: "Yoga"
            icon: "icon_yoga"
            searchText: "Rashmi Yogalates"
        }
        ListElement {
            name: "Lifestyle"
            icon: "icon_lifestyle"
            searchText: "Lifestyle vlog"
        }
        ListElement {
            name: "Surprise me!"
            icon: "icon_surpriseme"
            searchText: "Current Trends"
        }
    }

    WgtScreen {
        id: searchTube
        width: parent.width
        height: parent.height
        visible: _peace.isAuthorized
        headerComponent: _headerCompo
        pageContent: _predictionsList
        enableBusyTimer: false
        Component {
            id: _headerCompo
            Rectangle {
                id: header
                width: parent.width
                property bool isInDeepState: _peace.searchText !== "" ||  _peace.composedText !== ""
                height:  {
                    var itemHeight = isInDeepState ? Display.dp(80) : Display.dp(172);
                    return itemHeight;

                }
                anchors.top: parent.top
                color: Common.themeColor
                function resetSearchText() {
                    _searchBar.editSearchText = "";
                }

                WgtText {
                    id: caretgoryName
                    width: parent.width - Display.dp(30)
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Display.dp(8)
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    text: searchTube.content.pageStackView.currentItem.headerText
                    visible: text !== ""
                    font.pixelSize : Display.sp(24)
                }


                WgtSearchBar {
                    id: _searchBar
                    anchors {
                        left: parent.left
                        leftMargin: Display.dp(12)
                        right: parent.right
                        rightMargin: Display.dp(12)
                        bottom: parent.bottom
                        bottomMargin: isInDeepState ? Display.dp(6) : Display.dp(12)
                    }

                    height: isInDeepState ? Display.dp(80) :  Display.dp(100)
                    radius:  isInDeepState ? Display.dp(20) : Display.dp(30)
                    showGoIcon: false
                    visible: _peace.composedText === ""
                    onSearchTextChanged: {
                        _peace.searchText = _searchBar.searchText;
                    }
                }

            }
        }
        Component {
            id: _pageContent
            Flickable {
                flickableDirection: Flickable.VerticalFlick
                boundsBehavior: Flickable.StopAtBounds
                width: parent.width
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 15
                anchors.horizontalCenter: parent.horizontalCenter
                clip: true
                contentHeight: _peace.searchResultList.length * 100 + Display.dp(300)
                property string headerText: _peace.composedText

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
                        model: _peace.searchResultList.length
                        ItemPreviewImage {
                            id: _container
                            property var resultItem: _peace.searchResultList[index]
                            Layout.fillWidth: true
                            height:175
                            Layout.preferredWidth: Layout.columnSpan
                            Layout.preferredHeight: 200
                            Layout.maximumHeight: 200
                            source: _container.resultItem.snippet.thumbnails.medium.url
                            Behavior on scale {
                                SmoothedAnimation {
                                    duration: 250
                                }
                            }

                            VideoDescription {
                                title: _container.resultItem.snippet.title
                                //duration: root.ytDurationToSeconds(_container.resultItem.duration)
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
                                    searchTube.content.pageStackView.push(_ytviewer, {url: "https://www.youtube.com/embed/"+_container.resultItem.id.videoId+"?autoplay=1&rel=0&enablejsapi=1", headerText: _container.resultItem.snippet.title });
                                }
                            }

                        }
                    }
                }
            }
        }
        Component {
            id: _predictionsList
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: Display.dp(20)
                radius: Display.dp(20)
                border.color: Common.themeColor
                border.width: 2
                property alias pageStackView: pageContents
                property string searchText: _peace.searchText
                onSearchTextChanged: {
                    if (pageContents.depth === 2) {
                        pageContents.pop();
                    }
                }


                StackView {
                    id: pageContents
                    anchors.fill: parent
                    initialItem: _categories
                    onDepthChanged: {
                        if (depth === 1) {
                            _peace.composedText = "";
                        }
                    }

                    pushEnter: Transition {
                        PropertyAnimation {
                            property: "opacity"
                            from: 0
                            to:1
                            duration: 0
                        }
                    }
                    pushExit: Transition {
                        PropertyAnimation {
                            property: "opacity"
                            from: 1
                            to:0
                            duration: 0
                        }
                    }
                    popEnter: Transition {
                        PropertyAnimation {
                            property: "opacity"
                            from: 0
                            to:1
                            duration: 0
                        }
                    }
                    popExit: Transition {
                        PropertyAnimation {
                            property: "opacity"
                            from: 1
                            to:0
                            duration: 0
                        }
                    }

                }
                Component {
                    id: _categories
                    Item {
                        anchors.fill: parent
                        GridLayout {
                            id: category
                            width: parent.width - 30
                            height: parent.height
                            anchors.centerIn: parent
                            columns: 3
                            rowSpacing: 10
                            columnSpacing:10
                            visible: _peace.searchText === ""
                            Repeater {
                                model: categoriesModel.count
                                Rectangle {
                                    id: _container
                                    Layout.fillWidth: true
                                    height:Display.dp(125)
                                    Layout.preferredWidth: Layout.columnSpan
                                    Layout.preferredHeight: Display.dp(125)
                                    Layout.maximumHeight: Display.dp(125)
                                    color: "white"
                                    border.color: Common.themeColor
                                    border.width: 1
                                    radius: Display.dp(16)
                                    property var categoryData: categoriesModel.get(index)
                                    WgtTouchIcon {
                                        id: searchIconItem
                                        anchors.verticalCenterOffset: -Display.dp(20)
                                        anchors.centerIn: parent
                                        colorizeTo: Common.themeColor
                                        pressEffect: false
                                        icon.source: Common.getQrcIcon(categoryData.icon)
                                    }
                                    WgtText {
                                        id: caretgoryName
                                        width: parent.width
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.bottom: parent.bottom
                                        anchors.bottomMargin: Display.dp(8)
                                        color: "black"
                                        horizontalAlignment: Text.AlignHCenter
                                        text: categoryData.name
                                        font.pixelSize : Display.sp(16)
                                    }

                                    Behavior on scale {
                                        SmoothedAnimation {
                                            duration: 250
                                        }
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
                                            _peace.composedText = categoryData.searchText;
                                            //searchTube.showBusy = Qt.binding(() => _peace.searchResultList.length <= 0);
                                            pageContents.push(_pageContent);
                                        }
                                    }

                                }
                            }
                        }
                        ListView {
                            id: _pList
                            boundsBehavior: Flickable.StopAtBounds
                            width: parent.width + Display.dp(30)
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.margins: Display.dp(15)
                            anchors.horizontalCenter: parent.horizontalCenter
                            clip: true
                            property var predictions: getPredictionsList(_peace.predictionsList)
                            model: _pList.predictions.length - 1
                            visible: _peace.searchText !== ""
                            delegate:
                                Rectangle {
                                width: parent.width - Display.dp(50)
                                height: Display.dp(60)
                                anchors.horizontalCenter: parent.horizontalCenter

                                WgtIcon {
                                    id: searchIconItem
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    iconName: "icon_search"
                                }

                                WgtText {
                                    id: txtName
                                    width: parent.width - 3*searchIconItem.width
                                    anchors.left: searchIconItem.right
                                    anchors.leftMargin: Display.dp(8)
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: "black"
                                    elide: Text.ElideRight
                                    text: _pList.predictions[index]
                                }
                                WgtIcon {
                                    id: arrowIconItem
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.right: parent.right
                                    iconName: "icon_diagonalarrow"
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        _peace.composedText = txtName.text;
                                        //searchTube.showBusy = Qt.binding(() => _peace.searchResultList.length <= 0);
                                        pageContents.push(_pageContent);

                                    }
                                }
                            }
                            ScrollBar.vertical: ScrollBar { active: _pList.predictions.length > 0}
                        }

                    }
                }

            }
        }

        Component {
            id: _ytviewer
            WebEngineView {
                id: webOutput
                anchors.fill: parent
                url: "./player.html"
                property string headerText: ""

            }
        }

    }

    function getPredictionsList(predictionText) {
        const predictions = [];
        predictionText.split('[').forEach((ele, index) => {
                                              if (!ele.split('"')[1] || index === 1) return;
                                              return predictions.push(ele.split('"')[1]);
                                          });
        return predictions;
    }

    PeaceTube {
        id: _peace
        anchors.fill: parent
        visible: !_peace.isAuthorized

    }

    onClosing: {
        if(searchTube.content){
            if (searchTube.content.pageStackView.depth > 1) {
                close.accepted = false;
                searchTube.content.pageStackView.pop();
            } else if (_peace.searchText !== "") {
                close.accepted = false;
                searchTube.headerContent.resetSearchText();
            } else {
                return;
            }

        }else{
            return;
        }
    }

    function ytDurationToSeconds(duration) {
        var durationString = duration.replace("PT","");
        durationString = durationString.replace('H','H:');
        durationString = durationString.replace('M','M:');
        return durationString;
    }
    Component.onCompleted: {
        Common.themeColor = "#CCCC00";
    }
}
