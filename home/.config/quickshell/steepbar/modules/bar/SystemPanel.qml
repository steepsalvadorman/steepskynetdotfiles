import QtQuick
import QtQuick.Layouts
import "../../services" as Services

// Dropdown de telemetría: los velocímetros EN GRANDE viven aquí, bajo
// demanda — la barra solo lleva el orbe de salud. Rectangle embebido en
// la superficie de Bar.qml, igual que AudioPopup.
Rectangle {
    id: popup
    implicitWidth: 320
    implicitHeight: contentColumn.implicitHeight + 32
    visible: Services.PopupState.systemVisible

    radius: 18
    gradient: Gradient {
        GradientStop { position: 0.0; color: "#ffffff" }
        GradientStop { position: 1.0; color: "#f3f6fa" }
    }
    border.width: 1
    border.color: Qt.rgba(0.71, 0.80, 0.91, 0.55)

    // Tapa de vidrio superior
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 2
        width: parent.width - 16
        height: 56
        radius: 16
        antialiasing: true
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.55) }
            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.0) }
        }
    }

    // Línea de acento inferior
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 20
        height: 2.5
        radius: 1.5
        color: Services.Colors.accent
    }

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        RowLayout {
            spacing: 8
            Text {
                text: "󰓅"
                font.pixelSize: 18
                color: Services.Colors.accent
            }
            Text {
                text: "Sistema"
                font.family: Services.Colors.uiFont
                font.pixelSize: 13
                font.bold: true
                color: Services.Colors.fg
                style: Text.Sunken
                styleColor: Qt.rgba(1, 1, 1, 0.85)
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 22

            ColumnLayout {
                spacing: 4
                Gauge { size: 72; value: Services.SysStats.cpu; label: "CPU"; Layout.alignment: Qt.AlignHCenter }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: Math.round(Services.SysStats.cpuTemp) + "°C"
                    font.family: Services.Colors.uiFont
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    color: Services.SysStats.cpuTemp >= 80 ? Services.Colors.danger
                         : Services.SysStats.cpuTemp >= 65 ? Services.Colors.warning
                         : Services.Colors.subtext
                    style: Text.Sunken
                    styleColor: Qt.rgba(1, 1, 1, 0.85)
                }
            }

            ColumnLayout {
                spacing: 4
                Gauge { size: 72; value: Services.SysStats.ram; label: "RAM"; Layout.alignment: Qt.AlignHCenter }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "memoria"
                    font.family: Services.Colors.uiFont
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: Services.Colors.subtext
                    style: Text.Sunken
                    styleColor: Qt.rgba(1, 1, 1, 0.85)
                }
            }

            ColumnLayout {
                spacing: 4
                Gauge { size: 72; value: Services.SysStats.gpu; label: "GPU"; Layout.alignment: Qt.AlignHCenter }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: Math.round(Services.SysStats.gpuTemp) + "°C"
                    font.family: Services.Colors.uiFont
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    color: Services.SysStats.gpuTemp >= 80 ? Services.Colors.danger
                         : Services.SysStats.gpuTemp >= 65 ? Services.Colors.warning
                         : Services.Colors.subtext
                    style: Text.Sunken
                    styleColor: Qt.rgba(1, 1, 1, 0.85)
                }
            }
        }
    }
}
