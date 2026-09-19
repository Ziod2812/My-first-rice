import QtQuick

QtObject {
    id: theme

    readonly property color background: "#1E1E2E"
    readonly property color surface: "#313244"
    readonly property color surfaceVariant: "#444B6A"
    readonly property color surfaceContainer: "#313244"
    readonly property color surfaceContainerLow: "#1A1B26"
    readonly property color surfaceContainerHigh: "#444B6A"

    readonly property color text: "#CDD6F4"
    readonly property color textSecondary: "#A6ADC8"

    readonly property color primary: "#CBA6F7"
    readonly property color primaryContainer: "#5B4B73"
    readonly property color primaryText: "#1E1E2E"

    readonly property color secondary: "#89B4FA"
    readonly property color secondaryContainer: "#3B4F73"
    readonly property color secondaryText: "#1E1E2E"

    readonly property color tertiary: "#7AA2F7"
    readonly property color tertiaryContainer: "#3D4F7A"
    readonly property color tertiaryText: "#1E1E2E"

    readonly property color success: "#A6E3A1"
    readonly property color error: "#F38BA8"
    readonly property color warning: "#F9E2AF"

    readonly property color outline: "#6C7086"
    readonly property color outlineVariant: "#45475A"
    readonly property color shadow: "#000000"

    readonly property color mauve: primary
    readonly property color blue: secondary
    readonly property color cyan: tertiary
    readonly property color green: success
    readonly property color red: error

    readonly property color glass: Qt.rgba(
        surface.r,
        surface.g,
        surface.b,
        0.82
    )

    readonly property color glassStrong: Qt.rgba(
        surfaceContainer.r,
        surfaceContainer.g,
        surfaceContainer.b,
        0.92
    )

    readonly property color glassBorder: Qt.rgba(
        outline.r,
        outline.g,
        outline.b,
        0.35
    )

    readonly property int radiusSmall: 8
    readonly property int radiusMedium: 12
    readonly property int radiusLarge: 16
    readonly property int radiusXLarge: 20

    readonly property int spacingSmall: 6
    readonly property int spacingMedium: 10
    readonly property int spacingLarge: 14
    readonly property int spacingXLarge: 18

    readonly property int borderWidth: 1
}