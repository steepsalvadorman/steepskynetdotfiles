import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import "../../services" as Services

// Embedded dropdown: plain Rectangle anchored below the bar shell inside
// Bar.qml's tall layer surface (NOT a standalone window).
Rectangle {
    id: popup
    implicitWidth: 320
    implicitHeight: Math.min(contentColumn.implicitHeight + 24, 520)
    visible: Services.PopupState.audioVisible

    radius: 18
    gradient: Gradient {
        GradientStop { position: 0.0; color: "#ffffff" }
        GradientStop { position: 1.0; color: Services.Colors.cardBg }
    }
    border.width: 1
    border.color: Services.Colors.glassBorder

    // Inner Bevel Highlight
    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: 17
        color: "transparent"
        border.width: 1
        border.color: Services.Colors.innerBevel
    }

    // Glossy Reflection overlay
    Rectangle {
        anchors.fill: parent
        radius: 17
        clip: true
        color: "transparent"
        Rectangle {
            width: parent.width * 1.5
            height: 120
            rotation: -10
            x: -20
            y: -40
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.28) }
                GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.0) }
            }
        }
    }

    // Ambient Bottom Accent Glow Line
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 20
        height: 2.5
        radius: 1.5
        color: Services.Colors.accent
    }

    ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Header Title
            RowLayout {
                spacing: 8
                Text {
                    text: "󰓃"
                    font.pixelSize: 18
                    color: Services.Colors.accent
                }
                Text {
                    text: "Dispositivos de Audio"
                    font.family: Services.Colors.uiFont
                    font.pixelSize: 13
                    font.bold: true
                    color: Services.Colors.fg
                }
            }

            // --- SECTION 1: SALIDA (Sinks) ---
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: "SALIDA (ALTAVOCES / AURICULARES)"
                    font.family: Services.Colors.uiFont
                    font.pixelSize: 9
                    font.bold: true
                    color: Services.Colors.subtext
                }

                // List of outputs
                Repeater {
                    model: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream && n.audio)
                    delegate: ColumnLayout {
                        id: sinkDelegate
                        Layout.fillWidth: true
                        spacing: 2

                        // Track audio properties for this specific node
                        PwObjectTracker { objects: [modelData] }

                        readonly property bool isActive: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.id === modelData.id
                        property bool hovered: false

                        Rectangle {
                            Layout.fillWidth: true
                            height: 38
                            radius: 10
                            border.width: 1
                            border.color: sinkDelegate.isActive ? Services.Colors.accent2 : sinkDelegate.hovered ? "#a3c5f5" : "#d0dfef"
                            
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: sinkDelegate.isActive ? "#e5effa" : "#ffffff" }
                                GradientStop { position: 1.0; color: sinkDelegate.isActive ? "#d2e5fa" : "#f6f9fc" }
                            }

                            // Glossy Gel overlay reflection
                            Rectangle {
                                anchors.fill: parent
                                radius: 9
                                clip: true
                                color: "transparent"
                                Rectangle {
                                    width: parent.width * 1.5
                                    height: parent.height / 2
                                    rotation: -3
                                    x: -10
                                    y: -2
                                    gradient: Services.Colors.gelGloss
                                }
                            }

                            HoverHandler {
                                onHoveredChanged: sinkDelegate.hovered = hovered
                            }

                            TapHandler {
                                onTapped: Pipewire.preferredDefaultAudioSink = modelData
                            }

                            // Content Row
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 8

                                // Active LED Dot Indicator
                                Rectangle {
                                    width: 8; height: 8; radius: 4
                                    color: sinkDelegate.isActive ? Services.Colors.accent : "transparent"
                                    border.width: sinkDelegate.isActive ? 0 : 1
                                    border.color: "#8392a5"
                                }

                                // Speaker Icon
                                Text {
                                    text: (modelData.audio && modelData.audio.muted) ? "󰝟" : "󰕾"
                                    font.pixelSize: 14
                                    color: sinkDelegate.isActive ? Services.Colors.accent : "#2c3e50"
                                }

                                // Device Description
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.description || modelData.name
                                    font.family: Services.Colors.uiFont
                                    font.pixelSize: 10
                                    font.bold: true
                                    color: Services.Colors.fg
                                    elide: Text.ElideRight
                                }

                                // Mute Button (skeuomorphic mini-button)
                                Rectangle {
                                    width: 22; height: 22; radius: 6
                                    border.width: 1
                                    border.color: (modelData.audio && modelData.audio.muted) ? "#a3c5f5" : "#d0dfef"
                                    color: (modelData.audio && modelData.audio.muted) ? "#e5effa" : "#f6f9fc"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰝟"
                                        font.pixelSize: 10
                                        color: (modelData.audio && modelData.audio.muted) ? Services.Colors.accent : Services.Colors.subtext
                                    }

                                    TapHandler {
                                        onTapped: if (modelData.audio) modelData.audio.muted = !modelData.audio.muted
                                    }
                                }
                            }
                        }

                        // Volume Slider (only if active/selected)
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.leftMargin: 12
                            Layout.rightMargin: 12
                            visible: sinkDelegate.isActive
                            spacing: 8

                            Text {
                                text: modelData.audio ? Math.round(modelData.audio.volume * 100) + "%" : "0%"
                                font.family: Services.Colors.uiFont
                                font.pixelSize: 9
                                font.bold: true
                                color: Services.Colors.subtext
                                Layout.preferredWidth: 26
                            }

                            // Slider track
                            Rectangle {
                                id: sliderTrack
                                Layout.fillWidth: true
                                height: 5
                                radius: 2.5
                                color: "#d6e3f2"

                                Rectangle {
                                    width: parent.width * (modelData.audio ? Math.min(modelData.audio.volume, 1.0) : 0)
                                    height: parent.height
                                    radius: 2.5
                                    color: Services.Colors.accent2
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onPositionChanged: if (pressed) updateVol(mouseX)
                                    onPressed: updateVol(mouseX)
                                    function updateVol(mx) {
                                        const ratio = Math.max(0, Math.min(1, mx / width))
                                        if (modelData.audio) modelData.audio.volume = ratio
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // --- SECTION 2: ENTRADA (Sources) ---
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                Layout.topMargin: 4

                Text {
                    text: "ENTRADA (MICRÓFONOS)"
                    font.family: Services.Colors.uiFont
                    font.pixelSize: 9
                    font.bold: true
                    color: Services.Colors.subtext
                }

                // List of inputs
                Repeater {
                    model: Pipewire.nodes.values.filter(n => !n.isSink && !n.isStream && n.audio)
                    delegate: ColumnLayout {
                        id: sourceDelegate
                        Layout.fillWidth: true
                        spacing: 2

                        // Track audio properties for this specific node
                        PwObjectTracker { objects: [modelData] }

                        readonly property bool isActive: Pipewire.defaultAudioSource && Pipewire.defaultAudioSource.id === modelData.id
                        property bool hovered: false

                        Rectangle {
                            Layout.fillWidth: true
                            height: 38
                            radius: 10
                            border.width: 1
                            border.color: sourceDelegate.isActive ? Services.Colors.accent2 : sourceDelegate.hovered ? "#a3c5f5" : "#d0dfef"
                            
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: sourceDelegate.isActive ? "#e5effa" : "#ffffff" }
                                GradientStop { position: 1.0; color: sourceDelegate.isActive ? "#d2e5fa" : "#f6f9fc" }
                            }

                            // Glossy Gel overlay reflection
                            Rectangle {
                                anchors.fill: parent
                                radius: 9
                                clip: true
                                color: "transparent"
                                Rectangle {
                                    width: parent.width * 1.5
                                    height: parent.height / 2
                                    rotation: -3
                                    x: -10
                                    y: -2
                                    gradient: Services.Colors.gelGloss
                                }
                            }

                            HoverHandler {
                                onHoveredChanged: sourceDelegate.hovered = hovered
                            }

                            TapHandler {
                                onTapped: Pipewire.preferredDefaultAudioSource = modelData
                            }

                            // Content Row
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 8

                                // Active LED Dot Indicator
                                Rectangle {
                                    width: 8; height: 8; radius: 4
                                    color: sourceDelegate.isActive ? Services.Colors.accent : "transparent"
                                    border.width: sourceDelegate.isActive ? 0 : 1
                                    border.color: "#8392a5"
                                }

                                // Microphone Icon
                                Text {
                                    text: (modelData.audio && modelData.audio.muted) ? "󰍭" : "󰍬"
                                    font.pixelSize: 14
                                    color: sourceDelegate.isActive ? Services.Colors.accent : "#2c3e50"
                                }

                                // Device Description
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.description || modelData.name
                                    font.family: Services.Colors.uiFont
                                    font.pixelSize: 10
                                    font.bold: true
                                    color: Services.Colors.fg
                                    elide: Text.ElideRight
                                }

                                // Mute Button (mic toggle)
                                Rectangle {
                                    width: 22; height: 22; radius: 6
                                    border.width: 1
                                    border.color: (modelData.audio && modelData.audio.muted) ? "#a3c5f5" : "#d0dfef"
                                    color: (modelData.audio && modelData.audio.muted) ? "#e5effa" : "#f6f9fc"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰍭"
                                        font.pixelSize: 10
                                        color: (modelData.audio && modelData.audio.muted) ? Services.Colors.accent : Services.Colors.subtext
                                    }

                                    TapHandler {
                                        onTapped: if (modelData.audio) modelData.audio.muted = !modelData.audio.muted
                                    }
                                }
                            }
                        }

                        // Volume Slider (only if active/selected)
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.leftMargin: 12
                            Layout.rightMargin: 12
                            visible: sourceDelegate.isActive
                            spacing: 8

                            Text {
                                text: modelData.audio ? Math.round(modelData.audio.volume * 100) + "%" : "0%"
                                font.family: Services.Colors.uiFont
                                font.pixelSize: 9
                                font.bold: true
                                color: Services.Colors.subtext
                                Layout.preferredWidth: 26
                            }

                            // Slider track
                            Rectangle {
                                id: inputSliderTrack
                                Layout.fillWidth: true
                                height: 5
                                radius: 2.5
                                color: "#d6e3f2"

                                Rectangle {
                                    width: parent.width * (modelData.audio ? Math.min(modelData.audio.volume, 1.0) : 0)
                                    height: parent.height
                                    radius: 2.5
                                    color: Services.Colors.accent2
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onPositionChanged: if (pressed) updateVol(mouseX)
                                    onPressed: updateVol(mouseX)
                                    function updateVol(mx) {
                                        const ratio = Math.max(0, Math.min(1, mx / width))
                                        if (modelData.audio) modelData.audio.volume = ratio
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
