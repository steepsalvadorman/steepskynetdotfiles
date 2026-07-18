import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../../services" as Services

RowLayout {
    id: root
    spacing: 8

    // App Launcher Toggle Button (Skeuomorphic White Pill)
    Pill {
        hPad: 8
        vPad: 4
        onClicked: Services.PopupState.toggleLauncher()

        Image {
            source: Qt.resolvedUrl("../../icons/archlinux.svg")
            width: 20
            height: 20
            sourceSize: Qt.size(20, 20)
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

                width: 26
                height: 26

                // Ambient shadow for depth
                Rectangle {
                    anchors.fill: parent
                    anchors.topMargin: 1.5
                    radius: 999
                    color: "transparent"
                    border.width: 1
                    border.color: wsBtn.active ? Qt.rgba(0, 0, 0, 0.12) : wsBtn.occupied ? Qt.rgba(0, 0, 0, 0.06) : "transparent"
                }

                // Raised Button Base
                Rectangle {
                    id: btnBase
                    width: parent.width
                    height: parent.height - 1
                    y: wsBtn.active ? 1.0 : wsBtn.occupied ? 0.0 : 0.8
                    radius: 999

                    // Smooth transition on hover/active states
                    Behavior on y { NumberAnimation { duration: 60 } }

                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: wsBtn.active ? "#ffffff" : wsBtn.occupied ? "#ffffff" : "transparent"
                        }
                        GradientStop {
                            position: 1.0
                            color: wsBtn.active ? Services.Colors.accent : wsBtn.occupied ? "#eff2f6" : "transparent"
                        }
                    }

                    border.width: wsBtn.active ? 1.5 : wsBtn.occupied ? 1 : 0
                    border.color: wsBtn.active ? Services.Colors.accent : "#ced6e0"

                    // Inner bevel highlight
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 1
                        radius: 999
                        color: "transparent"
                        border.width: 1
                        border.color: wsBtn.active ? Qt.rgba(1, 1, 1, 0.8) : wsBtn.occupied ? Qt.rgba(1, 1, 1, 0.95) : "transparent"
                        visible: wsBtn.active || wsBtn.occupied
                    }

                    Text {
                        anchors.centerIn: parent
                        text: wsBtn.modelData
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        font.bold: true
                        color: wsBtn.active ? "#091224" : wsBtn.occupied ? "#2a3446" : Qt.rgba(0.05, 0.06, 0.11, 0.25)
                    }

                    TapHandler {
                        // Using CachyOS's Lua-based hyprland dispatcher syntax as per existing codebase logic
                        onTapped: Hyprland.dispatch("hl.dsp.focus({workspace = " + wsBtn.modelData + "})")
                    }
                }
            }
        }
    }
}

