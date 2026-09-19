import QtQuick
import Quickshell
import qs
import "./components"

PanelWindow {
    id: root

    property var modelData: null
    property bool minimalMode: false

    screen: root.modelData

    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 42
    exclusiveZone: 42
    aboveWindows: true

    Rectangle {
        id: bar

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 6
            leftMargin: 10
            rightMargin: 10
        }

        height: 30
        radius: 10

        color: Qt.rgba(
            theme.surface.r,
            theme.surface.g,
            theme.surface.b,
            root.minimalMode ? 0.07 : 0.48
        )

        border.width:
            root.minimalMode ? 0 : 1

        border.color:
            Qt.rgba(
                theme.outline.r,
                theme.outline.g,
                theme.outline.b,
                0.22
            )

        Behavior on color {
            ColorAnimation {
                duration: 220
            }
        }

        Behavior on border.width {
            NumberAnimation {
                duration: 180
            }
        }

        Theme {
            id: theme
        }

        Left {
            id: leftSide

            anchors {
                left: parent.left
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }
        }

        Power {
            id: powerSide

            anchors {
                left: leftSide.right
                leftMargin: 8
                verticalCenter: parent.verticalCenter
            }
        }

        Workspace {
            id: workspaceSide

            anchors {
                left: powerSide.right
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }
        }

        Center {
            id: centerSide

            anchors.centerIn: parent
        }

        Right {
            id: rightSide

            trayWindow: root

            anchors {
                right: parent.right
                rightMargin: 8
                verticalCenter: parent.verticalCenter
            }
        }

        Row {
            id: utilitySide

            anchors {
                right: modeButton.left
                rightMargin: 8
                verticalCenter: parent.verticalCenter
            }

            spacing: 6

            Clipboard {
                anchors.verticalCenter: parent.verticalCenter
            }

            Wallpaper {
                anchors.verticalCenter: parent.verticalCenter
            }

            Notification {
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Rectangle {
            id: modeButton

            anchors {
                right: rightSide.left
                rightMargin: 7
                verticalCenter: parent.verticalCenter
            }

            width: 26
            height: 22
            radius: 7

            color:
                root.minimalMode
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
                    0.55
                )

            border.width: 1

            border.color:
                Qt.rgba(
                    theme.outline.r,
                    theme.outline.g,
                    theme.outline.b,
                    0.15
                )

            Text {
                anchors.centerIn: parent

                text:
                    root.minimalMode ? "B" : "A"

                color: "#FFFFFF"

                font.family:
                    "JetBrainsMono Nerd Font"

                font.pixelSize: 10

                font.weight:
                    Font.Normal
            }

            MouseArea {
                anchors.fill: parent

                cursorShape:
                    Qt.PointingHandCursor

                acceptedButtons:
                    Qt.LeftButton

                onClicked: {
                    root.minimalMode =
                        !root.minimalMode
                }
            }
        }
    }
}