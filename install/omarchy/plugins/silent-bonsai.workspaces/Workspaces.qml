import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "silent-bonsai.workspaces"

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }
    return null
  }

  function workspaceIds() {
    var ids = [1, 2, 3, 4, 5]
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      var id = values[i].id
      if (id > 0 && id <= 10 && ids.indexOf(id) === -1) ids.push(id)
    }
    ids.sort(function(left, right) { return left - right })
    return ids
  }

  function iconFor(appId) {
    var id = String(appId || "").toLowerCase()
    if (id.indexOf("zen") !== -1) return ""
    if (id.indexOf("ghostty") !== -1) return ""
    if (id.indexOf("emacs") !== -1) return ""
    if (id.indexOf("nautilus") !== -1) return ""
    if (id.indexOf("mpv") !== -1) return ""
    if (id.indexOf("spotify") !== -1) return ""
    if (id.indexOf("docker") !== -1) return "󰡨"
    if (id.indexOf("gimp") !== -1) return ""
    if (id.indexOf("warden") !== -1) return ""
    if (id.indexOf("calculator") !== -1 || id.indexOf("omacalc") !== -1) return ""
    if (id.indexOf("kdenlive") !== -1) return ""
    if (id.indexOf("impala") !== -1) return ""
    if (id.indexOf("wiremix") !== -1) return "󰓃"
    if (id.indexOf("bluetui") !== -1) return "󰂯"
    if (id.indexOf("btop") !== -1) return ""
    if (id.indexOf("wayfreeze") !== -1) return "󰄀"
    return "󰖯"
  }

  function windowIcons(workspace) {
    if (!workspace) return ""
    var icons = []
    var toplevels = workspace.toplevels.values
    for (var i = 0; i < toplevels.length; i++) {
      var toplevel = toplevels[i]
      var appId = toplevel.wayland && toplevel.wayland.appId
        ? toplevel.wayland.appId
        : (toplevel.lastIpcObject && toplevel.lastIpcObject.class ? toplevel.lastIpcObject.class : "")
      icons.push(iconFor(appId))
    }
    return icons.join(" ")
  }

  function workspaceLabel(id, workspace) {
    var name = workspace && workspace.name ? String(workspace.name) : (id === 10 ? "0" : String(id))
    var icons = windowIcons(workspace)
    return icons ? name + " " + icons : name
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)
  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.workspaceIds().length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.workspaceIds()

      Item {
        id: workspaceItem
        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData

        implicitWidth: workspaceButton.implicitWidth
        implicitHeight: root.barSize

        BorderSurface {
          anchors.fill: parent
          anchors.topMargin: Style.spaceReal(2.5)
          anchors.bottomMargin: Style.spaceReal(2.5)
          color: "transparent"
          borderSpec: workspaceItem.focused
            ? Border.flat(Color.accent, 1)
            : (workspaceButton.tooltipHovered ? Border.flat("#2b4040", 1) : Border.none())
          radius: height / 2
        }

        WidgetButton {
          id: workspaceButton
          anchors.fill: parent
          bar: root.bar
          text: root.workspaceLabel(workspaceItem.modelData, workspaceItem.workspace)
          foreground: workspaceItem.focused
            ? Color.accent
            : (tooltipHovered ? (root.bar ? root.bar.barForeground : Color.foreground) : "#7f7f7f")
          useActiveColor: false
          opacity: workspaceItem.occupied || workspaceItem.focused ? 1 : 0.5
          horizontalMargin: 8
          verticalPadding: 1
          onPressed: function() { root.focusWorkspace(workspaceItem.modelData) }
        }
      }
    }
  }
}
