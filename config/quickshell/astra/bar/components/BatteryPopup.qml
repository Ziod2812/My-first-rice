import QtQuick
import Quickshell
import Quickshell.Wayland
import qs

PanelWindow {
    id: root

    visible: false

    property var batteryService: null

    signal closed()

    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    Theme {
        id: theme
    }

    Rectangle {
        id: popupCard

        width: 340
        height: contentColumn.implicitHeight + 40

        anchors {
            top: parent.top
            right: parent.right
            topMargin: 48
            rightMargin: 12
        }

        radius: 16

        color: Qt.rgba(
            theme.surface.r,
            theme.surface.g,
            theme.surface.b,
            0.96
        )

        border.width: 1

        border.color: Qt.rgba(
            theme.outline.r,
            theme.outline.g,
            theme.outline.b,
            0.30
        )

        Column {
            id: contentColumn

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 20
            }

            spacing: 14

            Row {
                width: parent.width
                spacing: 12

                Rectangle {
                    width: 46
                    height: 46
                    radius: 13

                    color: Qt.rgba(
                        theme.primary.r,
                        theme.primary.g,
                        theme.primary.b,
                        0.16
                    )

                    Text {
                        anchors.centerIn: parent

                        text: "󰁹"

                        color: theme.primary

                        font.family:
                            "Symbols Nerd Font"

                        font.pixelSize: 25
                    }
                }

                Column {
                    anchors.verticalCenter:
                        parent.verticalCenter

                    spacing: 2

                    Text {
                        text: "Battery"

                        color: theme.text

                        font.family:
                            "JetBrainsMono Nerd Font"

                        font.pixelSize: 15

                        font.weight:
                            Font.DemiBold
                    }

                    Text {
                        text: {
                            if (
                                !root.batteryService ||
                                !root.batteryService.available
                            )
                                return "Battery not detected"

                            return root.batteryService.status
                        }

                        color: theme.textSecondary

                        font.family:
                            "JetBrainsMono Nerd Font"

                        font.pixelSize: 10
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1

                color: Qt.rgba(
                    theme.outline.r,
                    theme.outline.g,
                    theme.outline.b,
                    0.18
                )
            }

            Column {
                width: parent.width
                spacing: 10

                Text {
                    text: {
                        if (
                            !root.batteryService ||
                            !root.batteryService.available
                        )
                            return "--"

                        return root.batteryService.percentage + "%"
                    }

                    color: theme.text

                    font.family:
                        "JetBrainsMono Nerd Font"

                    font.pixelSize: 30

                    font.weight:
                        Font.DemiBold
                }

                Rectangle {
                    width: parent.width
                    height: 7

                    radius: 4

                    color: Qt.rgba(
                        theme.outline.r,
                        theme.outline.g,
                        theme.outline.b,
                        0.18
                    )

                    Rectangle {
                        width:
                            parent.width *
                            (
                                root.batteryService &&
                                root.batteryService.available
                                    ? root.batteryService.percentage / 100
                                    : 0
                            )

                        height: parent.height

                        radius: parent.radius

                        color: {
                            if (
                                root.batteryService &&
                                root.batteryService.percentage <= 15
                            )
                                return "#F38BA8"

                            if (
                                root.batteryService &&
                                (
                                    root.batteryService.status === "Charging" ||
                                    root.batteryService.status === "Full"
                                )
                            )
                                return "#A6E3A1"

                            return theme.primary
                        }

                        Behavior on width {
                            NumberAnimation {
                                duration: 300
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1

                color: Qt.rgba(
                    theme.outline.r,
                    theme.outline.g,
                    theme.outline.b,
                    0.18
                )
            }

            Column {
                width: parent.width
                spacing: 8

                Text {
                    text: "Battery information"

                    color: theme.text

                    font.family:
                        "JetBrainsMono Nerd Font"

                    font.pixelSize: 11

                    font.weight:
                        Font.DemiBold
                }

                InfoRow {
                    label: "Health"
                    value: {
                        if (
                            !root.batteryService ||
                            root.batteryService.batteryHealth < 0
                        )
                            return "--"

                        return Math.round(
                            root.batteryService.batteryHealth
                        ) + "%"
                    }
                }

                InfoRow {
                    label: "Cycle count"
                    value: {
                        if (
                            !root.batteryService ||
                            root.batteryService.cycleCount < 0
                        )
                            return "--"

                        return String(
                            root.batteryService.cycleCount
                        )
                    }
                }

                InfoRow {
                    label: "Current"
                    value: {
                        if (
                            !root.batteryService ||
                            !root.batteryService.available
                        )
                            return "--"

                        if (
                            root.batteryService.energyNow >= 0
                        ) {
                            return (
                                root.batteryService.energyNow.toFixed(2) +
                                " Wh"
                            )
                        }

                        if (
                            root.batteryService.chargeNow >= 0
                        ) {
                            return (
                                root.batteryService.chargeNow.toFixed(2) +
                                " Ah"
                            )
                        }

                        return "--"
                    }
                }

                InfoRow {
                    label: "Full capacity"
                    value: {
                        if (
                            !root.batteryService ||
                            !root.batteryService.available
                        )
                            return "--"

                        if (
                            root.batteryService.energyFull >= 0
                        ) {
                            return (
                                root.batteryService.energyFull.toFixed(2) +
                                " Wh"
                            )
                        }

                        if (
                            root.batteryService.chargeFull >= 0
                        ) {
                            return (
                                root.batteryService.chargeFull.toFixed(2) +
                                " Ah"
                            )
                        }

                        return "--"
                    }
                }

                InfoRow {
                    label: "Design capacity"
                    value: {
                        if (
                            !root.batteryService ||
                            !root.batteryService.available
                        )
                            return "--"

                        if (
                            root.batteryService.energyFullDesign >= 0
                        ) {
                            return (
                                root.batteryService.energyFullDesign.toFixed(2) +
                                " Wh"
                            )
                        }

                        if (
                            root.batteryService.chargeFullDesign >= 0
                        ) {
                            return (
                                root.batteryService.chargeFullDesign.toFixed(2) +
                                " Ah"
                            )
                        }

                        return "--"
                    }
                }

                InfoRow {
                    label: "Power"
                    value: {
                        if (
                            !root.batteryService ||
                            root.batteryService.powerNow < 0
                        )
                            return "--"

                        return (
                            root.batteryService.powerNow.toFixed(2) +
                            " W"
                        )
                    }
                }

                InfoRow {
                    label: "Voltage"
                    value: {
                        if (
                            !root.batteryService ||
                            root.batteryService.voltageNow < 0
                        )
                            return "--"

                        return (
                            root.batteryService.voltageNow.toFixed(2) +
                            " V"
                        )
                    }
                }

                InfoRow {
                    label: "Technology"
                    value: {
                        if (
                            !root.batteryService ||
                            root.batteryService.technology.length === 0
                        )
                            return "--"

                        return root.batteryService.technology
                    }
                }

                InfoRow {
                    label: "Manufacturer"
                    value: {
                        if (
                            !root.batteryService ||
                            root.batteryService.manufacturer.length === 0
                        )
                            return "--"

                        return root.batteryService.manufacturer
                    }
                }

                InfoRow {
                    label: "Model"
                    value: {
                        if (
                            !root.batteryService ||
                            root.batteryService.modelName.length === 0
                        )
                            return "--"

                        return root.batteryService.modelName
                    }
                }

                InfoRow {
                    label: "Charge mode"
                    value: {
                        if (
                            !root.batteryService ||
                            root.batteryService.chargeTypes.length === 0
                        )
                            return "--"

                        return root.batteryService.chargeTypes
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 34

                radius: 9

                color: closeMouseArea.containsMouse
                    ? Qt.rgba(
                        theme.primary.r,
                        theme.primary.g,
                        theme.primary.b,
                        0.18
                    )
                    : Qt.rgba(
                        theme.surfaceContainer.r,
                        theme.surfaceContainer.g,
                        theme.surfaceContainer.b,
                        0.45
                    )

                border.width:
                    closeMouseArea.containsMouse
                        ? 1
                        : 0

                border.color:
                    Qt.rgba(
                        theme.primary.r,
                        theme.primary.g,
                        theme.primary.b,
                        0.35
                    )

                Text {
                    anchors.centerIn: parent

                    text: "Close"

                    color: theme.text

                    font.family:
                        "JetBrainsMono Nerd Font"

                    font.pixelSize: 10
                }

                MouseArea {
                    id: closeMouseArea

                    anchors.fill: parent

                    hoverEnabled: true

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked: {
                        root.visible = false
                        root.closed()
                    }
                }
            }
        }
    }

    MouseArea {
        id: outsideMouseArea

        anchors.fill: parent

        z: -1

        acceptedButtons:
            Qt.LeftButton

        onClicked: {
            root.visible = false
            root.closed()
        }
    }

    component InfoRow: Row {
        width: contentColumn.width

        spacing: 8

        property string label: ""
        property string value: ""

        Text {
            width: 115

            text: parent.label

            color: theme.textSecondary

            font.family:
                "JetBrainsMono Nerd Font"

            font.pixelSize: 10
        }

        Text {
            width:
                parent.width -
                115 -
                parent.spacing

            text: parent.value

            color: theme.text

            horizontalAlignment:
                Text.AlignRight

            elide:
                Text.ElideRight

            font.family:
                "JetBrainsMono Nerd Font"

            font.pixelSize: 10
        }
    }
}