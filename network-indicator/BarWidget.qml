import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services.System

Rectangle {
    id: root

    property var pluginApi: null

    property ShellScreen screen
    property string widgetId: ""
    property string section: ""

    // Plugin configuration
    readonly property var cfg:      pluginApi?.pluginSettings                      || ({})
    readonly property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

    readonly property color  bgColor:               cfg.backgroundColor     || defaults.backgroundColor         || "transparent"

    readonly property string arrowType:             cfg.arrowType           || defaults.arrowType               || "arrow"
    readonly property int    minWidth:              cfg.minWidth            || defaults.minWidth                || 0

    readonly property color  colorSilent:           cfg.colorSilent         || defaults.colorSilent             || Color.mSurfaceVariant
    readonly property color  colorTx:               cfg.colorTx             || defaults.colorTx                 || Color.mSecondary
    readonly property color  colorRx:               cfg.colorRx             || defaults.colorRx                 || Color.mPrimary
    readonly property color  colorText:             cfg.colorText           || defaults.colorText               || Qt.alpha(Color.mOnSurfaceVariant, 0.3)

    readonly property int    byteThresholdActive:   cfg.byteThresholdActive || defaults.byteThresholdActive     || 1024
    readonly property real   fontSizeModifier:      cfg.fontSizeModifier    || defaults.fontSizeModifier        || 0.75
    readonly property real   iconSizeModifier:      cfg.iconSizeModifier    || defaults.iconSizeModifier        || 1.0
    readonly property real   spacingInbetween:      cfg.spacingInbetween    || defaults.spacingInbetween        || 0.0

    // Bar positioning properties
    readonly property string barPosition: Settings.data.bar.position || "top"
    readonly property bool   barIsVertical: barPosition === "left" || barPosition === "right"

    implicitWidth:  barIsVertical
                    ? Style.barHeight
                    : Math.max(contentRow.implicitWidth, minWidth)
    implicitHeight: Style.barHeight

    color: bgColor
    radius: !barIsVertical ? Style.radiusM : width * 0.5

    // Widget
    property real txSpeed: SystemStatService.txSpeed
    property real rxSpeed: SystemStatService.rxSpeed

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: Style.marginS

        Column {
            spacing: root.spacingInbetween

            NText {
                visible: true
                text: convertBytes(root.txSpeed)
                color: root.colorText
                pointSize: Style.fontSizeS * root.fontSizeModifier
                font.weight: Font.Medium
                horizontalAlignment: Text.AlignLeft
            }

            NText {
                visible: true
                text: convertBytes(root.rxSpeed)
                color: root.colorText
                pointSize: Style.fontSizeS * root.fontSizeModifier
                font.weight: Font.Medium
                horizontalAlignment: Text.AlignLeft
            }
        }

        Column {
            spacing: -10.0 + root.spacingInbetween

            NIcon {
                icon: arrowType + "-up"
                color: root.txSpeed > root.byteThresholdActive
                       ? root.colorTx
                       : root.colorSilent
                pointSize: Style.fontSizeL * root.iconSizeModifier
            }

            NIcon {
                icon: arrowType + "-down"
                color: root.rxSpeed > root.byteThresholdActive
                       ? root.colorRx
                       : root.colorSilent
                pointSize: Style.fontSizeL * root.iconSizeModifier
            }
        }
    }

    // Mouse area to open panel
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onEntered:  root.color = Qt.lighter(root.bgColor, 1.1)
        onExited:   root.color = root.bgColor

        onClicked: {
            if (pluginApi) {
                Logger.i("NetworkIndicator", "Opening Panel for Network Indicator, maybe soon ...")
                pluginApi.openPanel(root.screen)
            }
        }
    }

    function convertBytes(bytesPerSecond) {
        const KB = 1024
        const MB = KB * 1024

        let value
        let unit

        if (bytesPerSecond < MB) {
            value = bytesPerSecond / KB
            unit = "KB"
        } else {
            value = bytesPerSecond / MB
            unit = "MB"
        }

        const text = value.toFixed(1) + " " + unit
        return text.padStart(9, " ")
    }
}
