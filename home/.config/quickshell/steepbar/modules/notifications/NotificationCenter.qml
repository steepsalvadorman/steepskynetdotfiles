import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../services" as Services

// History panel toggled by the bell icon — replaces the SwayNC control center.
Rectangle {
    id: center
    implicitWidth: 320
    implicitHeight: 420
    visible: Services.PopupState.notifCenterVisible

    onVisibleChanged: if (visible) Services.Notifications.markSeen()

    radius: 18
    color: Services.Colors.cardBg
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
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: "󰂚  Notificaciones"
                    font.family: "JetBrainsMono Nerd Font Mono"
                    font.pixelSize: 13
                    font.bold: true
                    color: Services.Colors.fg
                }
                Text {
                    text: "Limpiar"
                    font.pixelSize: 11
                    color: Services.Colors.accent2
                    TapHandler { onTapped: Services.Notifications.clearAll() }
                }
            }

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: list.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: list
                    width: parent.width
                    spacing: 8

                    Text {
                        visible: Services.Notifications.history.values.length === 0
                        text: "Sin notificaciones"
                        font.pixelSize: 12
                        color: Services.Colors.subtext
                    }

                    Repeater {
                        model: Services.Notifications.history
                        delegate: NotificationCard {
                            Layout.fillWidth: true
                            notification: modelData
                            popup: false
                        }
                    }
                }
            }
        }
    }
