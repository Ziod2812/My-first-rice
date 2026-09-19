import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Services.Pipewire as Pw
import qs
import qs.services

Item {
    id: root

    Theme {
        id: theme
    }

    implicitWidth: 26
    implicitHeight: 26

    property bool popupVisible: false

    readonly property var sink:
        Pipewire.defaultAudioSink

    Pw.PwObjectTracker {
        objects: [
            root.sink
        ]
    }

    Rectangle {
        id: volumeButton

        anchors.fill: parent

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
            anchors.centerIn: parent

            text: {
                if (
                    !root.sink ||
                    !root.sink.audio
                ) {
                    return "󰖁"
                }

                if (
                    root.sink.audio.muted
                ) {
                    return "󰖁"
                }

                if (
                    root.sink.audio.volume < 0.35
                ) {
                    return "󰕿"
                }

                if (
                    root.sink.audio.volume < 0.70
                ) {
                    return "󰖀"
                }

                return "󰕾"
            }

            color: "#FFFFFF"

            font.family:
                "Symbols Nerd Font"

            font.pixelSize: 15

            font.weight:
                Font.Normal
        }

        MouseArea {
            id: mouseArea

            anchors.fill: parent

            hoverEnabled: true

            cursorShape:
                Qt.PointingHandCursor

            acceptedButtons:
                Qt.LeftButton

            onClicked: {
                root.popupVisible =
                    !root.popupVisible

                volumePopup.visible =
                    root.popupVisible
            }

            onWheel: function(event) {
                if (
                    !root.sink ||
                    !root.sink.audio
                ) {
                    return
                }

                const delta =
                    event.angleDelta.y > 0
                    ? 0.05
                    : -0.05

                root.sink.audio.volume =
                    Math.max(
                        0,
                        Math.min(
                            1.5,
                            root.sink.audio.volume
                            + delta
                        )
                    )

                event.accepted = true
            }
        }
    }

    VolumePopup {
        id: volumePopup

        visible:
            root.popupVisible

        anchorItem:
            volumeButton

        onVisibleChanged: {
            if (!visible) {
                root.popupVisible = false
            }
        }
    }
}