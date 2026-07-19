pragma Singleton
import QtQuick

// Cross-widget open/close state for the popup windows (projects,
// notification center, app launcher, and audio control panel) so the bar pills,
// IpcHandler targets, and the popups themselves can all toggle the same flag.
QtObject {
    property bool projectsVisible: false
    property bool notifCenterVisible: false
    property bool launcherVisible: false
    property bool audioVisible: false
    property bool systemVisible: false

    function _closeAll() {
        projectsVisible = false
        notifCenterVisible = false
        launcherVisible = false
        audioVisible = false
        systemVisible = false
    }

    function toggleProjects() {
        const next = !projectsVisible
        _closeAll()
        projectsVisible = next
    }

    function toggleNotifCenter() {
        const next = !notifCenterVisible
        _closeAll()
        notifCenterVisible = next
    }

    function toggleLauncher() {
        const next = !launcherVisible
        _closeAll()
        launcherVisible = next
    }

    function toggleAudio() {
        const next = !audioVisible
        _closeAll()
        audioVisible = next
    }

    function toggleSystem() {
        const next = !systemVisible
        _closeAll()
        systemVisible = next
    }
}


