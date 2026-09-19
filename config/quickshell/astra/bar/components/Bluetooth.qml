import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs
import qs.services

Item {
    id: root

    width: 26
    height: 26

    implicitWidth: 26
    implicitHeight: 26

    property bool popupVisible: false
    property bool cursorInside: false

    Theme {
        id: theme
    }

    function closePopup() {
        autoCloseTimer.stop()
        root.cursorInside = false
        root.popupVisible = false
    }

    function restartAutoCloseTimer() {
        if (root.cursorInside) {
            autoCloseTimer.stop()
            return
        }

        autoCloseTimer.restart()
    }

    Rectangle {
        id: bluetoothButton

        anchors.fill: parent

        radius: 7

        color:
            buttonMouse.containsMouse
            ? Qt.rgba(
                theme.surfaceContainer.r,
                theme.surfaceContainer.g,
                theme.surfaceContainer.b,
                0.55
            )
            : "transparent"

        border.width:
            buttonMouse.containsMouse
            ? 1
            : 0

        border.color:
            Qt.rgba(
                0,
                0,
                0,
                buttonMouse.containsMouse
                ? 0.28
                : 0
            )

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }

        Behavior on border.width {
            NumberAnimation {
                duration: 120
            }
        }

        Text {
            anchors.centerIn: parent

            width: 26
            height: 26

            text:
                !BluetoothService.available
                ? "󰂲"
                : !BluetoothService.enabled
                ? "󰂲"
                : BluetoothService.connectedDeviceCount > 0
                ? "󰂱"
                : "󰂯"

            color:
                !BluetoothService.available
                ? theme.textSecondary
                : !BluetoothService.enabled
                ? theme.error
                : BluetoothService.connectedDeviceCount > 0
                ? theme.primary
                : "#FFFFFF"

            font.family:
                "Symbols Nerd Font"

            font.pixelSize: 15

            font.weight:
                Font.Normal

            horizontalAlignment:
                Text.AlignHCenter

            verticalAlignment:
                Text.AlignVCenter

            Behavior on color {
                ColorAnimation {
                    duration: 180
                }
            }
        }

        MouseArea {
            id: buttonMouse

            anchors.fill: parent

            hoverEnabled: true

            cursorShape:
                Qt.PointingHandCursor

            acceptedButtons:
                Qt.LeftButton

            onClicked: {
                root.popupVisible =
                    !root.popupVisible

                if (root.popupVisible)
                    root.restartAutoCloseTimer()
                else
                    root.closePopup()
            }
        }
    }

    Timer {
        id: autoCloseTimer

        interval: 5000
        repeat: false

        onTriggered: {
            if (!root.cursorInside)
                root.closePopup()
        }
    }

    PanelWindow {
        id: popup

        visible:
            root.popupVisible

        focusable: true

        WlrLayershell.keyboardFocus:
            WlrKeyboardFocus.OnDemand

        color: "transparent"

        anchors {
            top: true
            right: true
            bottom: true
            left: true
        }

        WlrLayershell.exclusiveZone: -1

        MouseArea {
            id: outsideMouseArea

            anchors.fill: parent

            onClicked: {
                root.closePopup()
            }
        }

        Rectangle {
            id: popupBackground

            width: 340
            height: 500

            anchors {
                top: parent.top
                right: parent.right
            }

            anchors.topMargin: 48
            anchors.rightMargin: 12

            radius: 18

            color:
                Qt.rgba(
                    theme.background.r,
                    theme.background.g,
                    theme.background.b,
                    0.97
                )

            border.width: 1

            border.color:
                Qt.rgba(
                    theme.outline.r,
                    theme.outline.g,
                    theme.outline.b,
                    0.30
                )

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    mouse.accepted = true
                }
            }

            HoverHandler {
                onHoveredChanged: {
                    root.cursorInside = hovered

                    if (hovered)
                        autoCloseTimer.stop()
                    else
                        root.restartAutoCloseTimer()
                }
            }

            Column {
                anchors.fill: parent

                anchors.margins: 14

                spacing: 10

                Row {
                    width: parent.width
                    height: 34

                    spacing: 8

                    Column {
                        width:
                            parent.width - 42

                        height: 34

                        spacing: 1

                        Text {
                            text: "Bluetooth"

                            color: "#FFFFFF"

                            font.family:
                                "JetBrainsMono Nerd Font"

                            font.pixelSize: 14

                            font.weight:
                                Font.DemiBold
                        }

                        Text {
                            text:
                                !BluetoothService.available
                                ? "Unavailable"
                                : !BluetoothService.enabled
                                ? "Disabled"
                                : BluetoothService.connectedDeviceCount > 0
                                ? BluetoothService.connectedDeviceCount +
                                  " connected"
                                : BluetoothService.scanning
                                ? "Scanning..."
                                : "Ready"

                            color:
                                !BluetoothService.available ||
                                !BluetoothService.enabled
                                ? theme.error
                                : BluetoothService.connectedDeviceCount > 0
                                ? theme.success
                                : theme.textSecondary

                            font.family:
                                "JetBrainsMono Nerd Font"

                            font.pixelSize: 8
                        }
                    }

                    Rectangle {
                        width: 34
                        height: 34

                        radius: 10

                        color:
                            BluetoothService.enabled
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
                                0.55
                            )

                        Text {
                            anchors.centerIn: parent

                            width: 34
                            height: 34

                            text:
                                BluetoothService.enabled
                                ? "󰂯"
                                : "󰂲"

                            color:
                                BluetoothService.enabled
                                ? theme.primary
                                : theme.error

                            font.family:
                                "Symbols Nerd Font"

                            font.pixelSize: 16

                            horizontalAlignment:
                                Text.AlignHCenter

                            verticalAlignment:
                                Text.AlignVCenter
                        }

                        MouseArea {
                            anchors.fill: parent

                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked: {
                                BluetoothService.toggleBluetooth()
                                root.restartAutoCloseTimer()
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1

                    color:
                        Qt.rgba(
                            theme.outline.r,
                            theme.outline.g,
                            theme.outline.b,
                            0.16
                        )
                }

                Rectangle {
                    width: parent.width
                    height: 58

                    radius: 12

                    color:
                        Qt.rgba(
                            theme.surfaceContainer.r,
                            theme.surfaceContainer.g,
                            theme.surfaceContainer.b,
                            0.70
                        )

                    Row {
                        anchors.fill: parent

                        anchors.leftMargin: 12
                        anchors.rightMargin: 12

                        spacing: 10

                        Text {
                            anchors.verticalCenter:
                                parent.verticalCenter

                            width: 20

                            text:
                                BluetoothService.connectedDeviceCount > 0
                                ? "󰂱"
                                : "󰂯"

                            color:
                                BluetoothService.connectedDeviceCount > 0
                                ? theme.success
                                : theme.textSecondary

                            font.family:
                                "Symbols Nerd Font"

                            font.pixelSize: 20

                            horizontalAlignment:
                                Text.AlignHCenter
                        }

                        Column {
                            anchors.verticalCenter:
                                parent.verticalCenter

                            width:
                                parent.width - 42

                            spacing: 3

                            Text {
                                width: parent.width

                                text:
                                    BluetoothService.connectedDevice
                                    ? BluetoothService.deviceName(
                                        BluetoothService.connectedDevice
                                    )
                                    : "Not connected"

                                color: "#FFFFFF"

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                font.pixelSize: 11

                                font.weight:
                                    Font.Medium

                                elide:
                                    Text.ElideRight
                            }

                            Text {
                                text:
                                    BluetoothService.connectedDevice
                                    ? "Bluetooth connection active"
                                    : "No active connection"

                                color: "#FFFFFF"

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                font.pixelSize: 8
                            }
                        }
                    }
                }

                Row {
                    width: parent.width
                    height: 24

                    Text {
                        id: deviceLabel

                        anchors.verticalCenter:
                            parent.verticalCenter

                        text: "Devices"

                        color: "#FFFFFF"

                        font.family:
                            "JetBrainsMono Nerd Font"

                        font.pixelSize: 9
                    }

                    Item {
                        width:
                            Math.max(
                                0,
                                parent.width -
                                deviceLabel.implicitWidth -
                                deviceCountLabel.implicitWidth -
                                8
                            )

                        height: 1
                    }

                    Text {
                        id: deviceCountLabel

                        anchors.verticalCenter:
                            parent.verticalCenter

                        text:
                            BluetoothService.deviceCount +
                            " devices"

                        color: "#FFFFFF"

                        font.family:
                            "JetBrainsMono Nerd Font"

                        font.pixelSize: 8
                    }
                }

                Flickable {
                    id: deviceFlickable

                    width: parent.width

                    height: 264

                    contentWidth: width

                    contentHeight:
                        deviceColumn.implicitHeight

                    clip: true

                    boundsBehavior:
                        Flickable.StopAtBounds

                    ScrollBar.vertical:
                        ScrollBar {
                            policy:
                                ScrollBar.AsNeeded
                        }

                    Column {
                        id: deviceColumn

                        width:
                            deviceFlickable.width

                        spacing: 5

                        Repeater {
                            model:
                                BluetoothService.devices

                            delegate: Rectangle {
                                required property var modelData

                                width:
                                    deviceColumn.width

                                height: 48

                                radius: 10

                                color:
                                    deviceMouse.containsMouse
                                    ? Qt.rgba(
                                        theme.primary.r,
                                        theme.primary.g,
                                        theme.primary.b,
                                        0.13
                                    )
                                    : Qt.rgba(
                                        theme.surfaceContainer.r,
                                        theme.surfaceContainer.g,
                                        theme.surfaceContainer.b,
                                        0.42
                                    )

                                border.width:
                                    modelData &&
                                    modelData.connected
                                    ? 1
                                    : 0

                                border.color:
                                    Qt.rgba(
                                        theme.success.r,
                                        theme.success.g,
                                        theme.success.b,
                                        0.28
                                    )

                                Row {
                                    anchors.fill: parent

                                    anchors.leftMargin: 11
                                    anchors.rightMargin: 10

                                    spacing: 9

                                    Text {
                                        anchors.verticalCenter:
                                            parent.verticalCenter

                                        width: 20
                                        height: 20

                                        text:
                                            modelData &&
                                            modelData.connected
                                            ? "󰂱"
                                            : modelData &&
                                            modelData.pairing
                                            ? "󰂰"
                                            : "󰂯"

                                        color:
                                            modelData &&
                                            modelData.connected
                                            ? theme.success
                                            : modelData &&
                                            modelData.pairing
                                            ? theme.primary
                                            : "#FFFFFF"

                                        font.family:
                                            "Symbols Nerd Font"

                                        font.pixelSize: 16

                                        horizontalAlignment:
                                            Text.AlignHCenter

                                        verticalAlignment:
                                            Text.AlignVCenter
                                    }

                                    Column {
                                        anchors.verticalCenter:
                                            parent.verticalCenter

                                        width:
                                            parent.width -
                                            20 -
                                            9 -
                                            76

                                        spacing: 2

                                        Text {
                                            width: parent.width

                                            text:
                                                BluetoothService.deviceName(
                                                    modelData
                                                )

                                            color: "#FFFFFF"

                                            font.family:
                                                "JetBrainsMono Nerd Font"

                                            font.pixelSize: 9

                                            elide:
                                                Text.ElideRight
                                        }

                                        Text {
                                            width: parent.width

                                            text:
                                                modelData &&
                                                modelData.connected
                                                ? "Connected"
                                                : modelData &&
                                                modelData.pairing
                                                ? "Pairing..."
                                                : modelData &&
                                                modelData.paired
                                                ? "Paired"
                                                : "Available"

                                            color:
                                                modelData &&
                                                modelData.connected
                                                ? theme.success
                                                : theme.textSecondary

                                            font.family:
                                                "JetBrainsMono Nerd Font"

                                            font.pixelSize: 8

                                            elide:
                                                Text.ElideRight
                                        }
                                    }

                                    Rectangle {
                                        width: 76
                                        height: 28

                                        anchors.verticalCenter:
                                            parent.verticalCenter

                                        radius: 8

                                        color:
                                            actionMouse.containsMouse
                                            ? Qt.rgba(
                                                theme.primary.r,
                                                theme.primary.g,
                                                theme.primary.b,
                                                0.20
                                            )
                                            : Qt.rgba(
                                                theme.surface.r,
                                                theme.surface.g,
                                                theme.surface.b,
                                                0.35
                                            )

                                        Text {
                                            anchors.centerIn: parent

                                            text:
                                                modelData &&
                                                modelData.connected
                                                ? "Disconnect"
                                                : modelData &&
                                                modelData.pairing
                                                ? "Cancel"
                                                : modelData &&
                                                modelData.paired
                                                ? "Connect"
                                                : "Pair"

                                            color: "#FFFFFF"

                                            font.family:
                                                "JetBrainsMono Nerd Font"

                                            font.pixelSize: 8
                                        }

                                        MouseArea {
                                            id: actionMouse

                                            anchors.fill: parent

                                            hoverEnabled: true

                                            cursorShape:
                                                Qt.PointingHandCursor

                                            onClicked: {
                                                if (
                                                    modelData &&
                                                    modelData.connected
                                                ) {
                                                    BluetoothService.disconnectDevice(
                                                        modelData
                                                    )
                                                } else if (
                                                    modelData &&
                                                    modelData.pairing
                                                ) {
                                                    BluetoothService.cancelPairing(
                                                        modelData
                                                    )
                                                } else if (
                                                    modelData &&
                                                    modelData.paired
                                                ) {
                                                    BluetoothService.connectDevice(
                                                        modelData
                                                    )
                                                } else if (
                                                    modelData
                                                ) {
                                                    BluetoothService.pairDevice(
                                                        modelData
                                                    )
                                                }

                                                root.restartAutoCloseTimer()
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    id: deviceMouse

                                    anchors.fill: parent

                                    hoverEnabled: true

                                    cursorShape:
                                        Qt.PointingHandCursor

                                    propagateComposedEvents: true

                                    onClicked: {
                                        mouse.accepted = false
                                    }
                                }
                            }
                        }

                        Rectangle {
                            visible:
                                BluetoothService.deviceCount === 0

                            width:
                                deviceColumn.width

                            height: 58

                            radius: 10

                            color:
                                Qt.rgba(
                                    theme.surfaceContainer.r,
                                    theme.surfaceContainer.g,
                                    theme.surfaceContainer.b,
                                    0.32
                                )

                            Column {
                                anchors.centerIn: parent

                                spacing: 3

                                Text {
                                    anchors.horizontalCenter:
                                        parent.horizontalCenter

                                    text: "󰂲"

                                    color:
                                        theme.textSecondary

                                    font.family:
                                        "Symbols Nerd Font"

                                    font.pixelSize: 16
                                }

                                Text {
                                    anchors.horizontalCenter:
                                        parent.horizontalCenter

                                    text:
                                        BluetoothService.enabled
                                        ? "No Bluetooth devices"
                                        : "Bluetooth is disabled"

                                    color:
                                        theme.textSecondary

                                    font.family:
                                        "JetBrainsMono Nerd Font"

                                    font.pixelSize: 8
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 34

                    radius: 9

                    color:
                        scanMouse.containsMouse
                        ? Qt.rgba(
                            theme.primary.r,
                            theme.primary.g,
                            theme.primary.b,
                            0.20
                        )
                        : Qt.rgba(
                            theme.surfaceContainer.r,
                            theme.surfaceContainer.g,
                            theme.surfaceContainer.b,
                            0.65
                        )

                    Text {
                        anchors.centerIn: parent

                        text:
                            BluetoothService.scanning
                            ? "Stop scan"
                            : "Scan for devices"

                        color:
                            BluetoothService.scanning
                            ? theme.primary
                            : "#FFFFFF"

                        font.family:
                            "JetBrainsMono Nerd Font"

                        font.pixelSize: 9
                    }

                    MouseArea {
                        id: scanMouse

                        anchors.fill: parent

                        enabled:
                            BluetoothService.enabled &&
                            BluetoothService.available

                        hoverEnabled: true

                        cursorShape:
                            enabled
                            ? Qt.PointingHandCursor
                            : Qt.ArrowCursor

                        onClicked: {
                            BluetoothService.toggleScan()
                            root.restartAutoCloseTimer()
                        }
                    }
                }
            }
        }
    }

    onPopupVisibleChanged: {
        if (root.popupVisible)
            root.restartAutoCloseTimer()
        else
            autoCloseTimer.stop()
    }
}