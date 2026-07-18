import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications
import "../../services" as Services

// Shared visual for both the popup toast stack and the history panel.
// `popup: true` enables the auto-dismiss timer; history entries stay put.
Rectangle {
    id: root
    property var notification
    property bool popup: false
    signal dismissRequested()

    radius: 14
    color: Services.Colors.cardBg
    border.width: 1
    border.color: Services.Colors.glassBorder

    // Inner highlight bevel
    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: 13
        color: "transparent"
        border.width: 1
        border.color: Services.Colors.innerBevel
    }

    implicitHeight: layout.implicitHeight + 20

    readonly property color urgencyColor: notification
        ? (notification.urgency === NotificationUrgency.Critical ? Services.Colors.danger
           : notification.urgency === NotificationUrgency.Low ? Services.Colors.subtext
           : Services.Colors.accent2)
        : Services.Colors.accent2

    Rectangle {
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
        width: 3
        radius: 2
        color: root.urgencyColor
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 12
        anchors.leftMargin: 16
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                Layout.fillWidth: true
                text: notification ? (notification.summary || notification.appName || "Notificación") : ""
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 13
                font.bold: true
                color: Services.Colors.fg
                elide: Text.ElideRight
            }
            Text {
                text: "✕"
                font.pixelSize: 11
                color: Services.Colors.subtext
                TapHandler {
                    onTapped: {
                        if (root.notification) root.notification.dismiss()
                        root.dismissRequested()
                    }
                }
            }
        }

        Text {
            Layout.fillWidth: true
            visible: notification && notification.body && notification.body.length > 0
            text: notification ? notification.body : ""
            textFormat: Text.RichText
            font.family: "JetBrainsMono Nerd Font Mono"
            font.pixelSize: 12
            color: Services.Colors.subtext
            wrapMode: Text.WordWrap
            maximumLineCount: 3
            elide: Text.ElideRight
        }

        RowLayout {
            visible: notification && notification.actions && notification.actions.length > 0
            spacing: 6

            Repeater {
                model: notification ? notification.actions : []
                delegate: Rectangle {
                    radius: 999
                    color: "#f1f4f8"
                    border.width: 1
                    border.color: Services.Colors.glassBorder
                    implicitWidth: actionLabel.implicitWidth + 16
                    implicitHeight: 22

                    Text {
                        id: actionLabel
                        anchors.centerIn: parent
                        text: modelData.text
                        font.pixelSize: 11
                        color: Services.Colors.fg
                    }
                    TapHandler { onTapped: modelData.invoke() }
                }
            }
        }
    }

    Timer {
        interval: (root.notification && root.notification.expireTimeout > 0) ? root.notification.expireTimeout * 1000 : 6000
        running: root.popup
        onTriggered: root.dismissRequested()
    }
}
