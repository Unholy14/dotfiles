import QtQuick
import Quickshell
import Quickshell.Wayland

Item {
    // --- PANEL DE FONDOS DE PANTALLA (A la izquierda) ---
    PanelWindow {
        id: wallpaperPanel
        anchors.left: true
        anchors.top: true
        anchors.bottom: true
        width: 350
        color: "#080808"
        visible: root.wallVisible

        WlrLayershell.namespace: "wallpaperpanel"
        WlrLayershell.layer: WlrLayershell.Layer.Top

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: hideTimer.stop()
            onExited: hideTimer.restart()
        }

        Rectangle {
            anchors.right: parent.right
            width: 2
            height: parent.height
            color: "#888888"
        }

        Item {
            id: wallHeader
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 25
            height: 50

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "GALERÍA"
                color: "#888888"
                font.bold: true
                font.pixelSize: 18
                font.letterSpacing: 2
            }

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: "✖"
                color: "#ffffff"
                font.pixelSize: 18

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.wallVisible = false
                }
            }
        }

        GridView {
            anchors.top: wallHeader.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20
            clip: true
            model: wallModel
            cellWidth: 155
            cellHeight: 110

            delegate: Rectangle {
                width: 145
                height: 100
                color: "transparent"
                radius: 5
                border.color: "#333333"

                Image {
                    anchors.fill: parent
                    anchors.margins: 2
                    source: fileUrl
                    fillMode: Image.PreserveAspectCrop
                    clip: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        cmdSetWall.targetWall = filePath
                        cmdSetWall.running = false
                        cmdSetWall.running = true
                    }
                }
            }
        }
    }

    // --- PANEL DE CONTROL PRINCIPAL (A la derecha) ---
    PanelWindow {
        id: controlPanel
        anchors.right: true
        anchors.top: true
        anchors.bottom: true
        width: 350
        color: "#080808"
        visible: root.panelVisible

        WlrLayershell.namespace: "controlpanel"
        WlrLayershell.layer: WlrLayershell.Layer.Top

        Rectangle {
            anchors.left: parent.left
            width: 2
            height: parent.height
            color: "#888888"
        }

        Timer {
            id: hideTimer
            interval: 800
            repeat: false
            onTriggered: {
                root.panelVisible = false
                root.wallVisible = false
            }
        }

        MouseArea {
            id: panelMouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: hideTimer.stop()
            onExited: hideTimer.restart()
        }

        // ENCABEZADO
        Item {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 25
            height: 50

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 15

                Text {
                    text: "CONTROL"
                    color: "#888888"
                    font.bold: true
                    font.pixelSize: 18
                    font.letterSpacing: 2
                }

                Text {
                    text: "[ FONDOS ]"
                    color: "#ffffff"
                    font.pixelSize: 14
                    font.bold: true
                    font.letterSpacing: 1
                    opacity: root.wallVisible ? 1.0 : 0.5

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.wallVisible = !root.wallVisible
                            if (root.wallVisible) {
                                wallModel.clear()
                                getWalls.running = false
                                getWalls.running = true
                            }
                        }
                    }
                }
            }

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: root.currentTime
                color: "#ffffff"
                font.bold: true
                font.pixelSize: 16
            }
        }

        // --- WIDGETS ---
        Column {
            anchors.top: parent.top
            anchors.topMargin: 70
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 15
            width: 310

            // WIDGET CPU, RAM, BAT
            Rectangle {
                width: parent.width
                height: 50
                color: "#111111"
                radius: 5
                border.color: "#333333"

                Row {
                    anchors.centerIn: parent
                    spacing: 25

                    Text {
                        text: "CPU: " + root.valCPU + "%"
                        color: "#ffffff"
                        font.pixelSize: 13
                    }

                    Text {
                        text: "RAM: " + root.valRAM + "%"
                        color: "#ffffff"
                        font.pixelSize: 13
                    }

                    Text {
                        text: "BAT: " + root.valBAT + "%"
                        color: "#ffffff"
                        font.pixelSize: 13
                    }
                }
            }

            // WIDGET VOLUMEN Y BRILLO
            Rectangle {
                width: parent.width
                height: 90
                color: "#111111"
                radius: 5
                border.color: "#333333"

                Column {
                    anchors.centerIn: parent
                    spacing: 15
                    width: parent.width - 40

                    // BARRA DE VOLUMEN
                    Row {
                        spacing: 15
                        width: parent.width

                        Text {
                            text: "🔊"
                            color: "#ffffff"
                            font.pixelSize: 16
                        }

                        Rectangle {
                            height: 12
                            width: parent.width - 40
                            color: "transparent"
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                width: parent.width
                                height: 6
                                color: "#333333"
                                radius: 3
                                anchors.centerIn: parent

                                Rectangle {
                                    width: parent.width * root.volProgress
                                    height: parent.height
                                    color: "#ffffff"
                                    radius: 3
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onPositionChanged: function(mouse) {
                                    if (pressed) {
                                        var p = Math.max(0, Math.min(1, mouse.x / width))
                                        root.volProgress = p
                                        cmdSetVol.targetVol = Math.floor(p * 100).toString()
                                        cmdSetVol.running = false
                                        cmdSetVol.running = true
                                    }
                                }
                                onClicked: function(mouse) {
                                    var p = Math.max(0, Math.min(1, mouse.x / width))
                                    root.volProgress = p
                                    cmdSetVol.targetVol = Math.floor(p * 100).toString()
                                    cmdSetVol.running = false
                                    cmdSetVol.running = true
                                }
                            }
                        }
                    }

                    // BARRA DE BRILLO
                    Row {
                        spacing: 15
                        width: parent.width

                        Text {
                            text: "☀️"
                            color: "#ffffff"
                            font.pixelSize: 16
                        }

                        Rectangle {
                            height: 12
                            width: parent.width - 40
                            color: "transparent"
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                width: parent.width
                                height: 6
                                color: "#333333"
                                radius: 3
                                anchors.centerIn: parent

                                Rectangle {
                                    width: parent.width * root.briProgress
                                    height: parent.height
                                    color: "#ffffff"
                                    radius: 3
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onPositionChanged: function(mouse) {
                                    if (pressed) {
                                        var p = Math.max(0, Math.min(1, mouse.x / width))
                                        root.briProgress = p
                                        cmdSetBri.targetBri = Math.floor(p * 100).toString()
                                        cmdSetBri.running = false
                                        cmdSetBri.running = true
                                    }
                                }
                                onClicked: function(mouse) {
                                    var p = Math.max(0, Math.min(1, mouse.x / width))
                                    root.briProgress = p
                                    cmdSetBri.targetBri = Math.floor(p * 100).toString()
                                    cmdSetBri.running = false
                                    cmdSetBri.running = true
                                }
                            }
                        }
                    }
                }
            }

            // WIDGET DE MÚSICA
            Rectangle {
                width: parent.width
                height: 320
                color: "#111111"
                radius: 5
                border.color: "#333333"

                Column {
                    anchors.centerIn: parent
                    spacing: 15

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 180
                        height: 180
                        color: "#050505"
                        radius: 4
                        clip: true

                        Text {
                            anchors.centerIn: parent
                            text: "♫"
                            color: "#333333"
                            font.pixelSize: 50
                            visible: root.musicCover === ""
                        }

                        Image {
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            source: root.musicCover
                            visible: root.musicCover !== ""
                        }
                    }

                    Column {
                        spacing: 2
                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.musicTitle
                            color: "#ffffff"
                            font.pixelSize: 14
                            font.bold: true
                            width: 280
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.musicArtist
                            color: "#888888"
                            font.pixelSize: 12
                            width: 280
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                            visible: root.musicArtist !== ""
                        }
                    }

                    Row {
                        spacing: 10
                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                            text: root.musicPosStr
                            color: "#888888"
                            font.pixelSize: 11
                            width: 30
                            horizontalAlignment: Text.AlignRight
                        }

                        Rectangle {
                            width: 180
                            height: 12
                            color: "transparent"
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                width: 180
                                height: 4
                                color: "#333333"
                                radius: 2
                                anchors.centerIn: parent

                                Rectangle {
                                    width: parent.width * root.musicProgress
                                    height: parent.height
                                    color: "#ffffff"
                                    radius: 2
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: function(mouse) {
                                    if (root.musicLenSec > 0) {
                                        var percent = mouse.x / width
                                        cmdSeek.targetSec = Math.floor(percent * root.musicLenSec).toString()
                                        cmdSeek.running = false
                                        cmdSeek.running = true
                                        root.musicProgress = percent
                                    }
                                }
                            }
                        }

                        Text {
                            text: root.musicLenStr
                            color: "#888888"
                            font.pixelSize: 11
                            width: 30
                            horizontalAlignment: Text.AlignLeft
                        }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 35

                        Text {
                            text: "⏮"
                            color: "#888888"
                            font.pixelSize: 20
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    cmdPrev.running = true
                                }
                            }
                        }

                        Text {
                            text: "⏯"
                            color: "#ffffff"
                            font.pixelSize: 24
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    cmdPlay.running = true
                                }
                            }
                        }

                        Text {
                            text: "⏭"
                            color: "#888888"
                            font.pixelSize: 20
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    cmdNext.running = true
                                }
                            }
                        }
                    }
                }
            }
        }

        // --- ARTE LOGO Y LAURELES ---
        Column {
            anchors.bottom: powerButtons.top
            anchors.bottomMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            spacing: 12

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "꧁   ❖   ꧂"
                color: "#888888"
                font.pixelSize: 22
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.currentDate
                color: "#888888"
                font.pixelSize: 18
                font.letterSpacing: 4
                font.bold: true
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "« Per Aspera Ad Astra »"
                color: "#555555"
                font.pixelSize: 14
                font.italic: true
            }

            Image {
                id: logoAres
                anchors.horizontalCenter: parent.horizontalCenter
                width: 170
                height: 170
                fillMode: Image.PreserveAspectFit
                source: "file://" + Quickshell.configDir + "/logo.png"
                opacity: 0.8
            }
        }

        // --- BOTONES DE ENERGÍA ---
        Row {
            id: powerButtons
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 50

            Text {
                text: "⏾"
                color: "#888888"
                font.pixelSize: 24
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: hideTimer.stop()
                    onExited: hideTimer.restart()
                    onClicked: {
                        cmdSuspend.running = true
                    }
                }
            }

            Text {
                text: "⭮"
                color: "#888888"
                font.pixelSize: 24
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: hideTimer.stop()
                    onExited: hideTimer.restart()
                    onClicked: {
                        cmdReboot.running = true
                    }
                }
            }

            Text {
                text: "⏻"
                color: "#ffffff"
                font.pixelSize: 24
                font.bold: true
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: hideTimer.stop()
                    onExited: hideTimer.restart()
                    onClicked: {
                        cmdPoweroff.running = true
                    }
                }
            }
        }
    }
}
