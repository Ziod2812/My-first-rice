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

    function activateNotification(
        notification
    ) {
        return NotificationService.activate(
            notification
        )
    }

    Rectangle {
        id: button

        anchors.fill: parent

        radius: theme.radiusSmall

        color: root.popupVisible
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
            theme.borderWidth

        border.color:
            root.popupVisible
            ? Qt.rgba(
                theme.primary.r,
                theme.primary.g,
                theme.primary.b,
                0.38
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

            text: "󰂚"

            color:
                NotificationService.count > 0
                ? theme.primary
                : theme.textSecondary

            font.family:
                "JetBrainsMono Nerd Font"

            font.pixelSize: 14
        }

        Rectangle {
            visible:
                NotificationService.count > 0

            width:
                NotificationService.count > 9
                ? 14
                : 11

            height: 11

            radius: 6

            anchors {
                top: parent.top
                right: parent.right
                topMargin: -2
                rightMargin: -2
            }

            color:
                theme.error

            border.width: 1
            border.color:
                theme.surface

            Text {
                anchors.centerIn: parent

                text:
                    NotificationService.count > 99
                    ? "99+"
                    : String(
                        NotificationService.count
                    )

                color:
                    theme.primaryText

                font.family:
                    "JetBrainsMono Nerd Font"

                font.pixelSize: 7
                font.bold: true
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
                mouse.accepted = true

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
        id: notificationPopup

        visible:
            root.popupVisible

        implicitWidth: 340
        implicitHeight: 500

        color: "transparent"

        exclusiveZone: -1
        aboveWindows: true

        WlrLayershell.layer:
            WlrLayer.Overlay

        anchors {
            top: true
            right: true
        }

        margins {
            top: 48
            right: 10
        }

        MouseArea {
            anchors.fill: parent

            z: 0

            onClicked: {
                mouse.accepted = true
                root.closePopup()
            }
        }

        Rectangle {
            id: panel

            width: 340
            height: 500

            anchors {
                top: parent.top
                right: parent.right
            }

            z: 1

            radius:
                theme.radiusLarge

            color:
                theme.glassStrong

            border.width:
                theme.borderWidth

            border.color:
                theme.glassBorder

            scale:
                root.popupVisible
                ? 1
                : 0.96

            opacity:
                root.popupVisible
                ? 1
                : 0

            Behavior on scale {
                NumberAnimation {
                    duration: 180
                    easing.type:
                        Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                    easing.type:
                        Easing.OutCubic
                }
            }

            MouseArea {
                anchors.fill: parent

                z: 0

                onClicked: {
                    mouse.accepted = true
                }
            }

            Column {
                anchors.fill: parent

                anchors.margins: 14

                spacing: 10

                z: 1

                Row {
                    width: parent.width
                    height: 32

                    Text {
                        anchors.verticalCenter:
                            parent.verticalCenter

                        text:
                            "Notifications"

                        color:
                            theme.text

                        font.family:
                            "JetBrainsMono Nerd Font"

                        font.pixelSize: 15

                        font.bold: true
                    }

                    Item {
                        width:
                            Math.max(
                                0,
                                parent.width
                                - clearButton.width
                                - 150
                            )

                        height: 1
                    }

                    Rectangle {
                        id: clearButton

                        width: 78
                        height: 28

                        radius:
                            theme.radiusSmall

                        visible:
                            NotificationService.count
                            > 0

                        color:
                            Qt.rgba(
                                theme.primary.r,
                                theme.primary.g,
                                theme.primary.b,
                                0.14
                            )

                        border.width:
                            theme.borderWidth

                        border.color:
                            Qt.rgba(
                                theme.primary.r,
                                theme.primary.g,
                                theme.primary.b,
                                0.24
                            )

                        Text {
                            anchors.centerIn:
                                parent

                            text:
                                "Clear all"

                            color:
                                theme.primary

                            font.family:
                                "JetBrainsMono Nerd Font"

                            font.pixelSize: 9
                        }

                        MouseArea {
                            anchors.fill: parent

                            z: 20

                            onClicked: {
                                mouse.accepted =
                                    true

                                NotificationService
                                .clearAll()

                                root.restartAutoCloseTimer()
                            }
                        }
                    }
                }

                Rectangle {
                    width:
                        parent.width

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
                    width:
                        parent.width

                    height:
                        parent.height - 48

                    ListView {
                        id:
                            notificationList

                        anchors.fill:
                            parent

                        clip:
                            true

                        spacing:
                            8

                        model:
                            NotificationService
                            .notifications

                        delegate:
                            Rectangle {
                            id:
                                notificationCard

                            width:
                                notificationList.width

                            height:
                                Math.max(
                                    88,
                                    contentColumn
                                    .implicitHeight
                                    + 24
                                )

                            radius:
                                theme.radiusMedium

                            property var notificationData:
                                modelData

                            property bool hasAction:
                                notificationData
                                && notificationData
                                .actions
                                && notificationData
                                .actions.length
                                > 0

                            color:
                                cardMouse
                                .containsMouse
                                ? Qt.rgba(
                                    theme.primary.r,
                                    theme.primary.g,
                                    theme.primary.b,
                                    0.09
                                )
                                : Qt.rgba(
                                    theme.surfaceContainer.r,
                                    theme.surfaceContainer.g,
                                    theme.surfaceContainer.b,
                                    0.72
                                )

                            border.width:
                                theme.borderWidth

                            border.color:
                                cardMouse
                                .containsMouse
                                ? Qt.rgba(
                                    theme.primary.r,
                                    theme.primary.g,
                                    theme.primary.b,
                                    0.24
                                )
                                : Qt.rgba(
                                    theme.outline.r,
                                    theme.outline.g,
                                    theme.outline.b,
                                    0.16
                                )

                            Behavior on color {
                                ColorAnimation {
                                    duration: 120
                                }
                            }

                            TapHandler {
                                id:
                                    cardMouse

                                acceptedButtons:
                                    Qt.LeftButton

                                onTapped: {
                                    var activated =
                                        root.activateNotification(
                                            notificationCard
                                            .notificationData
                                        )

                                    if (activated) {
                                        root.closePopup()
                                    } else {
                                        root.restartAutoCloseTimer()
                                    }
                                }
                            }

                            Column {
                                id:
                                    contentColumn

                                anchors {
                                    left:
                                        parent.left
                                    right:
                                        parent.right
                                    top:
                                        parent.top
                                }

                                anchors.margins:
                                    12

                                spacing:
                                    7

                                Row {
                                    width:
                                        parent.width

                                    spacing:
                                        8

                                    Rectangle {
                                        width:
                                            30

                                        height:
                                            30

                                        radius:
                                            8

                                        color:
                                            Qt.rgba(
                                                theme.primary.r,
                                                theme.primary.g,
                                                theme.primary.b,
                                                0.12
                                            )

                                        Image {
                                            anchors.centerIn:
                                                parent

                                            width:
                                                20

                                            height:
                                                20

                                            source:
                                                notificationCard
                                                .notificationData
                                                ? notificationCard
                                                  .notificationData
                                                  .appIcon
                                                : ""

                                            visible:
                                                source.length
                                                > 0

                                            fillMode:
                                                Image.PreserveAspectFit

                                            asynchronous:
                                                true
                                        }

                                        Text {
                                            anchors.centerIn:
                                                parent

                                            text:
                                                "󰂚"

                                            color:
                                                theme.primary

                                            font.family:
                                                "JetBrainsMono Nerd Font"

                                            font.pixelSize:
                                                14

                                            visible:
                                                !notificationCard
                                                .notificationData
                                                || !notificationCard
                                                .notificationData
                                                .appIcon
                                                || notificationCard
                                                .notificationData
                                                .appIcon
                                                .length
                                                === 0
                                        }
                                    }

                                    Column {
                                        width:
                                            parent.width
                                            - 76

                                        spacing:
                                            2

                                        Text {
                                            width:
                                                parent.width

                                            text:
                                                notificationCard
                                                .notificationData
                                                ? String(
                                                    notificationCard
                                                    .notificationData
                                                    .appName
                                                    || "Notification"
                                                )
                                                : "Notification"

                                            color:
                                                theme.textSecondary

                                            font.family:
                                                "JetBrainsMono Nerd Font"

                                            font.pixelSize:
                                                8

                                            elide:
                                                Text.ElideRight
                                        }

                                        Text {
                                            width:
                                                parent.width

                                            text:
                                                notificationCard
                                                .notificationData
                                                ? String(
                                                    notificationCard
                                                    .notificationData
                                                    .summary
                                                    || ""
                                                )
                                                : ""

                                            color:
                                                theme.text

                                            font.family:
                                                "JetBrainsMono Nerd Font"

                                            font.pixelSize:
                                                11

                                            font.bold:
                                                true

                                            maximumLineCount:
                                                2

                                            elide:
                                                Text.ElideRight
                                        }
                                    }

                                    Rectangle {
                                        id:
                                            dismissButton

                                        width:
                                            26

                                        height:
                                            26

                                        radius:
                                            7

                                        z:
                                            20

                                        color:
                                            dismissMouse
                                            .containsMouse
                                            ? Qt.rgba(
                                                theme.error.r,
                                                theme.error.g,
                                                theme.error.b,
                                                0.14
                                            )
                                            : "transparent"

                                        Text {
                                            anchors.centerIn:
                                                parent

                                            text:
                                                "󰅖"

                                            color:
                                                dismissMouse
                                                .containsMouse
                                                ? theme.error
                                                : theme.textSecondary

                                            font.family:
                                                "JetBrainsMono Nerd Font"

                                            font.pixelSize:
                                                11
                                        }

                                        MouseArea {
                                            id:
                                                dismissMouse

                                            anchors.fill:
                                                parent

                                            z:
                                                30

                                            hoverEnabled:
                                                true

                                            onClicked: {
                                                mouse.accepted =
                                                    true

                                                if (
                                                    notificationCard
                                                    .notificationData
                                                ) {
                                                    NotificationService
                                                    .dismiss(
                                                        notificationCard
                                                        .notificationData
                                                    )
                                                }

                                                root.restartAutoCloseTimer()
                                            }
                                        }
                                    }
                                }

                                Text {
                                    width:
                                        parent.width

                                    text:
                                        notificationCard
                                        .notificationData
                                        ? String(
                                            notificationCard
                                            .notificationData
                                            .body
                                            || ""
                                        )
                                        : ""

                                    color:
                                        theme.textSecondary

                                    font.family:
                                        "JetBrainsMono Nerd Font"

                                    font.pixelSize:
                                        9

                                    wrapMode:
                                        Text.WordWrap

                                    maximumLineCount:
                                        4

                                    elide:
                                        Text.ElideRight

                                    textFormat:
                                        Text.PlainText
                                }

                                Text {
                                    visible:
                                        notificationCard
                                        .hasAction

                                    width:
                                        parent.width

                                    text:
                                        "Click to open"

                                    color:
                                        theme.primary

                                    font.family:
                                        "JetBrainsMono Nerd Font"

                                    font.pixelSize:
                                        7

                                    opacity:
                                        cardMouse.containsMouse
                                        ? 1
                                        : 0.65
                                }
                            }
                        }

                        Text {
                            anchors.centerIn:
                                parent

                            visible:
                                notificationList.count
                                === 0

                            text:
                                "No notifications"

                            color:
                                theme.textSecondary

                            font.family:
                                "JetBrainsMono Nerd Font"

                            font.pixelSize:
                                10
                        }

                        ScrollBar.vertical:
                            ScrollBar {
                                active:
                                    true
                            }
                    }
                }
            }
        }

        HoverHandler {
            onHoveredChanged: {
                root.cursorInside =
                    hovered

                if (hovered)
                    autoCloseTimer.stop()
                else
                    root.restartAutoCloseTimer()
            }
        }
    }
}