import QtQuick
import Quickshell
import qs

Item {
    id: root

    implicitWidth:
        clockButton.width

    implicitHeight: 26

    property string currentTime: ""
    property string currentDate: ""

    property bool popupVisible: false

    Theme {
        id: theme
    }

    function updateTime() {
        const now = new Date()

        root.currentTime =
            Qt.formatDateTime(
                now,
                "HH:mm"
            )

        root.currentDate =
            Qt.formatDateTime(
                now,
                "dddd, dd MMMM yyyy"
            )
    }

    Timer {
        interval: 1000

        running: true

        repeat: true

        triggeredOnStart: true

        onTriggered: {
            root.updateTime()
        }
    }

    Component.onCompleted: {
        root.updateTime()
    }

    Rectangle {
        id: clockButton

        width:
            clockText.implicitWidth + 16

        height: 26

        radius: 7

        color:
            mouseArea.containsMouse
                ? Qt.rgba(
                    theme.surfaceContainer.r,
                    theme.surfaceContainer.g,
                    theme.surfaceContainer.b,
                    0.55
                )
                : "transparent"

        border.width:
            mouseArea.containsMouse
                ? 1
                : 0

        border.color:
            Qt.rgba(
                0,
                0,
                0,
                mouseArea.containsMouse
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
            id: clockText

            anchors.centerIn: parent

            text:
                root.currentTime

            color:
                "#FFFFFF"

            font.family:
                "JetBrainsMono Nerd Font"

            font.pixelSize:
                12

            font.weight:
                Font.Normal
        }

        MouseArea {
            id: mouseArea

            anchors.fill: parent

            acceptedButtons:
                Qt.LeftButton

            hoverEnabled: true

            cursorShape:
                Qt.PointingHandCursor

            onClicked: {
                root.popupVisible =
                    !root.popupVisible

                clockPopup.visible =
                    root.popupVisible
            }
        }
    }

    ClockPopup {
        id: clockPopup

        visible:
            root.popupVisible

        currentTime:
            root.currentTime

        currentDate:
            root.currentDate

        popupX:
            Math.max(
                8,
                root.mapToItem(
                    null,
                    0,
                    0
                ).x
                - 360
                - 8
            )

        onClosed: {
            root.popupVisible = false
            clockPopup.visible = false
        }
    }
}