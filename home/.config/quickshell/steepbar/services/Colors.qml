pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Mirror's Edge aesthetic: frosted white bar, pywal accent border.
// Reads ~/.cache/wal/colors live (16 hex lines written by `wal -i`) and
// falls back to the hand-picked palette below until pywal has run once.
QtObject {
    id: root

    property color bg: "#eef5f3eb"              // Warm Alabaster Frosted Glass (milk glass)
    property color fg: "#1e2a3b"              // Deep Charcoal Slate (softer than black)
    property color accent: "#0a6cff"          // Warm Cerulean Blue
    property color accent2: "#38b6ff"         // Soft Sky Blue
    property color subtext: "#5a687a"         // Muted Slate Grey

    // Fixed semantic colors carried over from the old alerts/docker scripts.
    readonly property color danger: "#ff453a"   // Warm Coral Red
    readonly property color warning: "#ffa62b"  // Golden Honey/Amber
    readonly property color idle: "#8e9fa7"     // Soft Muted Slate
    readonly property color success: "#34c759"  // Warm Grass Green

    property color cardBg: "#faf8f2ff"          // Ivory/Warm Cream dropdown card
    property color glassBorder: "#c7beaf"       // Soft Sand-grey border
    property color innerBevel: "#ffffff"        // Pure white reflection highlight

    // Tipografía de sistema: Adwaita Sans (derivada de Inter, instalada
    // de fábrica). Los glifos de iconos Nerd llegan por fallback de
    // fontconfig, así que no fijar familia en Texts de solo-icono.
    readonly property string uiFont: "Adwaita Sans"

    property var palette: []

    function _apply(text) {
        const lines = text.split("\n").map(l => l.trim()).filter(l => l.length > 0)
        if (lines.length < 16) return
        palette = lines
        // accent2 = lines[5]
        // accent = lines[6]
        // subtext = lines[8]
    }

    property FileView _colorsFile: FileView {
        id: colorsFile
        path: Quickshell.env("HOME") + "/.cache/wal/colors"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root._apply(text())
    }
}
