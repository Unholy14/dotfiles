import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    
    // --- VARIABLES DE ESTADO Y VISIBILIDAD ---
    property bool panelVisible: false
    property bool wallVisible: false
    property string currentTime: "00:00:00"
    property string currentDate: "00 . 00 . 0000"

    // --- VARIABLES DE SISTEMA ---
    property string valCPU: "--"
    property string valRAM: "--"
    property string valBAT: "--"
    property real volProgress: 0.5
    property real briProgress: 0.5
    property int activeWs: 1
    property bool wifiOn: false
    property bool btOn: false

    // --- VARIABLES DE MÚSICA ---
    property string musicTitle: "Sin reproducción"
    property string musicArtist: ""
    property string musicCover: ""
    property string musicPosStr: "0:00"
    property string musicLenStr: "0:00"
    property real musicProgress: 0.0
    property real musicLenSec: 0.0
    property bool draggingMusic: false
    property real dragMusicProgress: 0.0

    // --- COMANDOS AL HACER CLIC ---
    Process {
        id: cmdSuspend
        command: ["systemctl", "suspend"]
    }
    Process {
        id: cmdReboot
        command: ["systemctl", "reboot"]
    }
    Process {
        id: cmdPoweroff
        command: ["systemctl", "poweroff"]
    }
    Process {
        id: cmdPrev
        command: ["playerctl", "previous"]
    }
    Process {
        id: cmdPlay
        command: ["playerctl", "play-pause"]
    }
    Process {
        id: cmdNext
        command: ["playerctl", "next"]
    }
    Process {
        id: cmdOpenWifi
        command: ["nm-connection-editor"]
    }
    Process {
        id: cmdOpenBt
        command: ["blueman-manager"]
    }
    Process {
        id: cmdLyrics
        command: ["kitty", "--hold", "-e", "sptlrx"]
    }
    Process {
        id: cmdEq
        command: ["easyeffects"]
    }
    Process {
        id: cmdMixer
        command: ["pavucontrol"]
    }
    Process {
        id: cmdSeek
        property string targetSec: "0"
        command: ["playerctl", "position", targetSec]
    }
    Process {
        id: cmdSetVol
        property string targetVol: "50"
        command: ["bash", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + targetVol + "% 2>/dev/null || amixer sset Master " + targetVol + "%"]
    }
    Process {
        id: cmdSetBri
        property string targetBri: "50"
        command: ["bash", "-c", "brightnessctl set " + targetBri + "%"]
    }
    Process {
        id: cmdSetWall
        property string targetWall: ""
        command: ["waypaper", "--wallpaper", targetWall]
    }

    // --- CARGADOR DE FONDOS ---
    ListModel {
        id: wallModel
    }
    Process {
        id: getWalls
        command: ["bash", "-c", "ls -1 $HOME/Pictures/wallpapers/*.{jpg,jpeg,png,webp} 2>/dev/null"]
        stdout: SplitParser {
            onRead: function(data) {
                var path = String(data).trim()
                if (path !== "") {
                    wallModel.append({"filePath": path, "fileUrl": "file://" + path})
                }
            }
        }
    }

    // --- LECTORES DE DATOS ---
    Process {
        id: pWorkspace
        command: ["bash", "-c", "hyprctl activeworkspace -j 2>/dev/null | grep -o '\"id\": [0-9]*' | grep -o '[0-9]*' || echo 1"]
        stdout: SplitParser {
            onRead: function(data) {
                var val = parseInt(String(data).trim())
                if (!isNaN(val)) {
                    root.activeWs = val
                }
            }
        }
    }
    Process {
        id: pNet
        command: ["bash", "-c", "cat /sys/class/net/wl*/operstate 2>/dev/null | grep -q 'up' && echo 1 || echo 0"]
        stdout: SplitParser {
            onRead: function(data) {
                root.wifiOn = (String(data).trim() === "1")
            }
        }
    }
    Process {
        id: pBt
        command: ["bash", "-c", "bluetoothctl show 2>/dev/null | grep -q 'Powered: yes' && echo 1 || echo 0"]
        stdout: SplitParser {
            onRead: function(data) {
                root.btOn = (String(data).trim() === "1")
            }
        }
    }
    Process {
        id: pCpu
        command: ["bash", "-c", "grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print int(usage)}'"]
        stdout: SplitParser {
            onRead: function(data) {
                var val = String(data).replace(/[^0-9]/g, "")
                if (val !== "") {
                    root.valCPU = val
                }
            }
        }
    }
    Process {
        id: pRam
        command: ["bash", "-c", "free | awk '/Mem:/ {print int($3/$2*100)}'"]
        stdout: SplitParser {
            onRead: function(data) {
                var val = String(data).replace(/[^0-9]/g, "")
                if (val !== "") {
                    root.valRAM = val
                }
            }
        }
    }
    Process {
        id: pBat
        command: ["bash", "-c", "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null || echo 100"]
        stdout: SplitParser {
            onRead: function(data) {
                var val = String(data).replace(/[^0-9]/g, "")
                if (val !== "") {
                    root.valBAT = val
                }
            }
        }
    }
    Process {
        id: pVol
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{print int($2*100)}' || amixer sget Master 2>/dev/null | awk -F\"[][]\" '/Left:/ {print $2}' | tr -d '%' || echo 50"]
        stdout: SplitParser {
            onRead: function(data) {
                var val = parseFloat(String(data).trim())
                if (!isNaN(val)) {
                    root.volProgress = val / 100.0
                }
            }
        }
    }
    Process {
        id: pBri
        command: ["bash", "-c", "brightnessctl -m 2>/dev/null | awk -F, '{print substr($4, 1, length($4)-1)}' || echo 50"]
        stdout: SplitParser {
            onRead: function(data) {
                var val = parseFloat(String(data).trim())
                if (!isNaN(val)) {
                    root.briProgress = val / 100.0
                }
            }
        }
    }
    Process {
        id: pMusicTitle
        command: ["bash", "-c", "playerctl metadata --format '{{title}}' 2>/dev/null || echo 'Sin reproducción'"]
        stdout: SplitParser {
            onRead: function(data) {
                root.musicTitle = String(data).trim()
            }
        }
    }
    Process {
        id: pMusicArtist
        command: ["bash", "-c", "playerctl metadata --format '{{artist}}' 2>/dev/null || echo ''"]
        stdout: SplitParser {
            onRead: function(data) {
                root.musicArtist = String(data).trim()
            }
        }
    }
    Process {
        id: pMusicCover
        command: ["bash", "-c", "~/.config/eww/get_cover.sh"]
        stdout: SplitParser {
            onRead: function(data) {
                var path = String(data).trim()
                if (path !== "" && path !== "null") {
                    root.musicCover = "file://" + path + "?t=" + new Date().getTime()
                } else {
                    root.musicCover = ""
                }
            }
        }
    }
    Process {
        id: pMusicProgress
        command: ["bash", "-c", "echo \"$(playerctl position 2>/dev/null || echo 0) $(playerctl metadata mpris:length 2>/dev/null || echo 0)\""]
        stdout: SplitParser {
            onRead: function(data) {
                var parts = String(data).trim().replace(/\s+/g, " ").split(" ")
                if (parts.length >= 2) {
                    var posSec = parseFloat(parts[0])
                    var lenSec = parseFloat(parts[1]) / 1000000 
                    root.musicLenSec = lenSec
                    if (isNaN(posSec) || isNaN(lenSec) || lenSec <= 0) {
                        root.musicPosStr = "0:00"
                        root.musicLenStr = "0:00"
                        root.musicProgress = 0
                        return
                    }
                    var prog = posSec / lenSec
                    if (!root.draggingMusic) {
                        root.musicProgress = prog > 1 ? 1 : (prog < 0 ? 0 : prog)
                    }
                    root.musicPosStr = Math.floor(posSec / 60) + ":" + Math.floor(posSec % 60).toString().padStart(2, '0')
                    root.musicLenStr = Math.floor(lenSec / 60) + ":" + Math.floor(lenSec % 60).toString().padStart(2, '0')
                }
            }
        }
    }

    // --- TEMPORIZADORES ---
    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            pWorkspace.running = false
            pWorkspace.running = true
        }
    }
    
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var date = new Date()
            root.currentTime = date.toLocaleTimeString(Qt.locale(), "hh:mm:ss")
            root.currentDate = date.getDate().toString().padStart(2, '0') + " . " + (date.getMonth() + 1).toString().padStart(2, '0') + " . " + date.getFullYear()
            pMusicProgress.running = false
            pMusicProgress.running = true
        }
    }
    
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            pCpu.running = false
            pCpu.running = true
            pRam.running = false
            pRam.running = true
            pBat.running = false
            pBat.running = true
            pVol.running = false
            pVol.running = true
            pBri.running = false
            pBri.running = true
            pNet.running = false
            pNet.running = true
            pBt.running = false
            pBt.running = true
            pMusicTitle.running = false
            pMusicTitle.running = true
            pMusicArtist.running = false
            pMusicArtist.running = true
            pMusicCover.running = false
            pMusicCover.running = true
        }
    }

    Component.onCompleted: {
        pWorkspace.running = true
        pNet.running = true
        pBt.running = true
        pCpu.running = true
        pRam.running = true
        pBat.running = true
        pVol.running = true
        pBri.running = true
        pMusicTitle.running = true
        pMusicArtist.running = true
        pMusicCover.running = true
        pMusicProgress.running = true
        getWalls.running = true
    }

    // ==========================================
    // LLAMADA A LOS DEMÁS ARCHIVOS .QML
    // ==========================================
    
    PanelSuperior {}
    PanelControl {}

    // El gatillo invisible
    PanelWindow {
        id: hotEdge
        anchors.right: true
        anchors.top: true
        anchors.bottom: true
        color: "transparent"
        width: 1

        WlrLayershell.namespace: "hotedge"
        WlrLayershell.layer: WlrLayershell.Layer.Overlay

        Item {
            anchors.fill: parent
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                enabled: !root.panelVisible
                onEntered: {
                    root.panelVisible = true
                }
            }
        }
    }
}
