import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Services.Mpris
import "../../services" as Services

RowLayout {
    id: root
    spacing: 8

    readonly property MprisPlayer player: {
        const players = Mpris.players.values
        return players.find(p => p.isPlaying) ?? players[0] ?? null
    }

    // Timer to update the playback position reactively (every 500ms for smooth progress bar updates)
    Timer {
        id: positionTimer
        interval: 500
        repeat: true
        running: root.player && root.player.isPlaying
        onTriggered: {
            if (root.player) {
                root.player.positionChanged()
            }
        }
    }

    // (El reloj vive en Right.qml junto a la campana — no duplicar aquí.)

    // Custom Glassmorphic Music Pill (40px tall and wider)
    Item {
        id: container
        implicitWidth: 344
        implicitHeight: 46

        // Sombra de contacto: asienta el módulo sobre el vidrio sin contorno
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 2.5
            width: parent.width
            height: parent.height - 2
            radius: 23
            antialiasing: true
            color: Qt.rgba(0.07, 0.13, 0.24, 0.13)
        }

        // Cuerpo elevado
        Rectangle {
            id: containerBody
            width: parent.width
            height: parent.height - 1.5
            radius: 23
            antialiasing: true
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#ffffff" }
                GradientStop { position: 1.0; color: Services.Colors.cardBg }
            }
            border.width: 1
            border.color: Services.Colors.glassBorder
        }

        // Inner Bevel Highlight
        Rectangle {
            anchors.fill: containerBody
            anchors.margins: 1
            radius: 22
            color: "transparent"
            border.width: 1
            border.color: Services.Colors.innerBevel
        }

        // Glossy Reflection overlay (curved upper shine)
        Rectangle {
            anchors.fill: containerBody
            radius: 22
            clip: true
            color: "transparent"
            Rectangle {
                width: parent.width * 1.5
                height: parent.height / 1.8
                rotation: -3
                x: -10
                y: -3
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.35) }
                    GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.0) }
                }
            }
        }

        // Waving Aurora light wave (Frutiger Aero vector wave)
        ClippingRectangle {
            anchors.fill: containerBody
            radius: 23
            color: "transparent"
            opacity: (root.player && root.player.isPlaying) ? 0.28 : 0.0
            Behavior on opacity { NumberAnimation { duration: 600 } }

            Rectangle {
                id: wave
                width: parent.width * 1.5
                height: parent.height * 2
                anchors.verticalCenter: parent.verticalCenter
                x: -container.width * 0.4
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.5; color: Services.Colors.accent2 }
                    GradientStop { position: 1.0; color: "transparent" }
                }

                SequentialAnimation on x {
                    running: root.player && root.player.isPlaying
                    loops: Animation.Infinite
                    NumberAnimation { from: -container.width * 0.4; to: container.width * 0.4; duration: 4000; easing.type: Easing.InOutSine }
                    NumberAnimation { from: container.width * 0.4; to: -container.width * 0.4; duration: 4000; easing.type: Easing.InOutSine }
                }
            }
        }

        // Línea de acento inferior, dentro del cuerpo elevado
        Rectangle {
            anchors.bottom: containerBody.bottom
            anchors.bottomMargin: 1
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 28
            height: 1.5
            radius: 1
            color: Services.Colors.accent2
            opacity: 0.8
        }

        // 1. Vinyl Record — "picture disc": la carátula ocupa TODO el
        // disco, pegado al borde izquierdo del contenedor. Solo el disco
        // rota; el brillo especular es ESTÁTICO encima (Apple aqua).
        // layer.smooth + mipmap eliminan el pixelado al escalar.
        Item {
            id: vinylRecord
            anchors.left: parent.left
            anchors.leftMargin: 3
            anchors.verticalCenter: parent.verticalCenter
            width: 40
            height: 40

            // ── Contenedor de recorte ESTÁTICO (Evita el pixelado de bordes al girar) ──
            ClippingRectangle {
                anchors.fill: parent
                radius: width / 2
                antialiasing: true
                color: "#0d0f13"
                border.width: 1
                border.color: "#40454d"

                // ── Disco giratorio interno ──
                Item {
                    id: spinningDisc
                    anchors.fill: parent
                    antialiasing: true

                    RotationAnimation on rotation {
                        from: 0
                        to: 360
                        duration: 6000
                        loops: Animation.Infinite
                        running: root.player && root.player.isPlaying
                    }

                    Image {
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        source: (root.player && root.player.trackArtUrl)
                            ? root.player.trackArtUrl
                            : Qt.resolvedUrl("../../icons/music-placeholder.svg")
                        smooth: true
                        mipmap: true
                        antialiasing: true
                        sourceSize: Qt.size(128, 128)
                    }

                    // Viñeta de borde: hunde el arte hacia el canto del disco
                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        antialiasing: true
                        color: "transparent"
                        border.width: 3
                        border.color: Qt.rgba(0, 0, 0, 0.28)
                    }

                    // Surcos del vinilo sobre el arte
                    Repeater {
                        model: [36, 32, 28]
                        delegate: Rectangle {
                            required property int modelData
                            anchors.centerIn: parent
                            width: modelData
                            height: modelData
                            radius: modelData / 2
                            antialiasing: true
                            color: "transparent"
                            border.width: 1
                            border.color: Qt.rgba(0, 0, 0, 0.16)
                        }
                    }

                    // Eje central: etiqueta mínima + agujero
                    Rectangle {
                        anchors.centerIn: parent
                        width: 8
                        height: 8
                        radius: 4
                        antialiasing: true
                        color: "#10131a"
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.35)
                    }
                    Rectangle {
                        anchors.centerIn: parent
                        width: 2.5
                        height: 2.5
                        radius: 1.25
                        antialiasing: true
                        color: "#e8ecf2"
                    }
                }
            }

            // ── Capa de vidrio estática (Apple aqua: la luz no rota) ──
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 2
                width: parent.width - 10
                height: parent.height * 0.42
                radius: height / 2
                antialiasing: true
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.50) }
                    GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.02) }
                }
            }

            // Luz de borde (rim light) que sella el efecto de cristal
            Rectangle {
                anchors.fill: parent
                radius: width / 2
                antialiasing: true
                color: "transparent"
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.28)
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
                font.family: Services.Colors.uiFont
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: Services.Colors.fg
                elide: Text.ElideRight
                style: Text.Sunken
                styleColor: Qt.rgba(1, 1, 1, 0.80)
            }
            Text {
                Layout.fillWidth: true
                text: (root.player && root.player.trackArtist) ? root.player.trackArtist : "Desconocido"
                font.family: Services.Colors.uiFont
                font.pixelSize: 10
                font.weight: Font.Medium
                color: Services.Colors.subtext
                elide: Text.ElideRight
            }

            // Sleek progress bar / Seek slider (Aero Style)
            Item {
                Layout.fillWidth: true
                height: 8
                Layout.topMargin: 2
                visible: root.player && root.player.length > 0

                // Track progress line background
                Rectangle {
                    id: progressBg
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 3
                    radius: 1.5
                    color: Qt.rgba(0, 0, 0, 0.08)

                    // Progressive progress line
                    Rectangle {
                        height: parent.height
                        radius: parent.radius
                        width: parent.width * (root.player && root.player.length > 0 ? Math.max(0, Math.min(1, root.player.position / root.player.length)) : 0)
                        color: Services.Colors.accent2
                    }
                }

                // Interactive thumb that appears on hover
                Rectangle {
                    id: seekThumb
                    width: 8
                    height: 8
                    radius: 4
                    color: Services.Colors.accent
                    border.width: 1
                    border.color: "#ffffff"
                    anchors.verticalCenter: parent.verticalCenter
                    x: (parent.width - width) * (root.player && root.player.length > 0 ? Math.max(0, Math.min(1, root.player.position / root.player.length)) : 0)
                    opacity: seekHover.hovered || seekArea.pressed ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }

                // Mouse handler for seeking (tap/drag)
                MouseArea {
                    id: seekArea
                    anchors.fill: parent
                    preventStealing: true

                    HoverHandler { id: seekHover }

                    function handleSeek(mouse) {
                        if (root.player && root.player.canSeek && root.player.length > 0) {
                            let pct = Math.max(0, Math.min(1, mouse.x / width))
                            root.player.position = pct * root.player.length
                            root.player.positionChanged()
                        }
                    }

                    onPressed: mouse => handleSeek(mouse)
                    onPositionChanged: mouse => {
                        if (pressed) handleSeek(mouse)
                    }
                }
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
                font.pixelSize: 14
                color: prevHover.hovered ? Services.Colors.accent2 : Services.Colors.subtext
                Behavior on color { ColorAnimation { duration: 100 } }
                HoverHandler { id: prevHover }
                TapHandler { onTapped: root.player && root.player.canSeek && root.player.seek(-5) }
            }

            // Play/Pause — esfera glossy estilo Apple aqua: gradiente
            // vertical + destello superior estático + borde oscurecido.
            Rectangle {
                id: playBtn
                width: 28
                height: 28
                radius: 14
                antialiasing: true
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: playHover.hovered ? Qt.lighter(Services.Colors.accent2, 1.35) : Qt.lighter(Services.Colors.accent, 1.40)
                    }
                    GradientStop {
                        position: 1.0
                        color: playHover.hovered ? Services.Colors.accent2 : Services.Colors.accent
                    }
                }
                border.width: 1
                border.color: Qt.darker(Services.Colors.accent, 1.30)

                // Destello de vidrio superior
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 1.5
                    width: parent.width - 8
                    height: parent.height * 0.42
                    radius: height / 2
                    antialiasing: true
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.65) }
                        GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.05) }
                    }
                }

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
                font.pixelSize: 14
                color: nextHover.hovered ? Services.Colors.accent2 : Services.Colors.subtext
                Behavior on color { ColorAnimation { duration: 100 } }
                HoverHandler { id: nextHover }
                TapHandler { onTapped: root.player && root.player.canSeek && root.player.seek(5) }
            }
        }
    }
}
