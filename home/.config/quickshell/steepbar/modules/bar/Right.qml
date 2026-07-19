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

    // ── Estadísticas: Orbe de salud del sistema interactivo ────────
    property alias sysPillX: sysPill.x
    property alias sysPillWidth: sysPill.width
    Pill {
        id: sysPill
        hPad: 12
        vPad: 4
        interactive: true
        spacing: 8
        onClicked: Services.PopupState.toggleSystem()

        readonly property real maxUsage: Math.max(Services.SysStats.cpu, Services.SysStats.ram, Services.SysStats.gpu)
        readonly property string health: Services.SysStats.health

        readonly property color healthColor: health === "critical" ? Services.Colors.danger
                                            : health === "elevated" ? Services.Colors.warning
                                            : Services.Colors.success

        IconOrb {
            id: sysOrb
            glyph: "󰓅"
            tint: sysPill.healthColor
            colored: true
            glyphColor: "#ffffff"

            // Efecto de respiración sutil en estado crítico/elevado
            SequentialAnimation on scale {
                running: sysPill.health !== "normal"
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 1.08; duration: 900; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 1.08; to: 1.0; duration: 900; easing.type: Easing.InOutQuad }
            }
        }

        Text {
            text: Math.round(sysPill.maxUsage) + "%"
            font.family: Services.Colors.uiFont
            font.pixelSize: 12
            font.weight: Font.Bold
            color: Services.Colors.fg
            style: Text.Sunken
            styleColor: Qt.rgba(1, 1, 1, 0.85)
        }
    }

    // ── Volumen y dispositivos de audio ────────────────────
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

        // La rueda del mouse sobre la píldora ajusta el volumen de salida
        WheelHandler {
            onWheel: event => {
                if (volPill.sink && volPill.sink.audio) {
                    const delta = event.angleDelta.y > 0 ? 0.03 : -0.03
                    volPill.sink.audio.volume = Math.max(0, Math.min(1, volPill.sink.audio.volume + delta))
                }
            }
        }

        // Orbe altavoz: caramelo azul activo, plateado con glifo rojo si mute
        IconOrb {
            glyph: volPill.muted ? "󰝟" : volPill.volPct < 30 ? "󰕿" : volPill.volPct < 70 ? "󰖀" : "󰕾"
            tint: volPill.muted ? "#f5f8fc" : Services.Colors.accent
            colored: !volPill.muted
            glyphColor: volPill.muted ? Services.Colors.danger : "#ffffff"

            TapHandler {
                onTapped: {
                    if (volPill.sink && volPill.sink.audio) {
                        volPill.sink.audio.muted = !volPill.sink.audio.muted
                    }
                }
            }
        }

        Text {
            text: volPill.muted ? "Mute" : Math.round(volPill.volPct) + "%"
            font.family: Services.Colors.uiFont
            font.pixelSize: 12
            font.weight: Font.Bold
            color: Services.Colors.fg
            style: Text.Sunken
            styleColor: Qt.rgba(1, 1, 1, 0.85)
        }

        Rectangle {
            width: 1; height: 20
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: Qt.rgba(0.45, 0.55, 0.70, 0.45) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        // Orbe micrófono
        IconOrb {
            glyph: volPill.sourceMuted ? "󰍭" : "󰍬"
            tint: volPill.sourceMuted ? "#f5f8fc" : Services.Colors.accent2
            colored: !volPill.sourceMuted
            glyphColor: volPill.sourceMuted ? Services.Colors.danger : "#ffffff"

            TapHandler {
                onTapped: {
                    if (volPill.source && volPill.source.audio) {
                        volPill.source.audio.muted = !volPill.source.audio.muted
                    }
                }
            }
        }
    }



    // ── Reloj ──────────────────────────────────────────────
    Pill {
        id: clockPill
        hPad: 14
        vPad: 4
        interactive: false

        Text {
            text: Qt.formatDateTime(root.now, "HH:mm")
            font.family: Services.Colors.uiFont
            font.pixelSize: 16
            font.weight: Font.Bold
            color: Services.Colors.fg
            style: Text.Sunken
            styleColor: Qt.rgba(1, 1, 1, 0.85)
        }
        Rectangle {
            width: 4; height: 4; radius: 2
            color: Services.Colors.accent
            border.width: 1
            border.color: Qt.darker(Services.Colors.accent, 1.3)
        }
        Text {
            text: Qt.formatDateTime(root.now, "ddd d MMM")
            font.family: Services.Colors.uiFont
            font.pixelSize: 12
            font.weight: Font.DemiBold
            color: Services.Colors.subtext
            style: Text.Sunken
            styleColor: Qt.rgba(1, 1, 1, 0.85)
        }
    }

    // ── Notificaciones: Botón Circular Orbe ─────────────────
    Item {
        id: notifButton
        width: 30
        height: 30

        readonly property int count: Services.Notifications.history ? Services.Notifications.history.values.length : 0

        // Sombra de contacto
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 2
            width: parent.width
            height: parent.height - 1
            radius: 999
            antialiasing: true
            color: Qt.rgba(0.07, 0.13, 0.24, 0.14)
            visible: true
        }

        IconOrb {
            id: notifOrb
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            glyph: "󰂚"
            glyphSize: 14
            tint: pressHandler.pressed ? Qt.darker("#f5f8fc", 1.08)
                : hoverHandler.hovered ? Qt.lighter("#f5f8fc", 1.04)
                : "#f5f8fc"
            scale: pressHandler.pressed ? 0.94 : (hoverHandler.hovered ? 1.04 : 1.0)
            Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }
        }

        // Badge rojo de notificaciones estilo macOS
        Rectangle {
            visible: notifButton.count > 0
            anchors.right: parent.right
            anchors.rightMargin: -2
            anchors.top: parent.top
            anchors.topMargin: -2
            width: Math.max(14, badgeText.implicitWidth + 7)
            height: 14
            radius: 7
            antialiasing: true
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#ff6f68" }
                GradientStop { position: 1.0; color: "#d93025" }
            }
            border.width: 1
            border.color: "#ffffff"

            Text {
                id: badgeText
                anchors.centerIn: parent
                text: notifButton.count > 99 ? "99+" : notifButton.count
                font.family: Services.Colors.uiFont
                font.pixelSize: 9
                font.weight: Font.Bold
                color: "#ffffff"
            }
        }

        HoverHandler { id: hoverHandler }
        TapHandler {
            id: pressHandler
            onTapped: Services.PopupState.toggleNotifCenter()
        }
    }

    // ── Apagado/Power: Botón Circular Orbe ──────────────────
    Item {
        id: powerButton
        width: 30
        height: 30

        // Sombra de contacto
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 2
            width: parent.width
            height: parent.height - 1
            radius: 999
            antialiasing: true
            color: Qt.rgba(0.07, 0.13, 0.24, 0.14)
        }

        IconOrb {
            id: powerOrb
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            glyph: "󰐥"
            glyphSize: 14
            tint: powerPressHandler.pressed ? Qt.darker(Services.Colors.danger, 1.1)
                : powerHoverHandler.hovered ? Qt.lighter(Services.Colors.danger, 1.1)
                : Services.Colors.danger
            colored: true
            glyphColor: "#ffffff"
            scale: powerPressHandler.pressed ? 0.94 : (powerHoverHandler.hovered ? 1.04 : 1.0)
            Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }
        }

        HoverHandler { id: powerHoverHandler }
        TapHandler {
            id: powerPressHandler
            onTapped: Quickshell.execDetached(["wlogout", "-b", "6", "-T", "600", "-B", "600", "-L", "800", "-R", "800"])
        }
    }
}

