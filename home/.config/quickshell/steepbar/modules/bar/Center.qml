import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import "../../services" as Services

RowLayout {
    id: root
    spacing: 0

    // Only the Music player widget in the center
    Pill {
        id: musicPill
        hPad: 14
        vPad: 4
        interactive: false

        readonly property MprisPlayer player: {
            const players = Mpris.players.values
            return players.find(p => p.isPlaying) ?? players[0] ?? null
        }

        Rectangle {
            width: 30
            height: 30
            radius: 15
            color: "transparent"
            border.width: 1
            border.color: Services.Colors.accent
            
            // Enforce rounded clipping of child elements
            layer.enabled: true
            
            // Force high-resolution texture buffer for layershell to prevent pixelation on high-DPI screens
            layer.textureSize: Qt.size(120, 120)

            Image {
                id: albumArt
                anchors.fill: parent
                anchors.margins: 1
                fillMode: Image.PreserveAspectCrop
                source: (musicPill.player && musicPill.player.trackArtUrl)
                    ? musicPill.player.trackArtUrl
                    : Qt.resolvedUrl("../../icons/music-placeholder.svg")
                
                // Texture filtering options for high-fidelity downscaling
                smooth: true
                mipmap: true
                sourceSize: Qt.size(120, 120)

                // Continuous slow spin when playing
                RotationAnimation on rotation {
                    from: 0
                    to: 360
                    duration: 12000
                    loops: Animation.Infinite
                    running: musicPill.player && musicPill.player.isPlaying
                }
            }
        }

        ColumnLayout {
            spacing: 0
            Layout.preferredWidth: 150

            Text {
                Layout.fillWidth: true
                text: (musicPill.player && musicPill.player.trackTitle) ? musicPill.player.trackTitle : "Sin reproducción"
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 13
                font.bold: true
                color: "#0d0f1c"
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: (musicPill.player && musicPill.player.trackArtist) ? musicPill.player.trackArtist : "Desconocido"
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 11
                color: "#50546e"
                elide: Text.ElideRight
            }
        }

        RowLayout {
            spacing: 10

            Text {
                text: "󰒮"
                font.pixelSize: 14
                color: Qt.rgba(0.314, 0.329, 0.431, 0.60)
                TapHandler { onTapped: musicPill.player && musicPill.player.canSeek && musicPill.player.seek(-5) }
            }
            Text {
                text: (musicPill.player && musicPill.player.isPlaying) ? "󰏤" : "󰐊"
                font.pixelSize: 14
                color: Services.Colors.accent
                TapHandler { onTapped: musicPill.player && musicPill.player.togglePlaying() }
            }
            Text {
                text: "󰒭"
                font.pixelSize: 14
                color: Qt.rgba(0.314, 0.329, 0.431, 0.60)
                TapHandler { onTapped: musicPill.player && musicPill.player.canSeek && musicPill.player.seek(5) }
            }
        }
    }
}
