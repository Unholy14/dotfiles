import QtQuick
import Quickshell
import Quickshell.Wayland
import QtQuick.Layouts

PanelWindow {
    id: topBar
    anchors.top: true
    anchors.left: true
    anchors.right: true
    height: 45
    color: "transparent"

    WlrLayershell.namespace: "topbar"
    WlrLayershell.layer: WlrLayershell.Layer.Top
    exclusionMode: PanelWindow.ExclusionMode.Exclusive

    RowLayout {
        anchors.fill: parent
        anchors.topMargin: 8
        anchors.leftMargin: 15
        anchors.rightMargin: 15
        spacing: 12

        // ISLA 1: Workspaces
        Rectangle {
            Layout.preferredHeight: 32
            Layout.preferredWidth: 100
            radius: 6
            color: "#080808"
            border.color: hoverWs.containsMouse ? "#444444" : "#333333"

            Behavior on border.color { 
                ColorAnimation { duration: 300 } 
            }
            
            MouseArea {
                id: hoverWs
                anchors.fill: parent
                hoverEnabled: true
            }

            Row {
                anchors.centerIn: parent
                spacing: 8
                Repeater {
                    model: 5
                    Rectangle {
                        width: (index + 1) === root.activeWs ? 24 : 10
                        height: 10
                        radius: 5
                        color: (index + 1) === root.activeWs ? "#ffffff" : "#220000"
                        opacity: (index + 1) === root.activeWs ? 1.0 : 0.6
                        
                        Behavior on width { 
                            NumberAnimation { duration: 300; easing.type: Easing.OutCubic } 
                        }
                        Behavior on color { 
                            ColorAnimation { duration: 300 } 
                        }
                    }
                }
            }
        }

        // ISLA 1.5: Atajos
        Rectangle {
            Layout.preferredHeight: 32
            Layout.preferredWidth: 100
            radius: 6
            color: "#080808"
            border.color: "#333333"

            Row {
                anchors.centerIn: parent
                spacing: 15
                
                Text {
                    text: "󰔊"
                    color: hoverLyr.containsMouse ? "#ffffff" : "#888888"
                    font.pixelSize: 16
                    MouseArea {
                        id: hoverLyr
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            cmdLyrics.running = false
                            cmdLyrics.running = true
                        }
                    }
                }
                Text {
                    text: "󰓃"
                    color: hoverEq.containsMouse ? "#ffffff" : "#888888"
                    font.pixelSize: 16
                    MouseArea {
                        id: hoverEq
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            cmdEq.running = false
                            cmdEq.running = true
                        }
                    }
                }
                Text {
                    text: "󰋋"
                    color: hoverMix.containsMouse ? "#ffffff" : "#888888"
                    font.pixelSize: 16
                    MouseArea {
                        id: hoverMix
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            cmdMixer.running = false
                            cmdMixer.running = true
                        }
                    }
                }
            }
        }

        // ISLA 2: Música Interactiva
        Rectangle {
            Layout.preferredHeight: 32
            Layout.preferredWidth: (root.musicTitle !== "" && root.musicTitle !== "Sin reproducción") ? 250 : 0
            visible: Layout.preferredWidth > 0
            radius: 6
            color: "#080808"
            border.color: hoverMusic.containsMouse ? "#444444" : "#333333"
            clip: true

            Behavior on Layout.preferredWidth { 
                NumberAnimation { duration: 400; easing.type: Easing.OutBack } 
            }
            
            MouseArea {
                id: hoverMusic
                anchors.fill: parent
                hoverEnabled: true
            }

            Image {
                anchors.fill: parent
                source: root.musicCover
                fillMode: Image.PreserveAspectCrop
                opacity: 0.15
            }

            Row {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -2
                spacing: 8
                
                Text {
                    text: "󰎈"
                    color: "#ffffff"
                    font.pixelSize: 14
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            cmdPlay.running = false
                            cmdPlay.running = true
                        }
                    }
                }
                Text {
                    text: root.musicTitle
                    color: "#888888"
                    font.pixelSize: 11
                    font.bold: true
                    width: 180
                    elide: Text.ElideRight
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 5
                color: "#220000"
                
                Rectangle {
                    width: parent.width * (root.draggingMusic ? root.dragMusicProgress : root.musicProgress)
                    height: parent.height
                    color: "#ffffff"
                    radius: 2
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onPressed: function(mouse) {
                        root.draggingMusic = true
                        root.dragMusicProgress = Math.max(0, Math.min(1, mouse.x / width))
                    }
                    onPositionChanged: function(mouse) {
                        if (pressed) {
                            root.dragMusicProgress = Math.max(0, Math.min(1, mouse.x / width))
                        }
                    }
                    onReleased: function(mouse) {
                        root.draggingMusic = false
                        if (root.musicLenSec > 0) {
                            var p = Math.max(0, Math.min(1, mouse.x / width))
                            cmdSeek.targetSec = Math.floor(p * root.musicLenSec).toString()
                            cmdSeek.running = false
                            cmdSeek.running = true
                            root.musicProgress = p
                        }
                    }
                }
            }
        }

        Item { 
            Layout.fillWidth: true 
        }

        // ISLA 3: Reloj Central
        Rectangle {
            Layout.preferredHeight: 32
            Layout.preferredWidth: 220
            radius: 6
            color: "#080808"
            border.color: "#333333"
            
            Text {
                anchors.centerIn: parent
                text: root.currentDate + "  ◈  " + root.currentTime
                color: "#ffffff"
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 2
            }
        }

        Item { 
            Layout.fillWidth: true 
        }

        // ISLA 4: Estado
        Row {
            spacing: 12
            
            Rectangle {
                height: 32
                width: 110
                radius: 6
                color: "#080808"
                border.color: hoverState.containsMouse ? "#444444" : "#333333"
                
                Behavior on border.color { 
                    ColorAnimation { duration: 300 } 
                }
                
                MouseArea {
                    id: hoverState
                    anchors.fill: parent
                    hoverEnabled: true
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 15
                    
                    Text {
                        text: "󰂯"
                        color: root.btOn ? "#ffffff" : "#440000"
                        font.pixelSize: 15
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -5
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                cmdOpenBt.running = false
                                cmdOpenBt.running = true
                            }
                        }
                    }
                    Text {
                        text: "󰖩"
                        color: root.wifiOn ? "#ffffff" : "#440000"
                        font.pixelSize: 15
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -5
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                cmdOpenWifi.running = false
                                cmdOpenWifi.running = true
                            }
                        }
                    }
                    Text {
                        text: "󰕾"
                        color: "#ffffff"
                        font.pixelSize: 15
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -5
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.panelVisible = !root.panelVisible
                            }
                        }
                    }
                }
            }
            
            Rectangle {
                height: 32
                width: 70
                radius: 6
                color: "#080808"
                border.color: "#333333"
                
                Row {
                    anchors.centerIn: parent
                    spacing: 6
                    
                    Text {
                        text: "󰁹"
                        color: "#ffffff"
                        font.pixelSize: 14
                    }
                    Text {
                        text: root.valBAT + "%"
                        color: "#888888"
                        font.pixelSize: 11
                        font.bold: true
                    }
                }
            }
        }
    }
}
