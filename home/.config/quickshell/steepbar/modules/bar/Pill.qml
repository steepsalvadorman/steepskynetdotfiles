import QtQuick
import QtQuick.Layouts
import "../../services" as Services

Item {
    id: root
    default property alias content: row.data
    property alias spacing: row.spacing
    property bool interactive: true
    property real hPad: 12
    property real vPad: 4
    signal clicked()

    implicitWidth: row.implicitWidth + hPad * 2
    implicitHeight: Math.max(row.implicitHeight + vPad * 2, 34)

    // Outer Shadow / Ambient occlusion (static base)
    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 2.5
        radius: 999
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(0.08, 0.15, 0.25, 0.08)
    }

    // Interactive Floating Button Base (Skeuomorphic Relief)
    Rectangle {
        id: buttonBase
        width: parent.width
        height: parent.height - 1.5
        // Tactile depth offset: button goes down when pressed/hovered
        y: pressHandler.pressed ? 1.5 : hoverHandler.hovered ? 0.0 : 0.8
        radius: 999

        Behavior on y { NumberAnimation { duration: 60 } }

        // Skeuomorphic vertical gradient (raised look)
        gradient: Gradient {
            GradientStop { 
                position: 0.0 
                color: pressHandler.pressed ? "#cbdff5" : hoverHandler.hovered ? "#ffffff" : "#ffffff" 
            }
            GradientStop { 
                position: 1.0 
                color: pressHandler.pressed ? "#eaf2fa" : hoverHandler.hovered ? "#e3edf8" : "#f0f4f9" 
            }
        }

        // Border: switches to glowing accent color on hover
        border.width: 1
        border.color: pressHandler.pressed ? Services.Colors.accent : hoverHandler.hovered ? Services.Colors.accent2 : Services.Colors.glassBorder

        Behavior on border.color { ColorAnimation { duration: 150 } }

        // Inner Bevel Highlight (light catching the top edge)
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: 999
            color: "transparent"
            border.width: 1
            border.color: Services.Colors.innerBevel
        }

        // Glossy Reflection overlay (curved upper shine)
        Rectangle {
            anchors.fill: parent
            radius: 999
            clip: true
            color: "transparent"
            Rectangle {
                width: parent.width * 1.5
                height: parent.height / 1.8
                rotation: -3
                x: -10
                y: -3
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.38) }
                    GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.0) }
                }
            }
        }

        // LED / Active Neon accent line (glow indicator on active/hovered)
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: hoverHandler.hovered ? Math.min(parent.width * 0.4, 30) : 0
            height: 2
            radius: 1
            color: Services.Colors.accent
            Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        }

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 6
        }
    }

    HoverHandler { id: hoverHandler }
    TapHandler {
        id: pressHandler
        enabled: root.interactive
        onTapped: root.clicked()
    }
}

