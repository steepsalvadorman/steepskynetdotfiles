pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Mirror's Edge aesthetic: frosted white bar, pywal accent border.
// Reads ~/.cache/wal/colors live (16 hex lines written by `wal -i`) and
// falls back to the hand-picked palette below until pywal has run once.
QtObject {
    id: root

    property color bg: "#0f141d"
    property color fg: "#e0e5ee"
    property color accent: "#AACCEE"
    property color accent2: "#99B2DA"
    property color subtext: "#9ca0a6"

    // Fixed semantic colors carried over from the old alerts/docker scripts.
    readonly property color danger: "#fb4934"
    readonly property color warning: "#fabd2f"
    readonly property color idle: "#504945"
    readonly property color success: "#8ec07c"

    property var palette: []

    function _apply(text) {
        const lines = text.split("\n").map(l => l.trim()).filter(l => l.length > 0)
        if (lines.length < 16) return
        palette = lines
        accent2 = lines[5]
        accent = lines[6]
        subtext = lines[8]
    }

    property FileView _colorsFile: FileView {
        id: colorsFile
        path: Quickshell.env("HOME") + "/.cache/wal/colors"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root._apply(text())
    }
}
