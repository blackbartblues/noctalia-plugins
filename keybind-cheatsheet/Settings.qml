import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
  id: rootItem
  implicitWidth: 600
  implicitHeight: root.implicitHeight
  width: Math.max(implicitWidth, parent ? parent.width : 0)

  property var pluginApi: null

  Timer {
    id: resizeTimer
    interval: 10
    repeat: false
    running: false
    onTriggered: {
      // Find the QML Popup ancestor (identified by the `modal` bool property
      // which is unique to QML Popup and its subclasses) and set its width.
      var obj = rootItem.parent;
      var depth = 0;
      while (obj && depth < 10) {
        if (typeof obj.modal === "boolean") {
          obj.width = 640; // 600px content + 2*20px padding
          break;
        }
        obj = obj.parent;
        depth++;
      }
    }
  }

  Component.onCompleted: {
    resizeTimer.start();
  }

  Component.onDestruction: {
    resizeTimer.stop();
  }

  ColumnLayout {
    id: root
    implicitWidth: 600
    width: parent.width
    spacing: Style.marginM

  // Force minimum width with invisible spacer
  Item {
    Layout.preferredWidth: 600
    Layout.preferredHeight: 0
    visible: false
  }

  // Configuration
  property var cfg: rootItem.pluginApi?.pluginSettings || ({})
  property var defaults: rootItem.pluginApi?.manifest?.metadata?.defaultSettings || ({})

  // Edit-copy properties — initialized from saved settings, saved only in saveSettings()
  property int editWindowWidth: cfg.windowWidth ?? defaults.windowWidth ?? 1400
  property int editWindowHeight: cfg.windowHeight ?? defaults.windowHeight ?? 0
  property bool editAutoHeight: cfg.autoHeight ?? defaults.autoHeight ?? true
  property int editColumnCount: cfg.columnCount ?? defaults.columnCount ?? 3
  property string editModKeyVariable: cfg.modKeyVariable || defaults.modKeyVariable || "$mod"
  property string editHyprlandConfigPath: cfg.hyprlandConfigPath || defaults.hyprlandConfigPath || "~/.config/hypr/hyprland.conf"
  property string editHyprlandLuaConfigPath: cfg.hyprlandLuaConfigPath || defaults.hyprlandLuaConfigPath || "~/.config/hypr/hyprland.lua"
  property string editHyprlandParserMode: cfg.hyprlandParserMode || defaults.hyprlandParserMode || "auto"
  property bool editShowUndescribedBinds: cfg.showUndescribedBinds ?? defaults.showUndescribedBinds ?? true
  property string editNiriConfigPath: cfg.niriConfigPath || defaults.niriConfigPath || "~/.config/niri/config.kdl"

  // Header
  NText {
    Layout.fillWidth: true
    text: rootItem.pluginApi?.tr("settings.title")
    pointSize: Style.fontSizeXXL
    font.weight: Style.fontWeightBold
    color: Color.mOnSurface
  }

  NText {
    Layout.fillWidth: true
    text: rootItem.pluginApi?.tr("settings.description")
    color: Color.mOnSurfaceVariant
    pointSize: Style.fontSizeM
    wrapMode: Text.WordWrap
  }

  // Window Size Settings
  NBox {
    Layout.fillWidth: true
    Layout.preferredHeight: sizeContent.implicitHeight + Style.marginM * 2
    color: Color.mSurfaceVariant

    ColumnLayout {
      id: sizeContent
      anchors.fill: parent
      anchors.margins: Style.marginM
      spacing: Style.marginS

      NText {
        Layout.fillWidth: true
        text: rootItem.pluginApi?.tr("settings.window-size")
        pointSize: Style.fontSizeL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
      }

      // Width setting
      RowLayout {
        spacing: Style.marginM

        NText {
          text: rootItem.pluginApi?.tr("settings.width")
          color: Color.mOnSurface
          pointSize: Style.fontSizeM
          Layout.preferredWidth: 120
        }

        NTextInput {
          id: widthInput
          Layout.preferredWidth: 100 * Style.uiScaleRatio
          Layout.preferredHeight: Style.baseWidgetSize
          text: root.editWindowWidth.toString()

          onTextChanged: {
            var val = parseInt(text);
            if (!isNaN(val) && val >= 400 && val <= 3000) {
              root.editWindowWidth = val;
            }
          }
        }

        NText {
          text: rootItem.pluginApi?.tr("settings.width-range")
          color: Color.mOnSurfaceVariant
          pointSize: Style.fontSizeS
        }
      }

      // Height setting
      RowLayout {
        spacing: Style.marginM

        NText {
          text: rootItem.pluginApi?.tr("settings.height")
          color: Color.mOnSurface
          pointSize: Style.fontSizeM
          Layout.preferredWidth: 120
        }

        NToggle {
          id: autoHeightToggle
          label: rootItem.pluginApi?.tr("settings.auto-height")
          checked: root.editAutoHeight
          onToggled: function(checked) {
            root.editAutoHeight = checked;
          }
        }

        NTextInput {
          id: heightInput
          Layout.preferredWidth: 100 * Style.uiScaleRatio
          Layout.preferredHeight: Style.baseWidgetSize
          Component.onCompleted: text = root.editWindowHeight > 0 ? root.editWindowHeight.toString() : "850"
          enabled: !autoHeightToggle.checked
          opacity: enabled ? 1.0 : 0.5

          onTextChanged: {
            var val = parseInt(text);
            if (!isNaN(val) && val >= 300 && val <= 2000) {
              root.editWindowHeight = val;
            }
          }
        }

        NText {
          text: rootItem.pluginApi?.tr("settings.height-range")
          color: Color.mOnSurfaceVariant
          pointSize: Style.fontSizeS
          opacity: autoHeightToggle.checked ? 0.5 : 1.0
        }
      }

      NText {
        Layout.fillWidth: true
        text: rootItem.pluginApi?.tr("settings.auto-height-hint")
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeS
        wrapMode: Text.WordWrap
      }
    }
  }

  // Column Count Settings
  NBox {
    Layout.fillWidth: true
    Layout.preferredHeight: columnContent.implicitHeight + Style.marginM * 2
    color: Color.mSurfaceVariant

    ColumnLayout {
      id: columnContent
      anchors.fill: parent
      anchors.margins: Style.marginM
      spacing: Style.marginS

      NText {
        Layout.fillWidth: true
        text: rootItem.pluginApi?.tr("settings.layout")
        pointSize: Style.fontSizeL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
      }

      RowLayout {
        spacing: Style.marginM

        NText {
          text: rootItem.pluginApi?.tr("settings.columns")
          color: Color.mOnSurface
          pointSize: Style.fontSizeM
        }

        NComboBox {
          id: columnCombo
          Layout.preferredWidth: 150 * Style.uiScaleRatio
          Layout.preferredHeight: Style.baseWidgetSize
          model: ListModel {
            ListElement { name: "1"; key: "1" }
            ListElement { name: "2"; key: "2" }
            ListElement { name: "3"; key: "3" }
            ListElement { name: "4"; key: "4" }
          }
          currentKey: root.editColumnCount.toString()
          onSelected: key => {
            root.editColumnCount = parseInt(key);
          }
        }
      }

      NText {
        Layout.fillWidth: true
        text: rootItem.pluginApi?.tr("settings.columns-hint")
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeS
        wrapMode: Text.WordWrap
      }
    }
  }

  // Config File Paths & Parsing
  NBox {
    Layout.fillWidth: true
    Layout.preferredHeight: pathsContent.implicitHeight + Style.marginM * 2
    color: Color.mSurfaceVariant

    ColumnLayout {
      id: pathsContent
      anchors.fill: parent
      anchors.margins: Style.marginM
      spacing: Style.marginM

      NText {
        Layout.fillWidth: true
        text: rootItem.pluginApi?.tr("settings.config-paths")
        pointSize: Style.fontSizeL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
      }

      NText {
        Layout.fillWidth: true
        text: rootItem.pluginApi?.tr("settings.config-paths-description")
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeS
        wrapMode: Text.WordWrap
      }

      // Mod key variable
      ColumnLayout {
        spacing: Style.marginXS

        RowLayout {
          spacing: Style.marginS
          NIcon {
            icon: "keyboard"
            pointSize: Style.fontSizeM
            color: Color.mOnSurface
          }
          NText {
            text: rootItem.pluginApi?.tr("settings.mod-var")
            color: Color.mOnSurface
            pointSize: Style.fontSizeM
            font.weight: Style.fontWeightBold
          }
        }

        NTextInput {
          id: modVarInput
          Layout.fillWidth: true
          Layout.preferredHeight: Style.baseWidgetSize
          text: root.editModKeyVariable
          placeholderText: "$mod"

          onTextChanged: {
            if (text.length > 0) root.editModKeyVariable = text;
          }
        }

        NText {
          Layout.fillWidth: true
          text: rootItem.pluginApi?.tr("settings.mod-var-hint")
          color: Color.mOnSurfaceVariant
          pointSize: Style.fontSizeXS
          wrapMode: Text.WordWrap
        }
      }

      Rectangle {
        Layout.preferredHeight: 1
        color: Color.mOutline
        opacity: 0.3
      }

      // Hyprland path
      ColumnLayout {
        spacing: Style.marginXS

        RowLayout {
          spacing: Style.marginS
          NIcon {
            icon: "terminal"
            pointSize: Style.fontSizeM
            color: Color.mPrimary
          }
          NText {
            text: rootItem.pluginApi?.tr("settings.hyprland-path")
            color: Color.mOnSurface
            pointSize: Style.fontSizeM
            font.weight: Style.fontWeightBold
          }
        }

        NTextInput {
          id: hyprlandPathInput
          Layout.fillWidth: true
          Layout.preferredHeight: Style.baseWidgetSize
          text: root.editHyprlandConfigPath
          placeholderText: "~/.config/hypr/hyprland.conf"

          onTextChanged: {
            if (text.length > 0) root.editHyprlandConfigPath = text;
          }
        }

        NText {
          Layout.fillWidth: true
          text: rootItem.pluginApi?.tr("settings.hyprland-format-hint")
          color: Color.mOnSurfaceVariant
          pointSize: Style.fontSizeXS
          wrapMode: Text.WordWrap
        }
      }

      // Hyprland Lua path + parser mode
      ColumnLayout {
        spacing: Style.marginXS

        RowLayout {
          spacing: Style.marginS
          NIcon {
            icon: "terminal"
            pointSize: Style.fontSizeM
            color: Color.mPrimary
          }
          NText {
            text: rootItem.pluginApi?.tr("settings.hyprland-lua-path")
            color: Color.mOnSurface
            pointSize: Style.fontSizeM
            font.weight: Style.fontWeightBold
          }
        }

        NTextInput {
          id: hyprlandLuaPathInput
          Layout.fillWidth: true
          Layout.preferredHeight: Style.baseWidgetSize
          text: root.editHyprlandLuaConfigPath
          placeholderText: "~/.config/hypr/hyprland.lua"

          onTextChanged: {
            if (text.length > 0) root.editHyprlandLuaConfigPath = text;
          }
        }

        RowLayout {
          spacing: Style.marginM
          NText {
            text: rootItem.pluginApi?.tr("settings.hyprland-parser-mode")
            color: Color.mOnSurface
            pointSize: Style.fontSizeM
          }
          NComboBox {
            id: parserModeCombo
            Layout.preferredWidth: 180 * Style.uiScaleRatio
            Layout.preferredHeight: Style.baseWidgetSize
            model: ListModel {
              ListElement { name: "Auto"; key: "auto" }
              ListElement { name: "Lua (hyprctl)"; key: "lua" }
              ListElement { name: "Legacy .conf"; key: "conf" }
            }
            currentKey: root.editHyprlandParserMode
            onSelected: key => { root.editHyprlandParserMode = key; }
          }
        }

        NText {
          Layout.fillWidth: true
          text: rootItem.pluginApi?.tr("settings.hyprland-lua-hint")
          color: Color.mOnSurfaceVariant
          pointSize: Style.fontSizeXS
          wrapMode: Text.WordWrap
        }
      }

      Rectangle {
        Layout.preferredHeight: 1
        color: Color.mOutline
        opacity: 0.3
      }

      // Niri path
      ColumnLayout {
        spacing: Style.marginXS

        RowLayout {
          spacing: Style.marginS
          NIcon {
            icon: "layout"
            pointSize: Style.fontSizeM
            color: Color.mSecondary
          }
          NText {
            text: rootItem.pluginApi?.tr("settings.niri-path")
            color: Color.mOnSurface
            pointSize: Style.fontSizeM
            font.weight: Style.fontWeightBold
          }
        }

        NTextInput {
          id: niriPathInput
          Layout.fillWidth: true
          Layout.preferredHeight: Style.baseWidgetSize
          text: root.editNiriConfigPath
          placeholderText: "~/.config/niri/config.kdl"

          onTextChanged: {
            if (text.length > 0) root.editNiriConfigPath = text;
          }
        }

        NText {
          Layout.fillWidth: true
          text: rootItem.pluginApi?.tr("settings.niri-format-hint")
          color: Color.mOnSurfaceVariant
          pointSize: Style.fontSizeXS
          wrapMode: Text.WordWrap
        }
      }
    }
  }

  // Undescribed / hidden binds (Hyprland lua tor)
  NBox {
    Layout.fillWidth: true
    Layout.preferredHeight: undescContent.implicitHeight + Style.marginM * 2
    color: Color.mSurfaceVariant

    ColumnLayout {
      id: undescContent
      anchors.fill: parent
      anchors.margins: Style.marginM
      spacing: Style.marginS

      function overrideCount(kind) {
        var o = rootItem.pluginApi?.pluginSettings?.bindOverrides || ({});
        var n = 0;
        for (var k in o) {
          if (kind === "hidden" && o[k] && o[k].hidden === true) n++;
          else if (kind === "desc" && o[k] && o[k].desc) n++;
        }
        return n;
      }

      NText {
        Layout.fillWidth: true
        text: rootItem.pluginApi?.tr("settings.undescribed-title")
        pointSize: Style.fontSizeL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
      }

      NToggle {
        label: rootItem.pluginApi?.tr("settings.show-undescribed")
        checked: root.editShowUndescribedBinds
        onToggled: function(checked) { root.editShowUndescribedBinds = checked; }
      }

      NText {
        Layout.fillWidth: true
        text: rootItem.pluginApi?.tr("settings.show-undescribed-hint")
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeXS
        wrapMode: Text.WordWrap
      }

      NText {
        Layout.fillWidth: true
        text: rootItem.pluginApi?.tr("settings.overrides-summary")
              .replace("{hidden}", undescContent.overrideCount("hidden"))
              .replace("{custom}", undescContent.overrideCount("desc"))
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeS
        wrapMode: Text.WordWrap
      }

      RowLayout {
        spacing: Style.marginM

        NButton {
          text: rootItem.pluginApi?.tr("settings.restore-hidden")
          icon: "eye"
          onClicked: {
            var o = rootItem.pluginApi?.pluginSettings?.bindOverrides || ({});
            var next = ({});
            for (var k in o) {
              var e = ({});
              if (o[k] && o[k].desc) e.desc = o[k].desc;
              if (Object.keys(e).length > 0) next[k] = e;
            }
            if (rootItem.pluginApi && rootItem.pluginApi.pluginSettings) {
              rootItem.pluginApi.pluginSettings.bindOverrides = next;
              rootItem.pluginApi.saveSettings();
              rootItem.pluginApi.mainInstance?.refresh();
            }
            ToastService.showNotice(rootItem.pluginApi?.tr("settings.restore-hidden-message"));
          }
        }

        NButton {
          text: rootItem.pluginApi?.tr("settings.clear-overrides")
          icon: "rotate"
          onClicked: {
            if (rootItem.pluginApi && rootItem.pluginApi.pluginSettings) {
              rootItem.pluginApi.pluginSettings.bindOverrides = ({});
              rootItem.pluginApi.saveSettings();
              rootItem.pluginApi.mainInstance?.refresh();
            }
            ToastService.showNotice(rootItem.pluginApi?.tr("settings.clear-overrides-message"));
          }
        }
      }
    }
  }

  // Reset and Refresh buttons
  NBox {
    Layout.fillWidth: true
    Layout.preferredHeight: actionsContent.implicitHeight + Style.marginM * 2
    color: Color.mSurfaceVariant

    ColumnLayout {
      id: actionsContent
      anchors.fill: parent
      anchors.margins: Style.marginM
      spacing: Style.marginM

      NText {
        Layout.fillWidth: true
        text: rootItem.pluginApi?.tr("settings.actions")
        pointSize: Style.fontSizeL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
      }

      RowLayout {
        spacing: Style.marginM

        NButton {
          text: rootItem.pluginApi?.tr("settings.refresh-keybinds")
          icon: "refresh"
          onClicked: {
            rootItem.pluginApi?.mainInstance?.refresh();
            ToastService.showNotice(
              rootItem.pluginApi?.tr("settings.refresh-message")
            );
          }
        }

        NButton {
          text: rootItem.pluginApi?.tr("settings.reset-defaults")
          icon: "rotate"
          onClicked: {
            root.editWindowWidth = defaults.windowWidth || 1400;
            root.editWindowHeight = defaults.windowHeight || 0;
            root.editAutoHeight = defaults.autoHeight ?? true;
            root.editColumnCount = defaults.columnCount || 3;
            root.editModKeyVariable = defaults.modKeyVariable || "$mod";
            root.editHyprlandConfigPath = defaults.hyprlandConfigPath || "~/.config/hypr/hyprland.conf";
            root.editHyprlandLuaConfigPath = defaults.hyprlandLuaConfigPath || "~/.config/hypr/hyprland.lua";
            root.editHyprlandParserMode = defaults.hyprlandParserMode || "auto";
            root.editShowUndescribedBinds = defaults.showUndescribedBinds ?? true;
            root.editNiriConfigPath = defaults.niriConfigPath || "~/.config/niri/config.kdl";

            widthInput.text = root.editWindowWidth.toString();
            heightInput.text = "850";
            modVarInput.text = root.editModKeyVariable;
            hyprlandPathInput.text = root.editHyprlandConfigPath;
            hyprlandLuaPathInput.text = root.editHyprlandLuaConfigPath;
            niriPathInput.text = root.editNiriConfigPath;

            if (rootItem.pluginApi && rootItem.pluginApi.pluginSettings) {
              rootItem.pluginApi.pluginSettings.cheatsheetData = [];
              rootItem.pluginApi.saveSettings();
            }

            ToastService.showNotice(
              rootItem.pluginApi?.tr("settings.reset-message")
            );
          }
        }
      }
    }
  }

  // Keybind Command Info
  NBox {
    Layout.fillWidth: true
    Layout.preferredHeight: keybindContent.implicitHeight + Style.marginM * 2
    color: Color.mSurfaceVariant

    ColumnLayout {
      id: keybindContent
      anchors.fill: parent
      anchors.margins: Style.marginM
      spacing: Style.marginS

      NText {
        Layout.fillWidth: true
        text: rootItem.pluginApi?.tr("settings.keybind-setup")
        pointSize: Style.fontSizeL
        font.weight: Style.fontWeightBold
        color: Color.mOnSurface
      }

      NText {
        Layout.fillWidth: true
        text: rootItem.pluginApi?.tr("settings.keybind-setup-description")
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeS
        wrapMode: Text.WordWrap
      }

      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: commandText.implicitHeight + Style.marginS * 2
        color: Color.mSurface
        radius: Style.radiusS

        NText {
          id: commandText
          anchors.fill: parent
          anchors.margins: Style.marginS
          text: "qs -c \"noctalia-shell\" ipc call plugin:keybind-cheatsheet toggle"
          font.family: "monospace"
          pointSize: Style.fontSizeS
          color: Color.mPrimary
          wrapMode: Text.WrapAnywhere
        }
      }

      NText {
        Layout.fillWidth: true
        text: rootItem.pluginApi?.tr("settings.keybind-example-hyprland")
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeXS
        wrapMode: Text.WordWrap
      }

      NText {
        Layout.fillWidth: true
        text: rootItem.pluginApi?.tr("settings.keybind-example-niri")
        color: Color.mOnSurfaceVariant
        pointSize: Style.fontSizeXS
        wrapMode: Text.WordWrap
      }
    }
  }

  // Bottom spacing
  Item {
    Layout.preferredHeight: Style.marginL
  }

  }  // end ColumnLayout

  // Save function on rootItem so the shell can call component.saveSettings()
  function saveSettings() {
    if (!pluginApi) return;
    pluginApi.pluginSettings.windowWidth = root.editWindowWidth;
    pluginApi.pluginSettings.windowHeight = root.editWindowHeight;
    pluginApi.pluginSettings.autoHeight = root.editAutoHeight;
    pluginApi.pluginSettings.columnCount = root.editColumnCount;
    pluginApi.pluginSettings.modKeyVariable = root.editModKeyVariable;
    pluginApi.pluginSettings.hyprlandConfigPath = root.editHyprlandConfigPath;
    pluginApi.pluginSettings.hyprlandLuaConfigPath = root.editHyprlandLuaConfigPath;
    pluginApi.pluginSettings.hyprlandParserMode = root.editHyprlandParserMode;
    pluginApi.pluginSettings.showUndescribedBinds = root.editShowUndescribedBinds;
    pluginApi.pluginSettings.niriConfigPath = root.editNiriConfigPath;
    pluginApi.saveSettings();
    ToastService.showNotice(
      pluginApi?.tr("settings.saved")
    );
  }
}
