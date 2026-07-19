pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Mirror's Edge aesthetic: frosted white bar, pywal accent border.
// Reads ~/.cache/wal/colors live (16 hex lines written by `wal -i`) and
// falls back to the hand-picked palette below until pywal has run once.
QtObject {
    id: root

    property color bg: "#ebf2f6fa"
    property color fg: "#051630"
    property color accent: "#0052cc"
    property color accent2: "#00b3ff"
    property color subtext: "#4c6385"

    // Fixed semantic colors carried over from the old alerts/docker scripts.
    readonly property color danger: "#ff3b30"   // macOS Candy Red
    readonly property color warning: "#ff9f0a"  // macOS Candy Orange
    readonly property color idle: "#7e8e9f"     // Skeuomorphic Muted Slate
    readonly property color success: "#28cd41"  // macOS Candy Green

    property color cardBg: "#f2f8fcff"
    property color glassBorder: "#b5cce8"
    property color innerBevel: "#f2ffffff"

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
