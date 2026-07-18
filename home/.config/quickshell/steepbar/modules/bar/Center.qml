import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Services.Mpris
import "../../services" as Services

RowLayout {
    id: root
    spacing: 0

    readonly property MprisPlayer player: {
        const players = Mpris.players.values
        return players.find(p => p.isPlaying) ?? players[0] ?? null
    }

    // Custom Glassmorphic Music Pill (40px tall and wider)
    Rectangle {
        id: container
        implicitWidth: 320
        implicitHeight: 40
        radius: 20

        // Theme colors matching the Blue & White Mirror's Edge aesthetic
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#ffffff" }
            GradientStop { position: 1.0; color: "#f0f4f9" }
        }
        border.width: 1
        border.color: Services.Colors.glassBorder

        // Inner Bevel Highlight
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: 19
            color: "transparent"
            border.width: 1
            border.color: Services.Colors.innerBevel
        }

        // Ambient Bottom Accent Glow Line
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 24
            height: 1.5
            radius: 1
            color: Services.Colors.accent2
        }

        // 1. Large Vinyl Record Player (Left-aligned, flush to the corner)
        Rectangle {
            id: vinylRecord
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            width: 34
            height: 34
            radius: 17
            color: "#0b0c10"
            border.width: 1
            border.color: Qt.rgba(0.2, 0.35, 0.55, 0.2)

            // Force high-resolution layer buffer to prevent pixelation on High-DPI screens
            layer.enabled: true
            layer.textureSize: Qt.size(256, 256)

            // Vinyl Grooves (skeuomorphic rings)
            Rectangle {
                anchors.centerIn: parent
                width: 28
                height: 28
                radius: 14
                color: "transparent"
                border.width: 0.75
                border.color: Qt.rgba(255, 255, 255, 0.08)
            }
            Rectangle {
                anchors.centerIn: parent
                width: 22
                height: 22
                radius: 11
                color: "transparent"
                border.width: 0.75
                border.color: Qt.rgba(255, 255, 255, 0.05)
            }

            // Center Album Art Label (Enlarged and masked with OpacityMask for perfect anti-aliased roundness!)
            Item {
                id: labelWrapper
                anchors.centerIn: parent
                width: 20
                height: 20

                Image {
                    id: albumArt
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    source: (root.player && root.player.trackArtUrl)
                        ? root.player.trackArtUrl
                        : Qt.resolvedUrl("../../icons/music-placeholder.svg")
                    visible: false // Hidden because OpacityMask draws it
                    smooth: true
                    mipmap: true
                    sourceSize: Qt.size(120, 120)
                }

                Rectangle {
                    id: albumMask
                    anchors.fill: parent
                    radius: 10
                    color: "black"
                    visible: false // Hidden because OpacityMask uses it as mask
                    smooth: true
                }

                OpacityMask {
                    anchors.fill: parent
                    source: albumArt
                    maskSource: albumMask
                    smooth: true
                }
            }

            // Spindle Center Hole
            Rectangle {
                anchors.centerIn: parent
                width: 3
                height: 3
                radius: 1.5
                color: "#ffffff"
            }

            // Spin animation of the entire vinyl record
            RotationAnimation on rotation {
                from: 0
                to: 360
                duration: 6000  // Realistic rotation speed
                loops: Animation.Infinite
                running: root.player && root.player.isPlaying
            }
        }

        // 2. Track & Artist Info (Center-Left)
        ColumnLayout {
            id: trackInfo
            anchors.left: vinylRecord.right
            anchors.leftMargin: 8
            anchors.right: controlsRow.left
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: -1

            Text {
                Layout.fillWidth: true
                text: (root.player && root.player.trackTitle) ? root.player.trackTitle : "Sin reproducción"
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 12
                font.bold: true
                color: Services.Colors.fg
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: (root.player && root.player.trackArtist) ? root.player.trackArtist : "Desconocido"
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 10
                color: Services.Colors.subtext
                elide: Text.ElideRight
            }
        }

        // 3. Playback Controls (Right)
        RowLayout {
            id: controlsRow
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            // Previous Button
            Text {
                id: prevBtn
                text: "󰒮"
                font.pixelSize: 13
                color: prevHover.hovered ? Services.Colors.accent2 : Services.Colors.subtext
                Behavior on color { ColorAnimation { duration: 100 } }
                HoverHandler { id: prevHover }
                TapHandler { onTapped: root.player && root.player.canSeek && root.player.seek(-5) }
            }

            // Play/Pause Circular Button (Slightly larger, better targets)
            Rectangle {
                id: playBtn
                width: 26
                height: 26
                radius: 13
                color: playHover.hovered ? Services.Colors.accent2 : Services.Colors.accent
                border.width: 1
                border.color: Services.Colors.innerBevel
                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: (root.player && root.player.isPlaying) ? 0 : 1
                    text: (root.player && root.player.isPlaying) ? "󰏤" : "󰐊"
                    font.pixelSize: 12
                    color: "#ffffff"
                    font.bold: true
                }

                HoverHandler { id: playHover }
                TapHandler { onTapped: root.player && root.player.togglePlaying() }
            }

            // Next Button
            Text {
                id: nextBtn
                text: "󰒭"
                font.pixelSize: 13
                color: nextHover.hovered ? Services.Colors.accent2 : Services.Colors.subtext
                Behavior on color { ColorAnimation { duration: 100 } }
                HoverHandler { id: nextHover }
                TapHandler { onTapped: root.player && root.player.canSeek && root.player.seek(5) }
            }
        }
    }
}
