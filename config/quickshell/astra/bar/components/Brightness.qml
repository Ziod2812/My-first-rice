import QtQuick
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

    function changeBrightness(delta) {
        if (!BrightnessService.available)
            return

        BrightnessService.setBrightness(
            Math.max(
                1,
                Math.min(
                    100,
                    BrightnessService.percentage + delta
                )
            )
        )

        root.restartAutoCloseTimer()
    }

    Rectangle {
        id: brightnessButton

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
                !BrightnessService.available
                ? "󰃲"
                : BrightnessService.percentage <= 20
                ? "󰃞"
                : BrightnessService.percentage <= 40
                ? "󰃝"
                : BrightnessService.percentage <= 70
                ? "󰃟"
                : "󰃠"

            color:
                !BrightnessService.available
                ? theme.textSecondary
                : theme.primary

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
                if (!BrightnessService.available)
                    return

                root.popupVisible =
                    !root.popupVisible

                if (root.popupVisible)
                    root.restartAutoCloseTimer()
                else
                    root.closePopup()
            }

            onWheel: function(event) {
                if (!BrightnessService.available)
                    return

                const delta =
                    event.angleDelta.y > 0
                    ? 5
                    : -5

                root.changeBrightness(delta)

                event.accepted = true
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

            width: 300
            height: 148

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
                id: insideMouseArea

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

                    Text {
                        width: 34
                        height: 34

                        text:
                            BrightnessService.percentage <= 20
                            ? "󰃞"
                            : BrightnessService.percentage <= 40
                            ? "󰃝"
                            : BrightnessService.percentage <= 70
                            ? "󰃟"
                            : "󰃠"

                        color: theme.primary

                        font.family:
                            "Symbols Nerd Font"

                        font.pixelSize: 18

                        horizontalAlignment:
                            Text.AlignHCenter

                        verticalAlignment:
                            Text.AlignVCenter
                    }

                    Column {
                        width:
                            parent.width - 42

                        height: 34

                        spacing: 1

                        Text {
                            text: "Brightness"

                            color: "#FFFFFF"

                            font.family:
                                "JetBrainsMono Nerd Font"

                            font.pixelSize: 14

                            font.weight:
                                Font.DemiBold
                        }

                        Text {
                            text:
                                BrightnessService.available
                                ? Math.round(
                                    BrightnessService.percentage
                                ) + "%"
                                : "Unavailable"

                            color:
                                BrightnessService.available
                                ? theme.textSecondary
                                : theme.error

                            font.family:
                                "JetBrainsMono Nerd Font"

                            font.pixelSize: 8
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

                Item {
                    id: sliderArea

                    width: parent.width
                    height: 42

                    property real sliderValue:
                        BrightnessService.percentage

                    Rectangle {
                        id: sliderTrack

                        anchors.verticalCenter:
                            parent.verticalCenter

                        width: parent.width
                        height: 6

                        radius: 3

                        color:
                            Qt.rgba(
                                theme.surfaceContainerHigh.r,
                                theme.surfaceContainerHigh.g,
                                theme.surfaceContainerHigh.b,
                                0.85
                            )

                        Rectangle {
                            width:
                                sliderTrack.width *
                                Math.max(
                                    0,
                                    Math.min(
                                        1,
                                        sliderArea.sliderValue / 100
                                    )
                                )

                            height: parent.height

                            radius: 3

                            color:
                                theme.primary

                            Behavior on width {
                                NumberAnimation {
                                    duration: 90
                                }
                            }
                        }

                        Rectangle {
                            width: 12
                            height: 12

                            radius: 6

                            x:
                                Math.max(
                                    0,
                                    Math.min(
                                        sliderTrack.width - width,
                                        sliderTrack.width *
                                        Math.max(
                                            0,
                                            Math.min(
                                                1,
                                                sliderArea.sliderValue / 100
                                            )
                                        ) -
                                        width / 2
                                    )
                                )

                            anchors.verticalCenter:
                                parent.verticalCenter

                            color:
                                theme.primary

                            border.width: 2

                            border.color:
                                theme.surface

                            Behavior on x {
                                NumberAnimation {
                                    duration: 90
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent

                        cursorShape:
                            Qt.PointingHandCursor

                        function updateValue(mouseX) {
                            const ratio =
                                Math.max(
                                    0,
                                    Math.min(
                                        1,
                                        mouseX / width
                                    )
                                )

                            const value =
                                ratio * 100

                            sliderArea.sliderValue =
                                value

                            BrightnessService.setBrightness(
                                value
                            )

                            root.restartAutoCloseTimer()
                        }

                        onPressed:
                            function(mouse) {
                                updateValue(mouse.x)
                            }

                        onPositionChanged:
                            function(mouse) {
                                if (pressed)
                                    updateValue(mouse.x)
                            }

                        onWheel:
                            function(event) {
                                const delta =
                                    event.angleDelta.y > 0
                                    ? 5
                                    : -5

                                const value =
                                    Math.max(
                                        1,
                                        Math.min(
                                            100,
                                            sliderArea.sliderValue +
                                            delta
                                        )
                                    )

                                sliderArea.sliderValue =
                                    value

                                BrightnessService.setBrightness(
                                    value
                                )

                                root.restartAutoCloseTimer()

                                event.accepted = true
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