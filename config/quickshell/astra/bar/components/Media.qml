import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services

Item {
    id: root

    width: 0
    height: 0

    property bool revealed: false
    property bool cursorInside: false
    property bool cursorInTrigger: false

    Theme {
        id: theme
    }

    function showPanel() {
        hideTimer.stop()
        root.revealed = true
    }

    function updateHoverState() {
        if (
            root.cursorInside ||
            root.cursorInTrigger
        ) {
            hideTimer.stop()
            return
        }

        hideTimer.restart()
    }

    function hidePanel() {
        root.updateHoverState()
    }

    Timer {
        id: hideTimer

        interval: 1200
        repeat: false

        onTriggered: {
            if (
                !root.cursorInside &&
                !root.cursorInTrigger
            ) {
                root.revealed = false
            }
        }
    }

    PanelWindow {
        id: hoverZone

        visible: true

        height: 10

        color: "transparent"

        exclusiveZone: -1

        aboveWindows: true

        WlrLayershell.layer:
            WlrLayer.Overlay

        MouseArea {
            anchors.fill: parent

            hoverEnabled: true

            onEntered: {
                root.cursorInTrigger = true
                root.showPanel()
            }

            onExited: {
                root.cursorInTrigger = false
                root.updateHoverState()
            }
        }
    }

    PanelWindow {
        id: mediaPanel

        visible: root.revealed

        width: 460
        height: 150

        color: "transparent"

        exclusiveZone: -1

        aboveWindows: true

        WlrLayershell.layer:
            WlrLayer.Overlay

        anchors {
            top: true
            left: true
        }

        margins.top: 6

        margins.left:
            Math.max(
                10,
                (
                    screen.width -
                    width
                ) / 2
            )

        Rectangle {
            id: background

            anchors.fill: parent

            radius:
                theme.radiusLarge

            color:
                Qt.rgba(
                    theme.surface.r,
                    theme.surface.g,
                    theme.surface.b,
                    root.revealed
                    ? 0.92
                    : 0
                )

            border.width:
                root.revealed
                ? theme.borderWidth
                : 0

            border.color:
                Qt.rgba(
                    theme.outline.r,
                    theme.outline.g,
                    theme.outline.b,
                    0.28
                )

            scale:
                root.revealed
                ? 1
                : 0.94

            opacity:
                root.revealed
                ? 1
                : 0

            Behavior on color {
                ColorAnimation {
                    duration: 180
                }
            }

            Behavior on border.width {
                NumberAnimation {
                    duration: 160
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 220
                    easing.type:
                        Easing.OutBack
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 160
                    easing.type:
                        Easing.OutCubic
                }
            }

            MouseArea {
                anchors.fill: parent

                enabled:
                    root.revealed

                hoverEnabled: true

                onEntered: {
                    root.cursorInside = true
                    hideTimer.stop()
                }

                onExited: {
                    root.cursorInside = false
                    root.updateHoverState()
                }

                onClicked: {
                    mouse.accepted = true
                }
            }

            Row {
                anchors.fill: parent

                anchors.margins: 11

                spacing: 11

                Rectangle {
                    id: artwork

                    width: 92
                    height: 128

                    anchors.verticalCenter:
                        parent.verticalCenter

                    radius: 14

                    color:
                        Qt.rgba(
                            theme.surfaceContainerLow.r,
                            theme.surfaceContainerLow.g,
                            theme.surfaceContainerLow.b,
                            0.95
                        )

                    border.width: 1

                    border.color:
                        Qt.rgba(
                            theme.primary.r,
                            theme.primary.g,
                            theme.primary.b,
                            0.24
                        )

                    clip: true

                    Image {
                        anchors.fill: parent

                        source:
                            MediaService.artwork

                        fillMode:
                            Image.PreserveAspectCrop

                        asynchronous: true
                        smooth: true

                        visible:
                            MediaService.artwork.length > 0
                    }

                    Rectangle {
                        anchors.fill: parent

                        color:
                            Qt.rgba(
                                theme.primary.r,
                                theme.primary.g,
                                theme.primary.b,
                                MediaService.playing
                                ? 0.06
                                : 0.17
                            )
                    }

                    Rectangle {
                        width: 28
                        height: 3

                        radius: 1.5

                        anchors {
                            left: parent.left
                            bottom: parent.bottom
                        }

                        anchors.leftMargin: 10
                        anchors.bottomMargin: 9

                        color:
                            theme.primary

                        opacity:
                            MediaService.playing
                            ? 1
                            : 0.38
                    }

                    Text {
                        anchors.centerIn: parent

                        text: "󰝚"

                        color:
                            theme.primary

                        font.family:
                            "Symbols Nerd Font"

                        font.pixelSize: 28

                        visible:
                            MediaService.artwork.length === 0
                    }
                }

                Column {
                    width:
                        parent.width -
                        artwork.width -
                        parent.spacing

                    anchors.verticalCenter:
                        parent.verticalCenter

                    spacing: 6

                    Row {
                        width: parent.width
                        height: 15

                        spacing: 6

                        Text {
                            width:
                                parent.width -
                                playerBadge.width -
                                6

                            height: 15

                            text:
                                MediaService.available
                                ? "NOW PLAYING"
                                : "MEDIA"

                            color:
                                theme.primary

                            font.family:
                                "JetBrainsMono Nerd Font"

                            font.pixelSize: 7

                            font.weight:
                                Font.DemiBold

                            verticalAlignment:
                                Text.AlignVCenter
                        }

                        Rectangle {
                            id: playerBadge

                            width: 66
                            height: 15

                            radius: 6

                            color:
                                Qt.rgba(
                                    theme.primary.r,
                                    theme.primary.g,
                                    theme.primary.b,
                                    0.12
                                )

                            Text {
                                anchors.fill: parent

                                text:
                                    MediaService.playerName

                                color:
                                    theme.textSecondary

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                font.pixelSize: 6

                                horizontalAlignment:
                                    Text.AlignHCenter

                                verticalAlignment:
                                    Text.AlignVCenter

                                elide:
                                    Text.ElideRight
                            }
                        }
                    }

                    Text {
                        width: parent.width
                        height: 22

                        text:
                            MediaService.title

                        color:
                            theme.text

                        font.family:
                            "JetBrainsMono Nerd Font"

                        font.pixelSize: 12

                        font.weight:
                            Font.DemiBold

                        elide:
                            Text.ElideRight

                        verticalAlignment:
                            Text.AlignVCenter
                    }

                    Text {
                        width: parent.width
                        height: 14

                        text:
                            MediaService.available
                            ? MediaService.artist +
                              " · " +
                              MediaService.album
                            : "Nothing playing"

                        color:
                            theme.textSecondary

                        font.family:
                            "JetBrainsMono Nerd Font"

                        font.pixelSize: 8

                        elide:
                            Text.ElideRight

                        verticalAlignment:
                            Text.AlignVCenter
                    }

                    Row {
                        width: parent.width
                        height: 14

                        spacing: 6

                        Text {
                            width: 30
                            height: 14

                            text:
                                MediaService.formatTime(
                                    MediaService.position
                                )

                            color:
                                theme.textSecondary

                            font.family:
                                "JetBrainsMono Nerd Font"

                            font.pixelSize: 6

                            verticalAlignment:
                                Text.AlignVCenter
                        }

                        Item {
                            width:
                                parent.width - 72

                            height: 14

                            Rectangle {
                                id: progressTrack

                                anchors.verticalCenter:
                                    parent.verticalCenter

                                width: parent.width
                                height: 4

                                radius: 2

                                color:
                                    Qt.rgba(
                                        theme.surfaceContainerHigh.r,
                                        theme.surfaceContainerHigh.g,
                                        theme.surfaceContainerHigh.b,
                                        0.88
                                    )

                                Rectangle {
                                    width:
                                        progressTrack.width *
                                        MediaService.progress

                                    height:
                                        parent.height

                                    radius: 2

                                    color:
                                        theme.primary

                                    Behavior on width {
                                        NumberAnimation {
                                            duration: 140
                                            easing.type:
                                                Easing.OutCubic
                                        }
                                    }
                                }

                                Rectangle {
                                    width: 8
                                    height: 8

                                    radius: 4

                                    x:
                                        Math.max(
                                            0,
                                            Math.min(
                                                progressTrack.width -
                                                width,
                                                progressTrack.width *
                                                MediaService.progress -
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
                                }

                                MouseArea {
                                    anchors.fill: parent

                                    enabled:
                                        MediaService.canSeek

                                    cursorShape:
                                        enabled
                                        ? Qt.PointingHandCursor
                                        : Qt.ArrowCursor

                                    onClicked:
                                        function(mouse) {
                                            const ratio =
                                                Math.max(
                                                    0,
                                                    Math.min(
                                                        1,
                                                        mouse.x /
                                                        width
                                                    )
                                                )

                                            MediaService.seekTo(
                                                MediaService.length *
                                                ratio
                                            )
                                        }
                                }
                            }
                        }

                        Text {
                            width: 30
                            height: 14

                            text:
                                MediaService.formatTime(
                                    MediaService.length
                                )

                            color:
                                theme.textSecondary

                            font.family:
                                "JetBrainsMono Nerd Font"

                            font.pixelSize: 6

                            horizontalAlignment:
                                Text.AlignRight

                            verticalAlignment:
                                Text.AlignVCenter
                        }
                    }

                    Row {
                        width: parent.width
                        height: 34

                        spacing: 6

                        Rectangle {
                            width: 32
                            height: 32

                            radius: 9

                            color:
                                previousMouse.containsMouse
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
                                    0.48
                                )

                            opacity:
                                MediaService.canPrevious
                                ? 1
                                : 0.38

                            Text {
                                anchors.centerIn: parent

                                text: "󰒮"

                                color:
                                    theme.text

                                font.family:
                                    "Symbols Nerd Font"

                                font.pixelSize: 13
                            }

                            MouseArea {
                                id: previousMouse

                                anchors.fill: parent

                                hoverEnabled: true

                                enabled:
                                    MediaService.canPrevious

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked: {
                                    MediaService.previous()
                                }
                            }
                        }

                        Rectangle {
                            width: 40
                            height: 34

                            radius: 11

                            color:
                                playMouse.containsMouse
                                ? Qt.rgba(
                                    theme.primary.r,
                                    theme.primary.g,
                                    theme.primary.b,
                                    0.38
                                )
                                : Qt.rgba(
                                    theme.primary.r,
                                    theme.primary.g,
                                    theme.primary.b,
                                    0.20
                                )

                            border.width: 1

                            border.color:
                                Qt.rgba(
                                    theme.primary.r,
                                    theme.primary.g,
                                    theme.primary.b,
                                    0.30
                                )

                            Text {
                                anchors.centerIn: parent

                                text:
                                    MediaService.playing
                                    ? "󰏤"
                                    : "󰐊"

                                color:
                                    theme.primary

                                font.family:
                                    "Symbols Nerd Font"

                                font.pixelSize: 15
                            }

                            MouseArea {
                                id: playMouse

                                anchors.fill: parent

                                hoverEnabled: true

                                enabled:
                                    MediaService.canPlayPause

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked: {
                                    MediaService.togglePlaying()
                                }
                            }
                        }

                        Rectangle {
                            width: 32
                            height: 32

                            radius: 9

                            color:
                                nextMouse.containsMouse
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
                                    0.48
                                )

                            opacity:
                                MediaService.canNext
                                ? 1
                                : 0.38

                            Text {
                                anchors.centerIn: parent

                                text: "󰒭"

                                color:
                                    theme.text

                                font.family:
                                    "Symbols Nerd Font"

                                font.pixelSize: 13
                            }

                            MouseArea {
                                id: nextMouse

                                anchors.fill: parent

                                hoverEnabled: true

                                enabled:
                                    MediaService.canNext

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked: {
                                    MediaService.next()
                                }
                            }
                        }

                        Rectangle {
                            visible:
                                MediaService.shuffleSupported

                            width: 32
                            height: 32

                            radius: 9

                            color:
                                MediaService.shuffle
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
                                    0.48
                                )

                            Text {
                                anchors.centerIn: parent

                                text: "󰒟"

                                color:
                                    MediaService.shuffle
                                    ? theme.primary
                                    : theme.textSecondary

                                font.family:
                                    "Symbols Nerd Font"

                                font.pixelSize: 12
                            }

                            MouseArea {
                                anchors.fill: parent

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked: {
                                    MediaService.toggleShuffle()
                                }
                            }
                        }

                        Item {
                            width:
                                Math.max(
                                    0,
                                    parent.width -
                                    32 -
                                    40 -
                                    32 -
                                    (
                                        MediaService.shuffleSupported
                                        ? 32
                                        : 0
                                    ) -
                                    18
                                )

                            height: 32
                        }

                        Text {
                            visible:
                                MediaService.volumeSupported

                            width: 62
                            height: 32

                            text:
                                "VOL " +
                                Math.round(
                                    MediaService.volume * 100
                                ) +
                                "%"

                            color:
                                theme.textSecondary

                            font.family:
                                "JetBrainsMono Nerd Font"

                            font.pixelSize: 6

                            horizontalAlignment:
                                Text.AlignRight

                            verticalAlignment:
                                Text.AlignVCenter
                        }
                    }

                    Item {
                        width: parent.width
                        height: 7

                        visible:
                            MediaService.volumeSupported

                        Rectangle {
                            id: volumeTrack

                            anchors.verticalCenter:
                                parent.verticalCenter

                            width: parent.width
                            height: 3

                            radius: 1.5

                            color:
                                Qt.rgba(
                                    theme.surfaceContainerHigh.r,
                                    theme.surfaceContainerHigh.g,
                                    theme.surfaceContainerHigh.b,
                                    0.75
                                )

                            Rectangle {
                                width:
                                    volumeTrack.width *
                                    MediaService.volume

                                height:
                                    parent.height

                                radius: 1.5

                                color:
                                    theme.secondary

                                Behavior on width {
                                    NumberAnimation {
                                        duration: 100
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked:
                                    function(mouse) {
                                        const ratio =
                                            Math.max(
                                                0,
                                                Math.min(
                                                    1,
                                                    mouse.x /
                                                    width
                                                )
                                            )

                                        MediaService.setVolume(
                                            ratio
                                        )
                                    }
                            }
                        }
                    }
                }
            }
        }
    }
}