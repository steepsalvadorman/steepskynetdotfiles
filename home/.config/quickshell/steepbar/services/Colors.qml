pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Mirror's Edge aesthetic: frosted white bar, pywal accent border.
// Reads ~/.cache/wal/colors live (16 hex lines written by `wal -i`) and
// falls back to the hand-picked palette below until pywal has run once.
QtObject {
    id: root

    property color pywalAccent: palette.length >= 16 ? palette[2] : "transparent"
    property color pywalAccent2: palette.length >= 16 ? palette[3] : "transparent"

    property color bg: palette.length >= 16
        ? Qt.tint("#eef5f3eb", Qt.rgba(pywalAccent.r, pywalAccent.g, pywalAccent.b, 0.06))
        : "#eef5f3eb"              // Warm Alabaster Frosted Glass (milk glass)

    property color fg: "#1e2a3b"              // Deep Charcoal Slate (softer than black)

    // Dynamic contrast-filtered accent colors
    property color accent: palette.length >= 16
        ? (pywalAccent.hslLightness > 0.6 ? Qt.hsla(pywalAccent.hslHue, pywalAccent.hslSaturation, 0.45, 1.0) : pywalAccent)
        : "#0a6cff"          // Warm Cerulean Blue

    property color accent2: palette.length >= 16
        ? (pywalAccent2.hslLightness > 0.65 ? Qt.hsla(pywalAccent2.hslHue, pywalAccent2.hslSaturation, 0.50, 1.0) : pywalAccent2)
        : "#38b6ff"         // Soft Sky Blue

    property color subtext: "#5a687a"         // Muted Slate Grey

    // Fixed semantic colors carried over from the old alerts/docker scripts.
    readonly property color danger: "#ff453a"   // Warm Coral Red
    readonly property color warning: "#ffa62b"  // Golden Honey/Amber
    readonly property color idle: "#8e9fa7"     // Soft Muted Slate
    readonly property color success: "#34c759"  // Warm Grass Green

    property color cardBg: palette.length >= 16
        ? Qt.tint("#faf8f2ff", Qt.rgba(pywalAccent.r, pywalAccent.g, pywalAccent.b, 0.03))
        : "#faf8f2ff"          // Ivory/Warm Cream dropdown card

    property color glassBorder: "#c7beaf"       // Soft Sand-grey border
    property color innerBevel: "#ffffff"        // Pure white reflection highlight

    // Volumetric Glossy Gel Overlay Gradient (Mac OS X Aqua / Windows Aero style)
    readonly property Gradient gelGloss: Gradient {
        GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.56) }
        GradientStop { position: 0.48; color: Qt.rgba(1, 1, 1, 0.10) }
        GradientStop { position: 0.50; color: Qt.rgba(1, 1, 1, 0.0) }
        GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.0) }
    }

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
