import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../../services" as Services

// Scans ~/Documentos/programacion by language, opens the pick in VS Code.
// Toggled from the "Dev" pill in Right.qml and `qs -c steepbar ipc call projects toggle`.
Rectangle {
    id: popup
    implicitWidth: 260
    implicitHeight: Math.min(list.implicitHeight + 20, 520)
    visible: Services.PopupState.projectsVisible

    readonly property string scriptPath: Quickshell.env("HOME") + "/.config/quickshell/steepbar/scripts/projects"
    property var sections: []

    Process {
        id: scanProc
        command: [popup.scriptPath]
        stdout: StdioCollector { id: scanOut }
        onExited: {
            try { popup.sections = JSON.parse(scanOut.text) } catch (e) { popup.sections = [] }
        }
    }

    onVisibleChanged: if (visible) scanProc.running = true

    radius: 14
    color: Qt.rgba(0.957, 0.969, 1, 0.97)
    border.width: 1
    border.color: Qt.rgba(0.784, 0.843, 0.922, 0.55)

        ColumnLayout {
            id: list
            anchors.fill: parent
            anchors.margins: 10
            spacing: 2

            Text {
                text: " Proyectos"
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 13
                font.bold: true
                color: "#0d0f1c"
                Layout.bottomMargin: 6
            }

            Repeater {
                model: popup.sections
                delegate: ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: modelData.icon + "  " + modelData.label
                        font.pixelSize: 11
                        font.bold: true
                        color: Services.Colors.accent
                        Layout.topMargin: 6
                    }

                    Repeater {
                        model: modelData.projects
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            radius: 8
                            implicitHeight: 26
                            color: projHover.hovered ? Qt.rgba(0.667, 0.8, 0.933, 0.12) : "transparent"

                            HoverHandler { id: projHover }
                            TapHandler {
                                onTapped: {
                                    Quickshell.execDetached(["code", modelData.path])
                                    Services.PopupState.projectsVisible = false
                                }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 8
                                text: "  " + modelData.name
                                font.pixelSize: 13
                                color: projHover.hovered ? Services.Colors.accent : "#0d0f1c"
                            }
                        }
                    }
                }
            }
        }
    }
