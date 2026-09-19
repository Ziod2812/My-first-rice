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

    function openPopup() {
        root.popupVisible = true
        root.restartAutoCloseTimer()
    }

    function closePopup() {
        autoCloseTimer.stop()
        root.cursorInside = false
        root.popupVisible = false
    }

    function restartAutoCloseTimer() {
        if (!root.popupVisible)
            return

        if (root.cursorInside) {
            autoCloseTimer.stop()
            return
        }

        autoCloseTimer.restart()
    }

    Rectangle {
        id: button

        anchors.fill: parent

        radius: theme.radiusSmall

        color: root.popupVisible
            ? Qt.rgba(
                theme.error.r,
                theme.error.g,
                theme.error.b,
                0.18
            )
            : Qt.rgba(
                theme.surfaceContainer.r,
                theme.surfaceContainer.g,
                theme.surfaceContainer.b,
                0.45
            )

        border.width: theme.borderWidth

        border.color: root.popupVisible
            ? Qt.rgba(
                theme.error.r,
                theme.error.g,
                theme.error.b,
                0.36
            )
            : Qt.rgba(
                theme.outline.r,
                theme.outline.g,
                theme.outline.b,
                0.16
            )

        Behavior on color {
            ColorAnimation {
                duration: 160
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 160
            }
        }

        Text {
            anchors.centerIn: parent

            text: "󰐥"

            color: root.popupVisible
                ? theme.error
                : theme.textSecondary

            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14

            Behavior on color {
                ColorAnimation {
                    duration: 160
                }
            }
        }

        MouseArea {
            anchors.fill: parent

            hoverEnabled: true

            onEntered: {
                root.cursorInside = true
                autoCloseTimer.stop()
            }

            onExited: {
                root.cursorInside = false
                root.restartAutoCloseTimer()
            }

            onClicked: {
                if (root.popupVisible)
                    root.closePopup()
                else
                    root.openPopup()
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
        id: powerPopup

        visible: root.popupVisible

        implicitWidth: 360
        implicitHeight: 430

        color: "transparent"

        exclusiveZone: -1
        aboveWindows: true

        WlrLayershell.layer: WlrLayer.Overlay

        anchors {
            top: true
            left: true
        }

        margins {
            top: 48
            left: 10
        }

        MouseArea {
            anchors.fill: parent

            onClicked: {
                root.closePopup()
            }
        }

        Rectangle {
            id: panel

            width: 360
            height: 430

            anchors {
                top: parent.top
                left: parent.left
            }

            radius: theme.radiusLarge

            color: theme.glassStrong

            border.width: theme.borderWidth

            border.color: theme.glassBorder

            scale: root.popupVisible ? 1 : 0.96
            opacity: root.popupVisible ? 1 : 0

            Behavior on scale {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    mouse.accepted = true
                }
            }

            Column {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                Item {
                    width: parent.width
                    height: 34

                    Text {
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                        }

                        text: "Power"

                        color: theme.text

                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 15
                        font.bold: true
                    }

                    Text {
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }

                        text: "System"

                        color: theme.textSecondary

                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 8
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1

                    color: Qt.rgba(
                        theme.outline.r,
                        theme.outline.g,
                        theme.outline.b,
                        0.14
                    )
                }

                Text {
                    width: parent.width
                    height: 22

                    text: "Session"

                    color: theme.textSecondary

                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 8
                    font.bold: true
                }

                Grid {
                    width: parent.width

                    columns: 2

                    columnSpacing: 8
                    rowSpacing: 8

                    PowerButton {
                        title: "Lock"
                        subtitle: "Lock session"
                        icon: "󰌾"
                        accent: theme.primary

                        onClicked: {
                            root.closePopup()
                            PowerService.lock()
                        }
                    }

                    PowerButton {
                        title: "Logout"
                        subtitle: "End session"
                        icon: "󰍃"
                        accent: theme.warning

                        onClicked: {
                            root.closePopup()
                            PowerService.logout()
                        }
                    }

                    PowerButton {
                        title: "Suspend"
                        subtitle: "Sleep system"
                        icon: "󰒲"
                        accent: theme.blue

                        onClicked: {
                            root.closePopup()
                            PowerService.suspend()
                        }
                    }

                    PowerButton {
                        title: "Hibernate"
                        subtitle: "Save and sleep"
                        icon: "󰋊"
                        accent: theme.tertiary

                        onClicked: {
                            root.closePopup()
                            PowerService.hibernate()
                        }
                    }
                }

                Text {
                    width: parent.width
                    height: 22

                    text: "Power"

                    color: theme.textSecondary

                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 8
                    font.bold: true
                }

                Grid {
                    width: parent.width

                    columns: 2

                    columnSpacing: 8
                    rowSpacing: 8

                    PowerButton {
                        title: "Reboot"
                        subtitle: "Restart system"
                        icon: "󰜉"
                        accent: theme.green

                        onClicked: {
                            root.closePopup()
                            PowerService.reboot()
                        }
                    }

                    PowerButton {
                        title: "Shutdown"
                        subtitle: "Power off"
                        icon: "󰐥"
                        accent: theme.error

                        onClicked: {
                            root.closePopup()
                            PowerService.poweroff()
                        }
                    }
                }
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
    }

    component PowerButton: Rectangle {
        width: 158
        height: 82

        radius: theme.radiusMedium

        property string title: ""
        property string subtitle: ""
        property string icon: ""
        property color accent: theme.primary

        signal clicked()

        color: powerMouse.containsMouse
            ? Qt.rgba(
                accent.r,
                accent.g,
                accent.b,
                0.12
            )
            : Qt.rgba(
                theme.surfaceContainer.r,
                theme.surfaceContainer.g,
                theme.surfaceContainer.b,
                0.62
            )

        border.width: theme.borderWidth

        border.color: powerMouse.containsMouse
            ? Qt.rgba(
                accent.r,
                accent.g,
                accent.b,
                0.28
            )
            : Qt.rgba(
                theme.outline.r,
                theme.outline.g,
                theme.outline.b,
                0.14
            )

        scale: powerMouse.containsMouse ? 1.015 : 1

        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 130
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 130
            }
        }

        Rectangle {
            id: iconBox

            width: 40
            height: 40

            radius: theme.radiusMedium

            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                leftMargin: 12
            }

            color: Qt.rgba(
                parent.accent.r,
                parent.accent.g,
                parent.accent.b,
                powerMouse.containsMouse ? 0.18 : 0.10
            )

            border.width: 1

            border.color: Qt.rgba(
                parent.accent.r,
                parent.accent.g,
                parent.accent.b,
                0.18
            )

            Text {
                anchors.centerIn: parent

                text: parent.parent.icon

                color: parent.parent.accent

                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 18
            }
        }

        Column {
            anchors {
                left: iconBox.right
                right: parent.right
                verticalCenter: parent.verticalCenter
                leftMargin: 10
                rightMargin: 8
            }

            spacing: 2

            Text {
                width: parent.width

                text: parent.parent.title

                color: theme.text

                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 9
                font.bold: true

                elide: Text.ElideRight
            }

            Text {
                width: parent.width

                text: parent.parent.subtitle

                color: theme.textSecondary

                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 7

                elide: Text.ElideRight
            }
        }

        MouseArea {
            id: powerMouse

            anchors.fill: parent

            hoverEnabled: true

            onClicked: {
                parent.clicked()
            }
        }
    }
}