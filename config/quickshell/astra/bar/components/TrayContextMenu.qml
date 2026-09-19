import QtQuick
import Quickshell
import Quickshell.Wayland
import qs

PanelWindow {
    id: root

    property var menuHandle: null
    property real anchorX: 0
    property real anchorY: 0
    property bool menuOpen: false

    visible: false
    focusable: false

    color: "transparent"

    anchors {
        top: true
        right: true
        bottom: true
        left: true
    }

    WlrLayershell.exclusiveZone: -1
    WlrLayershell.layer: WlrLayer.Overlay

    Theme {
        id: theme
    }

    QsMenuOpener {
        id: opener

        menu: root.menuHandle
    }

    function openMenu(menu, x, y) {
        root.menuHandle = menu
        root.anchorX = x
        root.anchorY = y

        root.visible = true

        Qt.callLater(() => {
            root.menuOpen = true
        })
    }

    function closeMenu() {
        root.menuOpen = false
        closeTimer.restart()
    }

    Timer {
        id: closeTimer

        interval: 160
        repeat: false

        onTriggered: {
            root.visible = false
        }
    }

    MouseArea {
        id: outsideMouseArea

        anchors.fill: parent

        onClicked: {
            root.closeMenu()
        }
    }

    Rectangle {
        id: panel

        x: Math.max(
            8,
            Math.min(
                root.anchorX,
                root.width - width - 8
            )
        )

        y: Math.max(
            8,
            Math.min(
                root.anchorY + 6,
                root.height - height - 8
            )
        )

        width: 200
        height: column.implicitHeight + 16

        radius: 14

        color: Qt.rgba(
            theme.background.r,
            theme.background.g,
            theme.background.b,
            0.97
        )

        border.width: 1

        border.color: Qt.rgba(
            theme.outline.r,
            theme.outline.g,
            theme.outline.b,
            0.30
        )

        opacity: root.menuOpen ? 1 : 0
        scale: root.menuOpen ? 1 : 0.90

        transformOrigin: Item.TopRight

        Behavior on opacity {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutQuad
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutBack
                easing.overshoot: 1.4
            }
        }

        MouseArea {
            anchors.fill: parent

            onClicked: {}
        }

        Column {
            id: column

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 8

            spacing: 2

            Repeater {
                model: opener.children

                delegate: Item {
                    required property QsMenuEntry modelData

                    width: column.width
                    height: modelData.isSeparator ? 9 : 32

                    Rectangle {
                        visible: modelData.isSeparator

                        width: parent.width
                        height: 1

                        anchors.verticalCenter: parent.verticalCenter

                        color: Qt.rgba(
                            theme.outline.r,
                            theme.outline.g,
                            theme.outline.b,
                            0.18
                        )
                    }

                    Rectangle {
                        id: entryBackground

                        visible: !modelData.isSeparator

                        anchors.fill: parent

                        radius: 8

                        color:
                            entryMouse.containsMouse &&
                            modelData.enabled
                            ? Qt.rgba(
                                theme.primary.r,
                                theme.primary.g,
                                theme.primary.b,
                                0.18
                            )
                            : "transparent"

                        Behavior on color {
                            ColorAnimation {
                                duration: 100
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 10

                            text: modelData.text

                            color:
                                modelData.enabled
                                ? "#FFFFFF"
                                : Qt.rgba(1, 1, 1, 0.35)

                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10
                        }

                        MouseArea {
                            id: entryMouse

                            anchors.fill: parent

                            hoverEnabled: true
                            enabled: modelData.enabled

                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                modelData.triggered()
                                root.closeMenu()
                            }
                        }
                    }
                }
            }
        }
    }
}