import QtQuick
import QtQuick.Shapes
import "../../services" as Services

// Medidor circular tipo velocímetro (270°), escalable vía `size`.
// Número grande grabado (letterpress) al centro y etiqueta en el hueco
// inferior natural del arco. Sin contornos: riel hundido + arco de color.
Item {
    id: root
    property real value: 0          // 0–100
    property string label: ""
    property real size: 40

    readonly property color ringColor: value >= 90 ? Services.Colors.danger
                                     : value >= 75 ? Services.Colors.warning
                                     : Services.Colors.accent

    readonly property real _r: size / 2 - 4.5
    readonly property real _stroke: Math.max(4, size * 0.10)

    property real _shown: 0
    Behavior on _shown { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }
    onValueChanged: _shown = Math.max(0, Math.min(100, value))

    implicitWidth: size
    implicitHeight: size

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        // Riel hundido
        ShapePath {
            strokeWidth: root._stroke
            strokeColor: Qt.rgba(0.08, 0.15, 0.25, 0.15)
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root._r
                radiusY: root._r
                startAngle: 135
                sweepAngle: 270
            }
        }

        // Arco de valor
        ShapePath {
            strokeWidth: root._stroke
            strokeColor: root.ringColor
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root._r
                radiusY: root._r
                startAngle: 135
                sweepAngle: 270 * root._shown / 100
            }
        }
    }

    // Número grande, solo, grabado (letterpress)
    Text {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -1
        text: Math.round(root._shown)
        font.family: Services.Colors.uiFont
        font.pixelSize: Math.round(root.size * 0.35)
        font.weight: Font.Bold
        color: Services.Colors.fg
        style: Text.Sunken
        styleColor: Qt.rgba(1, 1, 1, 0.85)
    }

    // Etiqueta en el hueco inferior del velocímetro
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -1
        text: root.label
        font.family: Services.Colors.uiFont
        font.pixelSize: Math.max(7, Math.round(root.size * 0.175))
        font.weight: Font.Bold
        font.letterSpacing: 0.6
        color: Services.Colors.subtext
        style: Text.Sunken
        styleColor: Qt.rgba(1, 1, 1, 0.85)
    }
}
