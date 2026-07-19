import QtQuick
import "../../services" as Services

// Esfera caramelo aqua SIN contorno: el volumen sale del gradiente de tres
// paradas (luz arriba, color, base oscura), la tapa de vidrio y una sombra
// de contacto suave debajo. Ninguna línea de borde.
Item {
    id: root
    property string glyph: ""
    property color tint: "#f5f8fc"       // plateado por defecto
    property color glyphColor: Services.Colors.fg
    property real glyphSize: 13
    property bool colored: false          // true → orbe de color saturado con glifo claro

    implicitWidth: 26
    implicitHeight: 26

    // Sombra de contacto (halo difuso bajo la esfera)
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 2
        width: parent.width
        height: parent.height - 1
        radius: 999
        antialiasing: true
        color: Qt.rgba(0.07, 0.13, 0.24, 0.16)
    }

    Rectangle {
        id: body
        width: parent.width
        height: parent.height - 1
        radius: 999
        antialiasing: true
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.lighter(root.tint, 1.22) }
            GradientStop { position: 0.55; color: root.tint }
            GradientStop { position: 1.0; color: Qt.darker(root.tint, 1.22) }
        }

        // Tapa de vidrio estática
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 1
            width: parent.width - 8
            height: parent.height * 0.46
            radius: height / 2
            antialiasing: true
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.72) }
                GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.05) }
            }
        }

        // Reflejo secundario inferior (brillo de rebote ambiental Frutiger Aero)
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2
            width: parent.width - 10
            height: parent.height * 0.16
            radius: height / 2
            antialiasing: true
            color: Qt.rgba(1, 1, 1, 0.20)
        }

        Text {
            anchors.centerIn: parent
            text: root.glyph
            font.pixelSize: root.glyphSize
            color: root.glyphColor
            style: Text.Raised
            styleColor: root.colored ? Qt.darker(root.tint, 1.55) : Qt.rgba(1, 1, 1, 0.90)
        }
    }
}
