import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../services" as Services
import "../notifications" as NotifModule
import "../projects" as ProjectsModule

PanelWindow {
    id: bar
    required property var modelData
    screen: modelData
    WlrLayershell.namespace: "quickshell:bar"
    anchors { top: true; left: true; right: true }
    margins { top: 4; left: 13; right: 13 }
    
    // Reserve space only for the bar shell (52px height + 4px margin)
    exclusiveZone: 56
    
    // Tall window size to encompass dropdowns inside the same Layer Surface
    implicitHeight: 600
    color: "transparent"
    visible: Services.BarState.barVisible

    // Click mask: When popups are open, the whole window accepts clicks (for tap-outside-to-close).
    // When closed, only the 46px bar shell accepts clicks (transparent areas let clicks pass through).
    mask: Region {
        Region { item: shell }
        Region {
            x: 0
            y: 0
            width: (Services.PopupState.audioVisible || Services.PopupState.notifCenterVisible || Services.PopupState.projectsVisible || Services.PopupState.systemVisible) ? bar.width : 0
            height: (Services.PopupState.audioVisible || Services.PopupState.notifCenterVisible || Services.PopupState.projectsVisible || Services.PopupState.systemVisible) ? bar.height : 0
        }
    }

    // ── Bar Header Shell ──────────────────────────────────
    Rectangle {
        id: shell
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        // 52px: en 2560x1440 @ 31" (~95 ppp) ≈ 14 mm — presencia de
        // taskbar moderna sin robar altura de código/juego.
        height: 52
        radius: 26
        
        // Skeuomorphic raised vertical gradient
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#ffffff" }
            GradientStop { position: 1.0; color: "#e9eef6" }
        }
        
        border.width: 1
        border.color: Qt.rgba(0.71, 0.80, 0.91, 0.50)

        // Inner Bevel Highlight
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: 25
            color: "transparent"
            border.width: 1
            border.color: Services.Colors.innerBevel
        }

        // Glossy Reflection overlay
        Rectangle {
            anchors.fill: parent
            radius: 25
            clip: true
            color: "transparent"
            Rectangle {
                width: parent.width * 1.2
                height: parent.height / 1.7
                rotation: -1.5
                x: -10
                y: -3
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.32) }
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
            radius: 2
            color: Services.Colors.accent
        }

        Item {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12

            Left {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }

            Center {
                anchors.centerIn: parent
            }

            Right {
                id: barRight
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // Dismissal overlay: captures clicks outside the dropdown to close it
    MouseArea {
        anchors.fill: parent
        visible: Services.PopupState.audioVisible || Services.PopupState.notifCenterVisible || Services.PopupState.projectsVisible || Services.PopupState.systemVisible
        onClicked: {
            Services.PopupState.audioVisible = false
            Services.PopupState.notifCenterVisible = false
            Services.PopupState.projectsVisible = false
            Services.PopupState.systemVisible = false
        }
    }

    // ── Dropdown: Audio Control Center ────────────────────
    AudioPopup {
        id: audioDropdown
        anchors.top: shell.bottom
        anchors.right: shell.right
        anchors.rightMargin: 220

        visible: Services.PopupState.audioVisible || opacity > 0
        opacity: Services.PopupState.audioVisible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
        anchors.topMargin: Services.PopupState.audioVisible ? 8 : -8
        Behavior on anchors.topMargin { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
    }

    // ── Dropdown: Notifications Center ────────────────────
    NotifModule.NotificationCenter {
        id: notifDropdown
        anchors.top: shell.bottom
        anchors.right: shell.right
        anchors.rightMargin: 12

        visible: Services.PopupState.notifCenterVisible || opacity > 0
        opacity: Services.PopupState.notifCenterVisible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
        anchors.topMargin: Services.PopupState.notifCenterVisible ? 8 : -8
        Behavior on anchors.topMargin { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
    }

    // ── Dropdown: Developer Projects ──────────────────────
    ProjectsModule.ProjectsPopup {
        id: projectsDropdown
        anchors.top: shell.bottom
        anchors.right: shell.right
        anchors.rightMargin: 580

        visible: Services.PopupState.projectsVisible || opacity > 0
        opacity: Services.PopupState.projectsVisible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
        anchors.topMargin: Services.PopupState.projectsVisible ? 8 : -8
        Behavior on anchors.topMargin { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
    }

    // ── Dropdown: System Status and Gauges ────────────────
    SystemPanel {
        id: systemDropdown
        anchors.top: shell.bottom
        anchors.right: shell.right
        anchors.rightMargin: Math.max(12, shell.width - (12 + barRight.x + barRight.sysPillX + barRight.sysPillWidth))

        visible: Services.PopupState.systemVisible || opacity > 0
        opacity: Services.PopupState.systemVisible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
        anchors.topMargin: Services.PopupState.systemVisible ? 8 : -8
        Behavior on anchors.topMargin { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
    }
}
