import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../../services" as Services

RowLayout {
    id: root
    spacing: 8

    // App Launcher Toggle Button (Circular White Orb)
    Item {
        id: launcherBtn
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
            visible: true
        }

        IconOrb {
            id: launcherOrb
            anchors.fill: parent
            tint: pressHandler.pressed ? Qt.darker("#ffffff", 1.08)
                : hoverHandler.hovered ? Qt.lighter("#ffffff", 1.04)
                : "#ffffff"
            scale: pressHandler.pressed ? 0.94 : (hoverHandler.hovered ? 1.04 : 1.0)
            Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }

            Image {
                anchors.centerIn: parent
                source: Qt.resolvedUrl("../../icons/archlinux.svg")
                width: 16
                height: 16
                sourceSize: Qt.size(16, 16)
                opacity: 0.95
            }
        }

        HoverHandler { id: hoverHandler }
        TapHandler {
            id: pressHandler
            onTapped: Services.PopupState.toggleLauncher()
        }
    }

    // Workspaces List
    RowLayout {
        spacing: 4

        Repeater {
            model: [1, 2, 3, 4, 5]

            delegate: Item {
                id: wsBtn
                required property int modelData
                readonly property bool active: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData
                readonly property bool occupied: Hyprland.workspaces.values.some(w => w.id === modelData)

                width: 30
                height: 30

                // Sombra de contacto (solo bajo esferas materializadas)
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 2
                    width: parent.width
                    height: parent.height - 1
                    radius: 999
                    antialiasing: true
                    color: Qt.rgba(0.07, 0.13, 0.24, 0.14)
                    visible: wsBtn.active || wsBtn.occupied
                }

                // Esfera sin contorno: volumen por gradiente de tres paradas
                Rectangle {
                    id: btnBase
                    width: parent.width
                    height: parent.height - 1
                    radius: 999
                    antialiasing: true

                    scale: wsPress.pressed ? 0.94 : (wsHover.hovered ? 1.04 : 1.0)
                    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }

                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: wsBtn.active ? Qt.lighter(Services.Colors.accent, 1.35) : wsBtn.occupied ? "#ffffff" : "transparent"
                        }
                        GradientStop {
                            position: 0.55
                            color: wsBtn.active ? Services.Colors.accent : wsBtn.occupied ? "#f4f7fb" : "transparent"
                        }
                        GradientStop {
                            position: 1.0
                            color: wsBtn.active ? Qt.darker(Services.Colors.accent, 1.20) : wsBtn.occupied ? "#e8eef6" : "transparent"
                        }
                    }

                    // Tapa de vidrio (solo esferas visibles)
                    Rectangle {
                        visible: wsBtn.active || wsBtn.occupied
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 1
                        width: parent.width - 8
                        height: parent.height * 0.46
                        radius: height / 2
                        antialiasing: true
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.65) }
                            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.04) }
                        }
                    }

                    // Reflejo secundario inferior (brillo de rebote ambiental Frutiger Aero)
                    Rectangle {
                        visible: wsBtn.active || wsBtn.occupied
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        width: parent.width - 10
                        height: parent.height * 0.16
                        radius: height / 2
                        antialiasing: true
                        color: Qt.rgba(1, 1, 1, 0.20)
                    }

                    Text {
                        anchors.centerIn: parent
                        text: wsBtn.modelData
                        font.family: Services.Colors.uiFont
                        font.pixelSize: 12
                        font.bold: true
                        color: wsBtn.active ? "#ffffff" : wsBtn.occupied ? Services.Colors.fg : Qt.rgba(0.298, 0.388, 0.522, 0.4)
                        // Relieve: número en alto sobre esfera activa, grabado en el resto
                        style: wsBtn.active ? Text.Raised : Text.Sunken
                        styleColor: wsBtn.active ? Qt.darker(Services.Colors.accent, 1.5) : Qt.rgba(1, 1, 1, 0.85)
                    }

                    HoverHandler { id: wsHover }
                    TapHandler {
                        id: wsPress
                        // Using CachyOS's Lua-based hyprland dispatcher syntax as per existing codebase logic
                        onTapped: Hyprland.dispatch("hl.dsp.focus({workspace = " + wsBtn.modelData + "})")
                    }
                }
            }
        }
    }
}

