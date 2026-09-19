import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs
import qs.services

PanelWindow {
    id: root

    property Item anchorItem: null
    property bool cursorInside: false

    visible: false
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

    Theme {
        id: theme
    }

    function closePopup() {
        autoCloseTimer.stop()
        root.cursorInside = false
        root.visible = false
    }

    function restartAutoCloseTimer() {
        if (root.cursorInside) {
            autoCloseTimer.stop()
            return
        }

        autoCloseTimer.restart()
    }

    MouseArea {
        id: outsideMouseArea

        anchors.fill: parent

        onClicked: {
            root.closePopup()
        }
    }

    Timer {
        id: autoCloseTimer

        interval: 5000
        repeat: false

        onTriggered: {
            if (!root.cursorInside) {
                root.visible = false
            }
        }
    }

    onVisibleChanged: {
        if (!visible) {
            autoCloseTimer.stop()
            return
        }

        root.restartAutoCloseTimer()
    }

    Rectangle {
        id: background

        width: 330
        height: popupContent.implicitHeight + 28

        anchors.top: parent.top
        anchors.right: parent.right

        anchors.topMargin: 48
        anchors.rightMargin: 12

        radius: theme.radiusXLarge

        color:
            Qt.rgba(
                theme.surface.r,
                theme.surface.g,
                theme.surface.b,
                0.94
            )

        border.width:
            theme.borderWidth

        border.color:
            Qt.rgba(
                theme.outline.r,
                theme.outline.g,
                theme.outline.b,
                0.32
            )

        MouseArea {
            id: insideMouseArea

            anchors.fill: parent

            onClicked: {
                mouse.accepted = true
            }
        }

        HoverHandler {
            id: popupHover

            onHoveredChanged: {
                root.cursorInside = hovered

                if (hovered) {
                    autoCloseTimer.stop()
                } else {
                    root.restartAutoCloseTimer()
                }
            }
        }

        Column {
            id: popupContent

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }

            anchors.margins: 14

            spacing: 10

            Row {
                width: parent.width
                height: 30
                spacing: 9

                Text {
                    width: 28
                    height: 30

                    text: "󰕾"

                    color: theme.primary

                    font.family:
                        "Symbols Nerd Font"

                    font.pixelSize: 17

                    horizontalAlignment:
                        Text.AlignHCenter

                    verticalAlignment:
                        Text.AlignVCenter
                }

                Column {
                    width:
                        parent.width - 37

                    height: 30

                    spacing: 1

                    Text {
                        text: "Volume Mixer"

                        color:
                            theme.text

                        font.family:
                            "JetBrainsMono Nerd Font"

                        font.pixelSize: 12

                        font.weight:
                            Font.DemiBold
                    }

                    Text {
                        text:
                            AudioService.applicationStreams.length === 1
                            ? "1 application"
                            : AudioService.applicationStreams.length +
                              " applications"

                        color:
                            theme.textSecondary

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

            Rectangle {
                width: parent.width
                height: 72

                radius:
                    theme.radiusMedium

                color:
                    Qt.rgba(
                        theme.surfaceContainer.r,
                        theme.surfaceContainer.g,
                        theme.surfaceContainer.b,
                        0.68
                    )

                border.width: 1

                border.color:
                    Qt.rgba(
                        theme.outline.r,
                        theme.outline.g,
                        theme.outline.b,
                        0.16
                    )

                Column {
                    anchors.fill: parent

                    anchors.margins: 10

                    spacing: 5

                    Row {
                        width: parent.width
                        height: 21
                        spacing: 7

                        Text {
                            width: 20
                            height: 21

                            text:
                                AudioService.masterMuted
                                ? "󰖁"
                                : "󰕾"

                            color:
                                AudioService.masterMuted
                                ? theme.error
                                : theme.primary

                            font.family:
                                "Symbols Nerd Font"

                            font.pixelSize: 14

                            horizontalAlignment:
                                Text.AlignHCenter

                            verticalAlignment:
                                Text.AlignVCenter
                        }

                        Text {
                            width:
                                parent.width -
                                20 -
                                7 -
                                48

                            height: 21

                            text:
                                "System output"

                            color:
                                theme.text

                            font.family:
                                "JetBrainsMono Nerd Font"

                            font.pixelSize: 9

                            font.weight:
                                Font.DemiBold

                            verticalAlignment:
                                Text.AlignVCenter
                        }

                        Text {
                            width: 48
                            height: 21

                            text:
                                Math.round(
                                    AudioService.masterVolume * 100
                                ) + "%"

                            color:
                                AudioService.masterMuted
                                ? theme.error
                                : theme.textSecondary

                            font.family:
                                "JetBrainsMono Nerd Font"

                            font.pixelSize: 9

                            horizontalAlignment:
                                Text.AlignRight

                            verticalAlignment:
                                Text.AlignVCenter
                        }
                    }

                    Item {
                        id: masterSliderArea

                        width: parent.width
                        height: 20

                        property real sliderValue:
                            AudioService.masterVolume

                        Rectangle {
                            id: masterTrack

                            anchors.verticalCenter:
                                parent.verticalCenter

                            width: parent.width
                            height: 5

                            radius: 2.5

                            color:
                                Qt.rgba(
                                    theme.surfaceContainerHigh.r,
                                    theme.surfaceContainerHigh.g,
                                    theme.surfaceContainerHigh.b,
                                    0.85
                                )

                            Rectangle {
                                width:
                                    masterTrack.width *
                                    Math.max(
                                        0,
                                        Math.min(
                                            1,
                                            masterSliderArea.sliderValue /
                                            1.5
                                        )
                                    )

                                height:
                                    parent.height

                                radius: 2.5

                                color:
                                    theme.primary

                                Behavior on width {
                                    NumberAnimation {
                                        duration: 90
                                    }
                                }
                            }

                            Rectangle {
                                width: 11
                                height: 11

                                radius: 5.5

                                x:
                                    Math.max(
                                        0,
                                        Math.min(
                                            masterTrack.width - width,
                                            masterTrack.width *
                                            Math.max(
                                                0,
                                                Math.min(
                                                    1,
                                                    masterSliderArea.sliderValue /
                                                    1.5
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
                                    ratio * 1.5

                                masterSliderArea.sliderValue =
                                    value

                                AudioService.setMasterVolume(
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
                        }
                    }
                }
            }

            Row {
                width: parent.width
                height: 18
                spacing: 6

                Text {
                    text: "Applications"

                    color:
                        theme.textSecondary

                    font.family:
                        "JetBrainsMono Nerd Font"

                    font.pixelSize: 8

                    font.weight:
                        Font.DemiBold

                    verticalAlignment:
                        Text.AlignVCenter
                }

                Rectangle {
                    width:
                        parent.width - 78

                    height: 1

                    anchors.verticalCenter:
                        parent.verticalCenter

                    color:
                        Qt.rgba(
                            theme.outline.r,
                            theme.outline.g,
                            theme.outline.b,
                            0.12
                        )
                }
            }

            Column {
                id: applicationList

                width: parent.width

                spacing: 6

                Repeater {
                    model:
                        AudioService.applicationStreams

                    delegate: Rectangle {
                        required property var modelData

                        width:
                            applicationList.width

                        height: 70

                        radius:
                            theme.radiusMedium

                        color:
                            Qt.rgba(
                                theme.surfaceContainer.r,
                                theme.surfaceContainer.g,
                                theme.surfaceContainer.b,
                                0.48
                            )

                        border.width: 1

                        border.color:
                            Qt.rgba(
                                theme.outline.r,
                                theme.outline.g,
                                theme.outline.b,
                                0.14
                            )

                        Column {
                            anchors.fill: parent

                            anchors.margins: 9

                            spacing: 4

                            Row {
                                width: parent.width
                                height: 22
                                spacing: 7

                                Text {
                                    width: 22
                                    height: 22

                                    text: "󰀻"

                                    color:
                                        modelData &&
                                        modelData.audio &&
                                        modelData.audio.muted
                                        ? theme.error
                                        : theme.secondary

                                    font.family:
                                        "Symbols Nerd Font"

                                    font.pixelSize: 14

                                    horizontalAlignment:
                                        Text.AlignHCenter

                                    verticalAlignment:
                                        Text.AlignVCenter
                                }

                                Text {
                                    width:
                                        parent.width -
                                        22 -
                                        7 -
                                        48 -
                                        28 -
                                        7

                                    height: 22

                                    text:
                                        AudioService.applicationName(
                                            modelData
                                        )

                                    color:
                                        theme.text

                                    font.family:
                                        "JetBrainsMono Nerd Font"

                                    font.pixelSize: 9

                                    font.weight:
                                        Font.DemiBold

                                    elide:
                                        Text.ElideRight

                                    verticalAlignment:
                                        Text.AlignVCenter
                                }

                                Text {
                                    width: 48
                                    height: 22

                                    text:
                                        modelData &&
                                        modelData.audio
                                        ? Math.round(
                                            modelData.audio.volume * 100
                                        ) + "%"
                                        : "0%"

                                    color:
                                        modelData &&
                                        modelData.audio &&
                                        modelData.audio.muted
                                        ? theme.error
                                        : theme.textSecondary

                                    font.family:
                                        "JetBrainsMono Nerd Font"

                                    font.pixelSize: 8

                                    horizontalAlignment:
                                        Text.AlignRight

                                    verticalAlignment:
                                        Text.AlignVCenter
                                }

                                Rectangle {
                                    width: 28
                                    height: 22

                                    radius: 6

                                    color:
                                        modelData &&
                                        modelData.audio &&
                                        modelData.audio.muted
                                        ? Qt.rgba(
                                            theme.error.r,
                                            theme.error.g,
                                            theme.error.b,
                                            0.16
                                        )
                                        : Qt.rgba(
                                            theme.surface.r,
                                            theme.surface.g,
                                            theme.surface.b,
                                            0.22
                                        )

                                    Text {
                                        anchors.centerIn: parent

                                        text:
                                            modelData &&
                                            modelData.audio &&
                                            modelData.audio.muted
                                            ? "󰖁"
                                            : "󰕾"

                                        color:
                                            modelData &&
                                            modelData.audio &&
                                            modelData.audio.muted
                                            ? theme.error
                                            : theme.textSecondary

                                        font.family:
                                            "Symbols Nerd Font"

                                        font.pixelSize: 12
                                    }

                                    MouseArea {
                                        anchors.fill: parent

                                        cursorShape:
                                            Qt.PointingHandCursor

                                        onClicked:
                                            AudioService.toggleApplicationMute(
                                                modelData
                                            )
                                    }
                                }
                            }

                            Item {
                                id: applicationSliderArea

                                width: parent.width
                                height: 18

                                property real sliderValue:
                                    modelData &&
                                    modelData.audio
                                    ? modelData.audio.volume
                                    : 0

                                Rectangle {
                                    id: applicationTrack

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
                                            0.85
                                        )

                                    Rectangle {
                                        width:
                                            applicationTrack.width *
                                            Math.max(
                                                0,
                                                Math.min(
                                                    1,
                                                    applicationSliderArea.sliderValue /
                                                    1.5
                                                )
                                            )

                                        height:
                                            parent.height

                                        radius: 2

                                        color:
                                            modelData &&
                                            modelData.audio &&
                                            modelData.audio.muted
                                            ? theme.error
                                            : theme.secondary

                                        Behavior on width {
                                            NumberAnimation {
                                                duration: 90
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: 9
                                        height: 9

                                        radius: 4.5

                                        x:
                                            Math.max(
                                                0,
                                                Math.min(
                                                    applicationTrack.width - width,
                                                    applicationTrack.width *
                                                    Math.max(
                                                        0,
                                                        Math.min(
                                                            1,
                                                            applicationSliderArea.sliderValue /
                                                            1.5
                                                        )
                                                    ) -
                                                    width / 2
                                                )
                                            )

                                        anchors.verticalCenter:
                                            parent.verticalCenter

                                        color:
                                            modelData &&
                                            modelData.audio &&
                                            modelData.audio.muted
                                            ? theme.error
                                            : theme.secondary

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
                                            ratio * 1.5

                                        applicationSliderArea.sliderValue =
                                            value

                                        AudioService.setApplicationVolume(
                                            modelData,
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
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    visible:
                        AudioService.applicationStreams.length === 0

                    width:
                        applicationList.width

                    height: 58

                    radius:
                        theme.radiusMedium

                    color:
                        Qt.rgba(
                            theme.surfaceContainer.r,
                            theme.surfaceContainer.g,
                            theme.surfaceContainer.b,
                            0.32
                        )

                    border.width: 1

                    border.color:
                        Qt.rgba(
                            theme.outline.r,
                            theme.outline.g,
                            theme.outline.b,
                            0.12
                        )

                    Column {
                        anchors.centerIn: parent

                        spacing: 3

                        Text {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

                            text: "󰖁"

                            color:
                                theme.textSecondary

                            font.family:
                                "Symbols Nerd Font"

                            font.pixelSize: 15
                        }

                        Text {
                            text:
                                "No applications are playing audio"

                            color:
                                theme.textSecondary

                            font.family:
                                "JetBrainsMono Nerd Font"

                            font.pixelSize: 8

                            horizontalAlignment:
                                Text.AlignHCenter
                        }
                    }
                }
            }
        }
    }
}