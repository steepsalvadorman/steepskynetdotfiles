pragma Singleton
import QtQuick

// Shared bar-visibility flag, flipped via `qs -c steepbar ipc call bar toggle`
// (bound to $mainMod, B — see shell.qml and hyprland.conf).
QtObject {
    property bool barVisible: true
    function toggle() { barVisible = !barVisible }
}
