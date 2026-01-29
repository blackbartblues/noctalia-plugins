import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services.UI
import qs.Widgets

NIconButton {
  id: root

  property var pluginApi: null
  property ShellScreen screen
  property string widgetId: ""
  property string section: ""

  property bool steamRunning: false

  baseSize: Style.getCapsuleHeightForScreen(screen.name)
  applyUiScale: false
  icon: "brand-steam"
  tooltipText: steamRunning ? "Steam Running - Toggle Overlay" : "Steam Stopped"
  tooltipDirection: BarService.getTooltipDirection()

  colorBg: Style.capsuleColor
  colorFg: Color.mOnSurface
  colorBorder: "transparent"
  colorBorderHover: "transparent"

  // Process to check Steam status
  Process {
    id: checkSteamProcess
    command: ["pidof", "steam"]
    running: false

    onExited: (exitCode, exitStatus) => {
      steamRunning = (exitCode === 0);
    }
  }

  // IPC Process to toggle overlay
  Process {
    id: ipcProcess
    command: ["qs", "-p", Quickshell.shellDir, "ipc", "call", "plugin:hyprland-steam-overlay", "toggle"]
    running: false
  }

  // Update steam status periodically
  Timer {
    interval: 5000
    repeat: true
    running: true
    onTriggered: {
      checkSteamProcess.running = true;
    }
  }

  Component.onCompleted: {
    checkSteamProcess.running = true;
  }

  onClicked: {
    if (pluginApi) {
      Logger.i("SteamOverlay.BarWidget", "Calling Steam overlay toggle");
      ipcProcess.running = true;
    }
  }

  onRightClicked: {
    if (pluginApi) {
      pluginApi.openPanel(screen);
    }
  }
}
