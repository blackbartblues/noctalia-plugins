import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root

    readonly property int labelPadding: 15

    property var pluginApi:             null

    readonly property var cfg:          pluginApi?.pluginSettings                               || ({})
    readonly property var defaults:     pluginApi?.manifest?.metadata?.defaultSettings          || ({})

    property string arrowType:          cfg.arrowType           || defaults.arrowType           || "arrow"
    property int  minWidth:             cfg.minWidth            || defaults.minWidth            || 0

    property color colorSilent:         cfg.colorSilent         || defaults.colorSilent         || Color.mSurfaceVariant
    property color colorTx:             cfg.colorTx             || defaults.colorTx             || Color.mSecondary
    property color colorRx:             cfg.colorRx             || defaults.colorRx             || Color.mPrimary
    property color colorText:           cfg.colorText           || defaults.colorText           || Qt.alpha(Color.mOnSurfaceVariant, 0.3)

    property int  byteThresholdActive:  cfg.byteThresholdActive || defaults.byteThresholdActive || 1024
    property real fontSizeModifier:     cfg.fontSizeModifier    || defaults.fontSizeModifier    || 0.75
    property real iconSizeModifier:     cfg.iconSizeModifier    || defaults.iconSizeModifier    || 1.0
    property real spacingInbetween:     cfg.spacingInbetween    || defaults.spacingInbetween    || 1.0

    spacing: Style.marginL

    Component.onCompleted: {
        Logger.i("NetworkIndicator", "Settings UI loaded")
    }

    function toIntOr(defaultValue, text) {
        const v = parseInt(String(text).trim(), 10)
        return isNaN(v) ? defaultValue : v
    }

    // ---------- Basic numeric settings ----------

    RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginS

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Style.marginS

            NTextInput {
                Layout.fillWidth: true
                description: "Minimum Widget Width"
                placeholderText: String(root.minWidth)
                text: String(root.minWidth)
                onTextChanged: root.minWidth = root.toIntOr(0, text)
            }

            NTextInput {
                Layout.fillWidth: true
                description: "Threshold in bytes to show as active"
                placeholderText: root.byteThresholdActive + " bytes"
                text: String(root.byteThresholdActive)
                onTextChanged: root.byteThresholdActive = root.toIntOr(0, text)
            }
        }
    }

    // ---------- Sliders: font/icon size + spacing ----------

    RowLayout {
        Layout.fillWidth: true
        spacing: Style.marginS

        // Font size modifier
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Style.marginS

            Text {
                text: ("Font size modifier: {value}")
                      .replace("{value}", fontSizeModifierSlider.value.toFixed(2))
                color: Color.mOnSurfaceVariant
                font.pointSize: Style.fontSizeS
                font.weight: Font.Bold
            }

            NSlider {
                Layout.fillWidth: true
                id: fontSizeModifierSlider
                from: 0.5
                to: 1.0
                value: root.fontSizeModifier
                stepSize: 0.05
                onValueChanged: root.fontSizeModifier = value
            }
        }

        // Icon size modifier
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Style.marginS

            Text {
                text: ("Icon size modifier: {value}")
                      .replace("{value}", iconSizeModifierSlider.value.toFixed(2))
                color: Color.mOnSurfaceVariant
                font.pointSize: Style.fontSizeS
                font.weight: Font.Bold
            }

            NSlider {
                Layout.fillWidth: true
                id: iconSizeModifierSlider
                from: 0.5
                to: 1.25
                value: root.iconSizeModifier
                stepSize: 0.05
                onValueChanged: root.iconSizeModifier = value
            }
        }

        // Spacing between RX/TX
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Style.marginS

            Text {
                text: ("Spacing inbetween RX/TX: {value}")
                      .replace("{value}", spacingInbetweenSlider.value.toFixed(0))
                color: Color.mOnSurfaceVariant
                font.pointSize: Style.fontSizeS
                font.weight: Font.Bold
            }

            NSlider {
                Layout.fillWidth: true
                id: spacingInbetweenSlider
                from: -5
                to: 5
                value: root.spacingInbetween
                stepSize: 1
                onValueChanged: root.spacingInbetween = value
            }
        }
    }

    // ---------- Color settings ----------

    ColumnLayout {
        id: colorPanel

        Layout.fillWidth: true
        spacing: Style.marginS

        NLabel {
            label: "Coloring"
        }

        // TX / RX icon colors
        RowLayout {
            spacing: Style.marginS

            NLabel {
                Layout.fillWidth: true
                label: "Icon TX".padStart(root.labelPadding, " ")
            }

            NColorPicker {
                Layout.preferredWidth: Style.sliderWidth
                Layout.preferredHeight: Style.baseWidgetSize
                selectedColor: root.colorTx
                onColorSelected: function (color) {
                    root.colorTx = color
                }
            }

            NLabel {
                Layout.fillWidth: true
                label: "Icon RX".padStart(root.labelPadding, " ")
            }

            NColorPicker {
                Layout.preferredWidth: Style.sliderWidth
                Layout.preferredHeight: Style.baseWidgetSize
                selectedColor: root.colorRx
                onColorSelected: function (color) {
                    root.colorRx = color
                }
            }
        }

        // Inactive icon / value text colors
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginS

            NLabel {
                Layout.fillWidth: true
                label: "Icons Inactive".padStart(root.labelPadding, " ")
            }

            NColorPicker {
                Layout.preferredWidth: Style.sliderWidth
                Layout.preferredHeight: Style.baseWidgetSize
                selectedColor: root.colorSilent
                onColorSelected: function (color) {
                    root.colorSilent = color
                }
            }

            NLabel {
                Layout.fillWidth: true
                label: "Values".padStart(root.labelPadding, " ")
            }

            NColorPicker {
                Layout.preferredWidth: Style.sliderWidth
                Layout.preferredHeight: Style.baseWidgetSize
                selectedColor: root.colorText
                onColorSelected: function (color) {
                    root.colorText = color
                }
            }
        }
    }

    // ---------- Icon type ----------

    NComboBox {
      Layout.fillWidth: true
      label: "Icon type"
      model: [
        { "key": "arrow", "name": "arrow" },
        { "key": "arrow-narrow", "name": "arrow-narrow" },
        { "key": "caret", "name": "caret" },
        { "key": "chevron", "name": "chevron" },
      ]
      currentKey: root.arrowType
      onSelected: key => root.arrowType = key
    }

    function saveSettings() {
        if (!pluginApi) {
            Logger.e("NetworkIndicator", "Cannot save settings: pluginApi is null")
            return
        }

        pluginApi.pluginSettings.arrowType              = root.arrowType

        pluginApi.pluginSettings.minWidth               = root.minWidth
        pluginApi.pluginSettings.byteThresholdActive    = root.byteThresholdActive
        pluginApi.pluginSettings.fontSizeModifier       = root.fontSizeModifier
        pluginApi.pluginSettings.iconSizeModifier       = root.iconSizeModifier
        pluginApi.pluginSettings.spacingInbetween       = root.spacingInbetween

        pluginApi.pluginSettings.colorSilent            = root.colorSilent.toString()
        pluginApi.pluginSettings.colorTx                = root.colorTx.toString()
        pluginApi.pluginSettings.colorRx                = root.colorRx.toString()
        pluginApi.pluginSettings.colorText              = root.colorText.toString()

        pluginApi.saveSettings()

        Logger.i("NetworkIndicator", "Settings saved successfully")
    }
}
