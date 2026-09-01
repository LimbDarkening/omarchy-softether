import QtQuick
import qs.Commons

Item {
  id: root

  property real iconSize: Style.font.icon
  property color color: Color.foreground
  property color badgeColor: Color.urgent
  property string state: "off"
  property bool pulsing: false

  width: iconSize
  height: iconSize
  implicitWidth: iconSize
  implicitHeight: iconSize

  Canvas {
    id: shield
    anchors.fill: parent
    property real pulseOpacity: 1.0
    opacity: root.state === "off" ? 0.52 : (root.pulsing ? pulseOpacity : 1.0)

    onPaint: {
      var ctx = getContext("2d")
      var w = width
      var h = height
      ctx.reset()
      ctx.beginPath()
      ctx.moveTo(w * 0.50, h * 0.06)
      ctx.bezierCurveTo(w * 0.66, h * 0.16, w * 0.78, h * 0.19, w * 0.91, h * 0.22)
      ctx.lineTo(w * 0.88, h * 0.57)
      ctx.bezierCurveTo(w * 0.85, h * 0.76, w * 0.70, h * 0.90, w * 0.50, h * 0.98)
      ctx.bezierCurveTo(w * 0.30, h * 0.90, w * 0.15, h * 0.76, w * 0.12, h * 0.57)
      ctx.lineTo(w * 0.09, h * 0.22)
      ctx.bezierCurveTo(w * 0.22, h * 0.19, w * 0.34, h * 0.16, w * 0.50, h * 0.06)
      ctx.closePath()

      if (root.state === "off") {
        ctx.lineWidth = Math.max(1.3, w * 0.11)
        ctx.strokeStyle = root.color
        ctx.stroke()
      } else {
        ctx.fillStyle = root.color
        ctx.fill()
      }
    }

    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    Connections {
      target: root
      function onColorChanged() { shield.requestPaint() }
      function onStateChanged() { shield.requestPaint() }
    }

    SequentialAnimation on pulseOpacity {
      running: root.pulsing
      loops: Animation.Infinite
      NumberAnimation { from: 1.0; to: 0.38; duration: 520; easing.type: Easing.InOutQuad }
      NumberAnimation { from: 0.38; to: 1.0; duration: 520; easing.type: Easing.InOutQuad }
    }
  }

  Rectangle {
    visible: root.state === "error" || root.state === "warning"
    width: Math.max(7, root.iconSize * 0.43)
    height: width
    radius: width / 2
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    color: root.badgeColor
    border.width: 1
    border.color: Color.background

    Text {
      anchors.centerIn: parent
      text: "!"
      color: Color.background
      font.family: Style.font.family
      font.pixelSize: Math.max(6, parent.height * 0.72)
      font.bold: true
    }
  }
}
