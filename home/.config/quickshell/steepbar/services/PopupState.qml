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

    function toggleProjects() {
        projectsVisible = !projectsVisible
        if (projectsVisible) {
            notifCenterVisible = false
            launcherVisible = false
            audioVisible = false
        }
    }

    function toggleNotifCenter() {
        notifCenterVisible = !notifCenterVisible
        if (notifCenterVisible) {
            projectsVisible = false
            launcherVisible = false
            audioVisible = false
        }
    }

    function toggleLauncher() {
        launcherVisible = !launcherVisible
        if (launcherVisible) {
            projectsVisible = false
            notifCenterVisible = false
            audioVisible = false
        }
    }

    function toggleAudio() {
        audioVisible = !audioVisible
        if (audioVisible) {
            projectsVisible = false
            notifCenterVisible = false
            launcherVisible = false
        }
    }
}


