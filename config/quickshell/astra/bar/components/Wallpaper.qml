import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
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
    property bool scanning: false
    property var wallpapers: []

    Theme {
        id: theme
    }

    function openPopup() {
        root.popupVisible = true
        root.scanWallpapers()
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

    function scanWallpapers() {
        if (root.scanning)
            return

        root.scanning = true

        scanProcess.exec([
            "sh",
            "-c",
            "if [ -d \"$1\" ]; then find \"$1\" -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \\) -print | sort; fi",
            "sh",
            WallpaperService.wallpaperDirectory
        ])
    }

    function randomWallpaper() {
        if (root.wallpapers.length === 0)
            return

        WallpaperService.randomWallpaper(
            root.wallpapers
        )

        root.restartAutoCloseTimer()
    }

    function isCurrent(path) {
        return String(
            WallpaperService.currentWallpaper || ""
        ) === String(path || "")
    }

    function displayName(path) {
        var value = String(path || "")
        var parts = value.split("/")

        if (parts.length === 0)
            return value

        return parts[parts.length - 1]
    }

    function transitionName() {
        for (
            var i = 0;
            i < WallpaperService.transitions.length;
            i++
        ) {
            if (
                WallpaperService.transitions[i].id
                === WallpaperService.transitionType
            ) {
                return WallpaperService.transitions[i].name
            }
        }

        return "Fade"
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

        border.width: theme.borderWidth

        border.color: root.popupVisible
            ? Qt.rgba(
                theme.primary.r,
                theme.primary.g,
                theme.primary.b,
                0.36
            )
            : Qt.rgba(
                theme.outline.r,
                theme.outline.g,
                theme.outline.b,
                0.16
            )

        Text {
            anchors.centerIn: parent

            text: "󰸉"

            color: root.popupVisible
                ? theme.primary
                : theme.textSecondary

            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
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

    Process {
        id: scanProcess

        stdout: StdioCollector {
            onStreamFinished: {
                var value = String(
                    this.text || ""
                ).trim()

                var result = []

                if (value.length > 0) {
                    var lines = value.split("\n")

                    for (
                        var i = 0;
                        i < lines.length;
                        i++
                    ) {
                        var path = String(
                            lines[i] || ""
                        ).trim()

                        if (!path.length)
                            continue

                        result.push(path)
                    }
                }

                root.wallpapers = result
                root.scanning = false
            }
        }

        onExited: function(exitCode) {
            root.scanning = false
        }
    }

    PanelWindow {
        id: wallpaperPopup

        visible: root.popupVisible

        implicitWidth: 360
        implicitHeight: 560

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

            onClicked: {
                mouse.accepted = true
                root.closePopup()
            }
        }

        Rectangle {
            id: panel

            width: 360
            height: 560

            anchors {
                top: parent.top
                right: parent.right
            }

            radius: theme.radiusLarge

            clip: true

            color: theme.glassStrong

            border.width: theme.borderWidth

            border.color: theme.glassBorder

            scale: root.popupVisible
                ? 1
                : 0.96

            opacity: root.popupVisible
                ? 1
                : 0

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
                z: 0

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
                    height: 32

                    Text {
                        anchors {
                            left: parent.left
                            verticalCenter:
                                parent.verticalCenter
                        }

                        text: "Wallpapers"

                        color: theme.text

                        font.family:
                            "JetBrainsMono Nerd Font"

                        font.pixelSize: 15
                        font.bold: true
                    }

                    Row {
                        id: headerActions

                        anchors {
                            right: parent.right
                            verticalCenter:
                                parent.verticalCenter
                        }

                        spacing: 6

                        Rectangle {
                            id: randomButton

                            width: 78
                            height: 28

                            radius:
                                theme.radiusSmall

                            z: 10

                            color:
                                randomMouse.containsMouse
                                ? Qt.rgba(
                                    theme.primary.r,
                                    theme.primary.g,
                                    theme.primary.b,
                                    0.20
                                )
                                : Qt.rgba(
                                    theme.primary.r,
                                    theme.primary.g,
                                    theme.primary.b,
                                    0.12
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

                                text: "󰒝  Random"

                                color:
                                    theme.primary

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                font.pixelSize: 8
                                font.bold: true

                                horizontalAlignment:
                                    Text.AlignHCenter

                                verticalAlignment:
                                    Text.AlignVCenter
                            }

                            MouseArea {
                                id: randomMouse

                                anchors.fill: parent

                                hoverEnabled: true

                                onClicked: {
                                    mouse.accepted = true
                                    root.randomWallpaper()
                                }
                            }
                        }

                        Rectangle {
                            id: refreshButton

                            width: 28
                            height: 28

                            radius:
                                theme.radiusSmall

                            z: 10

                            color:
                                root.scanning
                                ? Qt.rgba(
                                    theme.primary.r,
                                    theme.primary.g,
                                    theme.primary.b,
                                    0.20
                                )
                                : refreshMouse.containsMouse
                                    ? Qt.rgba(
                                        theme.surfaceContainerHigh.r,
                                        theme.surfaceContainerHigh.g,
                                        theme.surfaceContainerHigh.b,
                                        0.90
                                    )
                                    : Qt.rgba(
                                        theme.surfaceContainerHigh.r,
                                        theme.surfaceContainerHigh.g,
                                        theme.surfaceContainerHigh.b,
                                        0.65
                                    )

                            border.width:
                                theme.borderWidth

                            border.color:
                                root.scanning
                                ? Qt.rgba(
                                    theme.primary.r,
                                    theme.primary.g,
                                    theme.primary.b,
                                    0.34
                                )
                                : Qt.rgba(
                                    theme.outline.r,
                                    theme.outline.g,
                                    theme.outline.b,
                                    0.18
                                )

                            Text {
                                anchors.centerIn:
                                    parent

                                text:
                                    root.scanning
                                    ? "󰑓"
                                    : "󰑐"

                                color:
                                    root.scanning
                                    ? theme.primary
                                    : theme.textSecondary

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                font.pixelSize: 12

                                RotationAnimation on rotation {
                                    running: root.scanning

                                    from: 0
                                    to: 360

                                    duration: 900

                                    loops:
                                        Animation.Infinite
                                }
                            }

                            MouseArea {
                                id: refreshMouse

                                anchors.fill: parent

                                z: 20

                                hoverEnabled: true

                                onClicked: {
                                    mouse.accepted = true
                                    root.scanWallpapers()
                                }
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
                            0.14
                        )
                }

                Item {
                    width: parent.width
                    height: 22

                    Text {
                        anchors {
                            left: parent.left
                            verticalCenter:
                                parent.verticalCenter
                        }

                        text:
                            root.scanning
                            ? "Refreshing..."
                            : String(
                                root.wallpapers.length
                            ) + " wallpapers"

                        color:
                            root.scanning
                            ? theme.primary
                            : theme.textSecondary

                        font.family:
                            "JetBrainsMono Nerd Font"

                        font.pixelSize: 8
                    }

                    Text {
                        anchors {
                            right: parent.right
                            verticalCenter:
                                parent.verticalCenter
                        }

                        text:
                            root.transitionName()
                            + " · "
                            + Number(
                                WallpaperService
                                .transitionDuration
                            ).toFixed(1)
                            + "s"

                        color: theme.primary

                        font.family:
                            "JetBrainsMono Nerd Font"

                        font.pixelSize: 8
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 116

                    radius:
                        theme.radiusMedium

                    color:
                        Qt.rgba(
                            theme.surfaceContainer.r,
                            theme.surfaceContainer.g,
                            theme.surfaceContainer.b,
                            0.52
                        )

                    border.width:
                        theme.borderWidth

                    border.color:
                        Qt.rgba(
                            theme.outline.r,
                            theme.outline.g,
                            theme.outline.b,
                            0.14
                        )

                    Column {
                        anchors.fill: parent

                        anchors.margins: 10

                        spacing: 8

                        Row {
                            width: parent.width
                            height: 18

                            Text {
                                anchors.verticalCenter:
                                    parent.verticalCenter

                                text: "Transition"

                                color: theme.text

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                font.pixelSize: 9
                                font.bold: true
                            }

                            Item {
                                width:
                                    parent.width
                                    - selectedTransition.width
                                    - 8

                                height: 1
                            }

                            Text {
                                id: selectedTransition

                                anchors.verticalCenter:
                                    parent.verticalCenter

                                text:
                                    root.transitionName()

                                color:
                                    theme.primary

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                font.pixelSize: 8
                            }
                        }

                        Flickable {
                            id: transitionFlickable

                            width: parent.width
                            height: 28

                            contentWidth:
                                transitionRow.width

                            contentHeight:
                                height

                            clip: true

                            flickableDirection:
                                Flickable.HorizontalFlick

                            boundsBehavior:
                                Flickable.StopAtBounds

                            Row {
                                id: transitionRow

                                height:
                                    parent.height

                                spacing: 5

                                Repeater {
                                    model:
                                        WallpaperService.transitions

                                    delegate: Rectangle {
                                        id: transitionButton

                                        width:
                                            Math.max(
                                                50,
                                                transitionText
                                                .implicitWidth
                                                + 18
                                            )

                                        height: 26

                                        radius:
                                            theme.radiusSmall

                                        property string transitionId:
                                            String(
                                                modelData.id
                                            )

                                        property bool selected:
                                            WallpaperService
                                            .transitionType
                                            === transitionId

                                        color:
                                            transitionMouse
                                            .containsMouse
                                            ? Qt.rgba(
                                                theme.primary.r,
                                                theme.primary.g,
                                                theme.primary.b,
                                                0.18
                                            )
                                            : selected
                                                ? Qt.rgba(
                                                    theme.primary.r,
                                                    theme.primary.g,
                                                    theme.primary.b,
                                                    0.15
                                                )
                                                : Qt.rgba(
                                                    theme.surfaceContainerHigh.r,
                                                    theme.surfaceContainerHigh.g,
                                                    theme.surfaceContainerHigh.b,
                                                    0.48
                                                )

                                        border.width:
                                            theme.borderWidth

                                        border.color:
                                            selected
                                            ? Qt.rgba(
                                                theme.primary.r,
                                                theme.primary.g,
                                                theme.primary.b,
                                                0.36
                                            )
                                            : Qt.rgba(
                                                theme.outline.r,
                                                theme.outline.g,
                                                theme.outline.b,
                                                0.13
                                            )

                                        Text {
                                            id: transitionText

                                            anchors.centerIn:
                                                parent

                                            text:
                                                String(
                                                    modelData.name
                                                )

                                            color:
                                                transitionButton
                                                .selected
                                                ? theme.primary
                                                : theme.textSecondary

                                            font.family:
                                                "JetBrainsMono Nerd Font"

                                            font.pixelSize: 7

                                            font.bold:
                                                transitionButton
                                                .selected
                                        }

                                        MouseArea {
                                            id: transitionMouse

                                            anchors.fill:
                                                parent

                                            hoverEnabled: true

                                            onClicked: {
                                                mouse.accepted =
                                                    true

                                                WallpaperService
                                                .setTransition(
                                                    transitionButton
                                                    .transitionId
                                                )

                                                root.restartAutoCloseTimer()
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Row {
                            width: parent.width
                            height: 28
                            spacing: 8

                            Text {
                                anchors.verticalCenter:
                                    parent.verticalCenter

                                text: "Duration"

                                color:
                                    theme.textSecondary

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                font.pixelSize: 8
                            }

                            Rectangle {
                                id: durationTrack

                                width:
                                    parent.width
                                    - durationValue.width
                                    - 62

                                height: 5

                                radius: 3

                                anchors.verticalCenter:
                                    parent.verticalCenter

                                color:
                                    Qt.rgba(
                                        theme.outline.r,
                                        theme.outline.g,
                                        theme.outline.b,
                                        0.24
                                    )

                                Rectangle {
                                    width:
                                        durationTrack.width
                                        * Math.max(
                                            0,
                                            Math.min(
                                                1,
                                                WallpaperService
                                                .transitionDuration
                                                / 5
                                            )
                                        )

                                    height:
                                        parent.height

                                    radius: 3

                                    color:
                                        theme.primary
                                }

                                Rectangle {
                                    width: 10
                                    height: 10

                                    radius: 5

                                    anchors.verticalCenter:
                                        parent.verticalCenter

                                    x:
                                        Math.max(
                                            0,
                                            Math.min(
                                                durationTrack.width
                                                - 10,
                                                durationTrack.width
                                                * Math.max(
                                                    0,
                                                    Math.min(
                                                        1,
                                                        WallpaperService
                                                        .transitionDuration
                                                        / 5
                                                    )
                                                ) - 5
                                            )
                                        )

                                    color:
                                        theme.primary

                                    border.width: 2

                                    border.color:
                                        theme.surface
                                }

                                MouseArea {
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                    }

                                    height: 24

                                    anchors.verticalCenter:
                                        parent.verticalCenter

                                    onPressed:
                                        function(mouse) {
                                            var ratio =
                                                Math.max(
                                                    0,
                                                    Math.min(
                                                        1,
                                                        mouse.x
                                                        / width
                                                    )
                                                )

                                            WallpaperService
                                            .setTransitionDuration(
                                                Math.round(
                                                    ratio * 50
                                                ) / 10
                                            )

                                            root.restartAutoCloseTimer()
                                        }

                                    onPositionChanged:
                                        function(mouse) {
                                            if (!pressed)
                                                return

                                            var ratio =
                                                Math.max(
                                                    0,
                                                    Math.min(
                                                        1,
                                                        mouse.x
                                                        / width
                                                    )
                                                )

                                            WallpaperService
                                            .setTransitionDuration(
                                                Math.round(
                                                    ratio * 50
                                                ) / 10
                                            )

                                            root.restartAutoCloseTimer()
                                        }
                                }
                            }

                            Text {
                                id: durationValue

                                width: 38

                                anchors.verticalCenter:
                                    parent.verticalCenter

                                text:
                                    Number(
                                        WallpaperService
                                        .transitionDuration
                                    ).toFixed(1)
                                    + "s"

                                color:
                                    theme.primary

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                font.pixelSize: 8

                                horizontalAlignment:
                                    Text.AlignRight
                            }
                        }
                    }
                }

                GridView {
                    id: wallpaperGrid

                    width: parent.width

                    height:
                        parent.height - 170

                    clip: true

                    cellWidth: 108
                    cellHeight: 108

                    model:
                        root.wallpapers

                    interactive: true

                    boundsBehavior:
                        Flickable.StopAtBounds

                    delegate: Rectangle {
                        id: wallpaperCard

                        width: 102
                        height: 102

                        radius:
                            theme.radiusMedium

                        property string wallpaperPath:
                            String(
                                modelData || ""
                            )

                        property bool selected:
                            root.isCurrent(
                                wallpaperPath
                            )

                        color:
                            selected
                            ? Qt.rgba(
                                theme.primary.r,
                                theme.primary.g,
                                theme.primary.b,
                                0.16
                            )
                            : Qt.rgba(
                                theme.surfaceContainer.r,
                                theme.surfaceContainer.g,
                                theme.surfaceContainer.b,
                                0.62
                            )

                        border.width:
                            selected
                            ? 2
                            : theme.borderWidth

                        border.color:
                            selected
                            ? theme.primary
                            : Qt.rgba(
                                theme.outline.r,
                                theme.outline.g,
                                theme.outline.b,
                                0.14
                            )

                        scale:
                            wallpaperMouse.containsMouse
                            ? 1.02
                            : 1

                        Behavior on scale {
                            NumberAnimation {
                                duration: 120
                                easing.type:
                                    Easing.OutCubic
                            }
                        }

                        Image {
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                            }

                            height: 66

                            anchors.topMargin: 5
                            anchors.leftMargin: 5
                            anchors.rightMargin: 5

                            source:
                                wallpaperCard
                                .wallpaperPath.length
                                ? "file://"
                                  + wallpaperCard
                                  .wallpaperPath
                                : ""

                            fillMode:
                                Image.PreserveAspectCrop

                            asynchronous: true
                            cache: false
                            mipmap: true

                            sourceSize.width: 220
                            sourceSize.height: 140

                            Rectangle {
                                anchors.fill:
                                    parent

                                radius: 7

                                color:
                                    "transparent"

                                border.width:
                                    1

                                border.color:
                                    Qt.rgba(
                                        theme.outline.r,
                                        theme.outline.g,
                                        theme.outline.b,
                                        0.10
                                    )
                            }
                        }

                        Text {
                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                            }

                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            anchors.bottomMargin: 7

                            text:
                                root.displayName(
                                    wallpaperCard
                                    .wallpaperPath
                                )

                            color:
                                wallpaperCard.selected
                                ? theme.primary
                                : theme.textSecondary

                            font.family:
                                "JetBrainsMono Nerd Font"

                            font.pixelSize: 7

                            elide:
                                Text.ElideMiddle

                            horizontalAlignment:
                                Text.AlignHCenter
                        }

                        Rectangle {
                            visible:
                                wallpaperCard.selected

                            width: 17
                            height: 17

                            radius: 6

                            anchors {
                                top: parent.top
                                right: parent.right
                                topMargin: 5
                                rightMargin: 5
                            }

                            color:
                                theme.primary

                            Text {
                                anchors.centerIn:
                                    parent

                                text: "󰄬"

                                color:
                                    theme.primaryText

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                font.pixelSize: 9
                            }
                        }

                        MouseArea {
                            id: wallpaperMouse

                            anchors.fill:
                                parent

                            hoverEnabled: true

                            onClicked: {
                                mouse.accepted = true

                                WallpaperService
                                .setWallpaper(
                                    wallpaperCard
                                    .wallpaperPath
                                )

                                root.restartAutoCloseTimer()
                            }
                        }
                    }

                    Text {
                        anchors.centerIn:
                            parent

                        visible:
                            !WallpaperService.available
                            || root.wallpapers.length
                            === 0

                        text:
                            root.scanning
                            ? "Refreshing..."
                            : !WallpaperService.available
                                ? "awww unavailable"
                                : "No wallpapers found"

                        color:
                            root.scanning
                            ? theme.primary
                            : theme.textSecondary

                        font.family:
                            "JetBrainsMono Nerd Font"

                        font.pixelSize: 10
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