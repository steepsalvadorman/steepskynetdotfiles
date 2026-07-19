pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Telemetría del sistema compartida entre el orbe de salud de la barra
// y el panel de detalle. Sondea scripts/sysinfo cada 3 s.
QtObject {
    id: root

    property real cpu: 0
    property real cpuTemp: 0
    property real ram: 0
    property real gpu: 0
    property real gpuTemp: 0

    // Semáforo de salud: la señal ambiental que colorea el orbe
    readonly property string health:
        (cpu >= 90 || ram >= 90 || gpu >= 90 || cpuTemp >= 85 || gpuTemp >= 85) ? "critical"
      : (cpu >= 75 || ram >= 75 || gpu >= 75 || cpuTemp >= 70 || gpuTemp >= 70) ? "elevated"
      : "normal"

    property Process _proc: Process {
        command: [Quickshell.env("HOME") + "/.config/quickshell/steepbar/scripts/sysinfo", "--all"]
        stdout: StdioCollector { id: sysOut }
        onExited: {
            const p = sysOut.text.trim().split("|")
            if (p.length === 5) {
                root.cpu = parseFloat(p[0]) || 0
                root.cpuTemp = parseFloat(p[1]) || 0
                root.ram = parseFloat(p[2]) || 0
                root.gpu = parseFloat(p[3]) || 0
                root.gpuTemp = parseFloat(p[4]) || 0
            }
        }
    }

    property Timer _timer: Timer {
        interval: 3000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: root._proc.running = true
    }
}
