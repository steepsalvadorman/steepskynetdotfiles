import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../../services" as Services

RowLayout {
    id: root
    spacing: 8

    readonly property string scriptsDir: Quickshell.env("HOME") + "/.config/quickshell/steepbar/scripts"

    // Timer & Date properties for the clock
    property date now: new Date()
    Timer { interval: 30000; running: true; repeat: true; triggeredOnStart: true; onTriggered: root.now = new Date() }

    // ── Sysinfo (Estadísticas de CPU, RAM, GPU, Temperaturas) ──────
    Pill {
        id: sysPill
        hPad: 12
        vPad: 4
        interactive: false
        spacing: 12

        property string cpu: "0"
        property string cpuTemp: "0"
        property string ram: "0"
        property string gpu: "0"
        property string gpuTemp: "0"

        Process {
            id: sysProc
            command: [root.scriptsDir + "/sysinfo", "--all"]
            stdout: StdioCollector { id: sysOut }
            onExited: {
                const p = sysOut.text.trim().split("|")
                if (p.length === 5) {
                    sysPill.cpu = p[0]; sysPill.cpuTemp = p[1]; sysPill.ram = p[2]
                    sysPill.gpu = p[3]; sysPill.gpuTemp = p[4]
                }
            }
        }
        Timer { interval: 3000; running: true; repeat: true; triggeredOnStart: true; onTriggered: sysProc.running = true }

        // CPU
        RowLayout {
            spacing: 4
            Image { source: Qt.resolvedUrl("../../icons/cpu.svg"); width: 15; height: 15; sourceSize: Qt.size(15, 15) }
            Text { text: sysPill.cpu + "%"; font.pixelSize: 11; font.bold: true; color: Services.Colors.fg }
        }
        // CPU Temp
        RowLayout {
            spacing: 4
            Image { source: Qt.resolvedUrl("../../icons/temp.svg"); width: 13; height: 13; sourceSize: Qt.size(13, 13) }
            Text { text: sysPill.cpuTemp + "°"; font.pixelSize: 11; font.bold: true; color: Services.Colors.accent }
        }
        // RAM
        RowLayout {
            spacing: 4
            Image { source: Qt.resolvedUrl("../../icons/ram.svg"); width: 15; height: 15; sourceSize: Qt.size(15, 15) }
            Text { text: sysPill.ram + "%"; font.pixelSize: 11; font.bold: true; color: Services.Colors.fg }
        }
        // GPU
        RowLayout {
            spacing: 4
            Image { source: Qt.resolvedUrl("../../icons/gpu.svg"); width: 15; height: 15; sourceSize: Qt.size(15, 15) }
            Text { text: sysPill.gpu + "%"; font.pixelSize: 11; font.bold: true; color: Services.Colors.fg }
        }
        // GPU Temp
        RowLayout {
            spacing: 4
            Image { source: Qt.resolvedUrl("../../icons/temp-gpu.svg"); width: 13; height: 13; sourceSize: Qt.size(13, 13) }
            Text { text: sysPill.gpuTemp + "°"; font.pixelSize: 11; font.bold: true; color: Services.Colors.accent2 }
        }
    }

    // ── Volume & Audio Devices (Salida y Entrada) ──────────
    Pill {
        id: volPill
        hPad: 12
        vPad: 4
        interactive: true
        onClicked: Services.PopupState.toggleAudio()

        PwObjectTracker { objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : [] }
        readonly property var sink: Pipewire.defaultAudioSink
        readonly property real volPct: (sink && sink.audio) ? sink.audio.volume * 100 : 0
        readonly property bool muted: (sink && sink.audio) ? sink.audio.muted : false

        PwObjectTracker { objects: Pipewire.defaultAudioSource ? [Pipewire.defaultAudioSource] : [] }
        readonly property var source: Pipewire.defaultAudioSource
        readonly property bool sourceMuted: (source && source.audio) ? source.audio.muted : true

        // Output Status (Speaker)
        Text {
            text: volPill.muted ? "󰝟" : volPill.volPct < 30 ? "󰕿" : volPill.volPct < 70 ? "󰖀" : "󰕾"
            font.pixelSize: 15
            color: volPill.muted ? Services.Colors.danger : Services.Colors.fg
        }
        
        Text {
            text: volPill.muted ? "Muted" : Math.round(volPill.volPct) + "%"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11
            font.bold: true
            color: Services.Colors.fg
        }

        // Separator
        Text {
            text: "|"
            font.pixelSize: 11
            color: Services.Colors.glassBorder
        }

        // Input Status (Microphone)
        Text {
            text: volPill.sourceMuted ? "󰍭" : "󰍬"
            font.pixelSize: 15
            color: volPill.sourceMuted ? Services.Colors.danger : Services.Colors.accent
        }
    }

    // ── Red (Network Status) ──────────────────────────────
    Pill {
        id: netPill
        hPad: 12
        vPad: 4
        interactive: false
        
        property string netType: "disconnected"
        property string ssid: "Offline"
        property string signalStrength: "0"

        Process {
            id: netProc
            command: [root.scriptsDir + "/network_status"]
            stdout: StdioCollector { id: netOut }
            onExited: {
                const parts = netOut.text.trim().split("|")
                if (parts.length === 3) {
                    netPill.netType = parts[0]
                    netPill.ssid = parts[1]
                    netPill.signalStrength = parts[2]
                }
            }
        }
        Timer { interval: 5000; running: true; repeat: true; triggeredOnStart: true; onTriggered: netProc.running = true }

        // Icon based on type
        Text {
            text: netPill.netType === "wifi" ? "󰖩" : netPill.netType === "ethernet" ? "󰈀" : "󰖪"
            font.pixelSize: 15
            color: netPill.netType === "disconnected" ? Services.Colors.danger : Services.Colors.fg
        }
        
        Text {
            text: netPill.ssid
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11
            font.bold: true
            color: Services.Colors.fg
        }
    }

    // ── Clock (Reloj y Fecha en el lado derecho) ────────────────────────
    Pill {
        id: clockPill
        hPad: 14
        vPad: 4
        interactive: false

        Text {
            text: Qt.formatDateTime(root.now, "HH:mm")
            font.family: "JetBrainsMono Nerd Font Mono"
            font.pixelSize: 13
            font.bold: true
            color: Services.Colors.fg
        }
        Text {
            text: "·"
            font.family: "JetBrainsMono Nerd Font Mono"
            font.pixelSize: 12
            color: Services.Colors.accent
        }
        Text {
            text: Qt.formatDateTime(root.now, "ddd d MMM")
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11
            color: Services.Colors.subtext
        }
    }

    // ── Notifications (Bell icon & counter) ─────────────────────────────────
    Pill {
        id: notifPill
        hPad: 12
        vPad: 4
        onClicked: Services.PopupState.toggleNotifCenter()

        readonly property int count: Services.Notifications.history ? Services.Notifications.history.values.length : 0
        readonly property color tint: count > 5 ? Services.Colors.danger : count > 0 ? Services.Colors.warning : Services.Colors.fg

        Text { text: "󰂚"; font.pixelSize: 15; color: notifPill.tint }
        Text { visible: notifPill.count > 0; text: notifPill.count; font.pixelSize: 11; font.bold: true; color: notifPill.tint }
    }
}
