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
    
    // Reserve space only for the bar shell (40px height + 4px margin)
    exclusiveZone: 44
    
    // Tall window size to encompass dropdowns inside the same Layer Surface
    implicitHeight: 600
    color: "transparent"
    visible: Services.BarState.barVisible

    // Click mask: When popups are open, the whole window accepts clicks (for tap-outside-to-close).
    // When closed, only the 40px bar shell accepts clicks (transparent areas let clicks pass through).
    mask: Region {
        Region { item: shell }
        Region {
            x: 0
            y: 0
            width: (Services.PopupState.audioVisible || Services.PopupState.notifCenterVisible || Services.PopupState.projectsVisible) ? bar.width : 0
            height: (Services.PopupState.audioVisible || Services.PopupState.notifCenterVisible || Services.PopupState.projectsVisible) ? bar.height : 0
        }
    }

    // ── Bar Header Shell ──────────────────────────────────
    Rectangle {
        id: shell
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40
        radius: 18
        
        // Skeuomorphic raised vertical gradient
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#ffffff" }
            GradientStop { position: 1.0; color: "#f2f4f8" }
        }
        
        border.width: 1
        border.color: "#ced5df"

        // Inner Bevel Highlight
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: 17
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.95)
        }

        // Glossy Reflection overlay
        Rectangle {
            anchors.fill: parent
            radius: 17
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
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // Dismissal overlay: captures clicks outside the dropdown to close it
    MouseArea {
        anchors.fill: parent
        visible: Services.PopupState.audioVisible || Services.PopupState.notifCenterVisible || Services.PopupState.projectsVisible
        onClicked: {
            Services.PopupState.audioVisible = false
            Services.PopupState.notifCenterVisible = false
            Services.PopupState.projectsVisible = false
        }
    }

    // ── Dropdown: Audio Control Center ────────────────────
    AudioPopup {
        id: audioDropdown
        anchors.top: shell.bottom
        anchors.topMargin: 8
        anchors.right: shell.right
        anchors.rightMargin: 220
    }

    // ── Dropdown: Notifications Center ────────────────────
    NotifModule.NotificationCenter {
        id: notifDropdown
        anchors.top: shell.bottom
        anchors.topMargin: 8
        anchors.right: shell.right
        anchors.rightMargin: 12
    }

    // ── Dropdown: Developer Projects ──────────────────────
    ProjectsModule.ProjectsPopup {
        id: projectsDropdown
        anchors.top: shell.bottom
        anchors.topMargin: 8
        anchors.right: shell.right
        anchors.rightMargin: 580
    }
}
