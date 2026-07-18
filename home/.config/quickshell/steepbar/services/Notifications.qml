pragma Singleton
import QtQuick
import Quickshell.Services.Notifications

// Native freedesktop notification daemon, replacing SwayNC entirely.
// Popups.qml renders incoming toasts; NotificationCenter.qml renders
// `history`; NotifBell.qml badges on `unseenCount`.
QtObject {
    id: root

    property int unseenCount: 0

    readonly property NotificationServer server: NotificationServer {
        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        imageSupported: true
        actionsSupported: true
        actionIconsSupported: true

        onNotification: notification => {
            notification.tracked = true
            root.unseenCount += 1
        }
    }

    readonly property var history: server.trackedNotifications

    function clearAll() {
        const items = history.values
        for (let i = items.length - 1; i >= 0; i--) items[i].dismiss()
        unseenCount = 0
    }

    function markSeen() {
        unseenCount = 0
    }
}
