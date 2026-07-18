import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../services" as Services

// Toast stack, top-right corner — replaces SwayNC's popup notifications.
PanelWindow {
    id: popupWindow
    WlrLayershell.namespace: "quickshell:popups"
    anchors { top: true; right: true }
    margins { top: 56; right: 16 }
    exclusiveZone: 0
    color: "transparent"
    implicitWidth: 320
    implicitHeight: column.implicitHeight
    visible: repeater.count > 0

    property var queue: []

    Connections {
        target: Services.Notifications.server
        function onNotification(notification) {
            popupWindow.queue = [...popupWindow.queue, notification]
        }
    }

    function remove(notification) {
        popupWindow.queue = popupWindow.queue.filter(n => n !== notification)
    }

    Column {
        id: column
        anchors.top: parent.top
        anchors.right: parent.right
        width: 320
        spacing: 8

        Repeater {
            id: repeater
            model: popupWindow.queue
            delegate: NotificationCard {
                width: 320
                notification: modelData
                popup: true
                onDismissRequested: popupWindow.remove(modelData)
            }
        }
    }
}
