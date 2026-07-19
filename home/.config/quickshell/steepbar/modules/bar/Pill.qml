import QtQuick
import QtQuick.Layouts
import "../../services" as Services

// Zona de la barra SIN contorno. La información pasiva vive desnuda sobre
// el vidrio; las zonas interactivas se "materializan" al hover: emerge una
// superficie aqua (gradiente + tapa de vidrio + sombra de contacto) con
// fundido — relieve hecho de luz, nunca de líneas.
Item {
    id: root
    default property alias content: row.data
    property alias spacing: row.spacing
    property bool interactive: true
    property real hPad: 12
    property real vPad: 4
    signal clicked()

    implicitWidth: row.implicitWidth + hPad * 2
    implicitHeight: Math.max(row.implicitHeight + vPad * 2, 38)

    readonly property bool _lit: root.interactive && (hoverHandler.hovered || pressHandler.pressed)

    // Sombra de contacto (halo suave, sin anillo)
    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 2
        radius: 999
        color: Qt.rgba(0.07, 0.13, 0.24, 0.10)
        opacity: root._lit ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 160 } }
    }

    // Superficie que emerge al hover
    Rectangle {
        id: buttonBase
        width: parent.width
        height: parent.height - 1
        y: pressHandler.pressed ? 1 : 0
        radius: 999
        antialiasing: true
        opacity: root._lit ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 160 } }
        Behavior on y { NumberAnimation { duration: 60 } }

        gradient: Gradient {
            GradientStop { position: 0.0; color: pressHandler.pressed ? Qt.darker(Services.Colors.cardBg, 1.08) : "#ffffff" }
            GradientStop { position: 1.0; color: pressHandler.pressed ? Qt.darker(Services.Colors.cardBg, 1.02) : Services.Colors.cardBg }
        }

        // Tapa de vidrio
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 1.5
            width: parent.width - 10
            height: parent.height * 0.46
            radius: height / 2
            antialiasing: true
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.60) }
                GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.03) }
            }
        }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        anchors.verticalCenterOffset: pressHandler.pressed ? 1 : 0
        spacing: 6
        Behavior on anchors.verticalCenterOffset { NumberAnimation { duration: 60 } }
    }

    HoverHandler { id: hoverHandler }
    TapHandler {
        id: pressHandler
        enabled: root.interactive
        onTapped: root.clicked()
    }
}
