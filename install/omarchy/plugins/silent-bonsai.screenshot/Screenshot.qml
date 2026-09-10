import QtQuick
import qs.Ui

BarWidget {
  id: root
  moduleName: "silent-bonsai.screenshot"

  readonly property bool revealed: bar
    && bar.centerSectionRevealHeld === true
    && bar.centerHoverRevealSuppressed !== true

  implicitWidth: revealed ? button.implicitWidth : 0
  implicitHeight: button.implicitHeight
  opacity: revealed ? 1 : 0
  clip: true

  Behavior on implicitWidth {
    NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
  }

  Behavior on opacity {
    NumberAnimation { duration: 120 }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰄀"
    tooltipText: "Take screenshot"
    horizontalMargin: 7.5
    onPressed: function() {
      if (root.bar) root.bar.run("omarchy capture screenshot")
    }
  }
}
