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
        if (!ClipboardService.available)
            return

        root.popupVisible = true
        ClipboardService.refreshHistory()
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

        radius: 8

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

        border.width: 1

        border.color: root.popupVisible
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

            text: "󰅍"

            color: "#FFFFFF"

            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14

            Behavior on color {
                ColorAnimation {
                    duration: 160
                }
            }
        }

        Rectangle {
            visible: ClipboardService.historyCount > 0

            width: ClipboardService.historyCount > 9 ? 14 : 11
            height: 11

            radius: 6

            anchors {
                top: parent.top
                right: parent.right
                topMargin: -2
                rightMargin: -2
            }

            color: "#FFFFFF"

            border.width: 1
            border.color: theme.surface

            Text {
                anchors.centerIn: parent

                text: ClipboardService.historyCount > 99
                    ? "99+"
                    : String(ClipboardService.historyCount)

                color: "#1E1E2E"

                font.family: "JetBrainsMono Nerd Font"
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
        id: clipboardPopup

        visible: root.popupVisible

        implicitWidth: 360
        implicitHeight: 520

        color: "transparent"

        exclusiveZone: -1
        aboveWindows: true

        WlrLayershell.layer: WlrLayer.Overlay

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

            onClicked: {
                root.closePopup()
            }
        }

        Rectangle {
            id: panel

            width: 360
            height: 520

            anchors {
                top: parent.top
                right: parent.right
            }

            radius: theme.radiusLarge

            color: Qt.rgba(
                theme.surface.r,
                theme.surface.g,
                theme.surface.b,
                0.95
            )

            border.width: theme.borderWidth

            border.color: Qt.rgba(
                theme.outline.r,
                theme.outline.g,
                theme.outline.b,
                0.30
            )

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

                Row {
                    width: parent.width
                    height: 32
                    spacing: 8

                    Text {
                        anchors.verticalCenter: parent.verticalCenter

                        text: "Clipboard"

                        color: theme.text

                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 15
                        font.bold: true
                    }

                    Item {
                        width: Math.max(
                            0,
                            parent.width - clearButton.width - 100
                        )
                        height: 1
                    }

                    Rectangle {
                        id: clearButton

                        width: 78
                        height: 28

                        radius: 8

                        visible: ClipboardService.historyCount > 0

                        color: Qt.rgba(
                            theme.error.r,
                            theme.error.g,
                            theme.error.b,
                            0.10
                        )

                        border.width: 1

                        border.color: Qt.rgba(
                            theme.error.r,
                            theme.error.g,
                            theme.error.b,
                            0.22
                        )

                        Text {
                            anchors.centerIn: parent

                            text: "Clear all"

                            color: theme.error

                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 9
                        }

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                ClipboardService.clearHistory()
                                root.restartAutoCloseTimer()
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
                        0.16
                    )
                }

                Text {
                    width: parent.width
                    height: 18

                    text: ClipboardService.loadingHistory
                        ? "Loading clipboard history..."
                        : ClipboardService.historyCount > 0
                            ? String(ClipboardService.historyCount) + " items"
                            : "No clipboard history"

                    color: theme.textSecondary

                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 8
                }

                Item {
                    width: parent.width
                    height: parent.height - 80

                    ListView {
                        id: clipboardList

                        anchors.fill: parent

                        clip: true

                        spacing: 8

                        model: ClipboardService.history

                        delegate: Rectangle {
                            id: clipboardCard

                            width: clipboardList.width
                            height: 68

                            radius: theme.radiusMedium

                            color: Qt.rgba(
                                theme.surfaceContainer.r,
                                theme.surfaceContainer.g,
                                theme.surfaceContainer.b,
                                0.72
                            )

                            border.width: 1

                            border.color: Qt.rgba(
                                theme.outline.r,
                                theme.outline.g,
                                theme.outline.b,
                                0.16
                            )

                            property string entryText: String(modelData || "")

                            Text {
                                id: preview

                                anchors {
                                    left: parent.left
                                    right: copyButton.left
                                    top: parent.top
                                    bottom: parent.bottom
                                }

                                anchors.leftMargin: 12
                                anchors.rightMargin: 8
                                anchors.topMargin: 10
                                anchors.bottomMargin: 10

                                text: clipboardCard.entryText

                                color: theme.text

                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 9

                                wrapMode: Text.WordWrap

                                maximumLineCount: 3

                                elide: Text.ElideRight

                                verticalAlignment: Text.AlignVCenter
                            }

                            Rectangle {
                                id: copyButton

                                width: 30
                                height: 30

                                anchors {
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                    rightMargin: 10
                                }

                                radius: 8

                                color: Qt.rgba(
                                    theme.primary.r,
                                    theme.primary.g,
                                    theme.primary.b,
                                    0.12
                                )

                                border.width: 1

                                border.color: Qt.rgba(
                                    theme.primary.r,
                                    theme.primary.g,
                                    theme.primary.b,
                                    0.20
                                )

                                Text {
                                    anchors.centerIn: parent

                                    text: "󰆏"

                                    color: theme.primary

                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 12
                                }

                                MouseArea {
                                    anchors.fill: parent

                                    onClicked: {
                                        ClipboardService.copyEntry(
                                            clipboardCard.entryText
                                        )

                                        root.restartAutoCloseTimer()
                                    }
                                }
                            }

                            MouseArea {
                                anchors {
                                    left: parent.left
                                    top: parent.top
                                    bottom: parent.bottom
                                    right: copyButton.left
                                }

                                onClicked: {
                                    ClipboardService.copyEntry(
                                        clipboardCard.entryText
                                    )

                                    root.restartAutoCloseTimer()
                                }
                            }
                        }

                        ScrollBar.vertical: ScrollBar {
                            active: true
                        }

                        Text {
                            anchors.centerIn: parent

                            visible:
                                !ClipboardService.loadingHistory
                                && clipboardList.count === 0

                            text: ClipboardService.available
                                ? "No clipboard history"
                                : "wl-clipboard unavailable"

                            color: theme.textSecondary

                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10
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
}