import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs
import qs.services

Item {
    id: root

    width: workspaceRow.implicitWidth
    height: 26
    implicitWidth: workspaceRow.implicitWidth
    implicitHeight: 26

    Theme {
        id: theme
    }

    Row {
        id: workspaceRow

        anchors.verticalCenter: parent.verticalCenter

        spacing: 4

        Repeater {
            model: Hyprland.workspaces

            delegate: Rectangle {
                id: workspaceButton

                width: workspaceLabel.implicitWidth + 16
                height: 24

                radius: 8

                property var workspaceData: modelData

                color: workspaceData && workspaceData.focused
                    ? Qt.rgba(
                        theme.primary.r,
                        theme.primary.g,
                        theme.primary.b,
                        0.24
                    )
                    : workspaceData && workspaceData.urgent
                        ? Qt.rgba(
                            theme.error.r,
                            theme.error.g,
                            theme.error.b,
                            0.20
                        )
                        : Qt.rgba(
                            theme.surfaceContainer.r,
                            theme.surfaceContainer.g,
                            theme.surfaceContainer.b,
                            0.36
                        )

                border.width: 1

                border.color: workspaceData && workspaceData.focused
                    ? Qt.rgba(
                        theme.primary.r,
                        theme.primary.g,
                        theme.primary.b,
                        0.40
                    )
                    : Qt.rgba(
                        theme.outline.r,
                        theme.outline.g,
                        theme.outline.b,
                        0.12
                    )

                scale: workspaceData && workspaceData.focused ? 1.04 : 1.0

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

                Behavior on scale {
                    NumberAnimation {
                        duration: 140
                        easing.type: Easing.OutCubic
                    }
                }

                Text {
                    id: workspaceLabel

                    anchors.centerIn: parent

                    text: workspaceButton.workspaceData
                        ? String(
                            workspaceButton.workspaceData.name
                            || workspaceButton.workspaceData.id
                        )
                        : ""

                    color: workspaceButton.workspaceData
                        && workspaceButton.workspaceData.focused
                        ? theme.primary
                        : workspaceButton.workspaceData
                            && workspaceButton.workspaceData.urgent
                            ? theme.error
                            : theme.textSecondary

                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 9
                    font.bold: workspaceButton.workspaceData
                        && workspaceButton.workspaceData.focused

                    Behavior on color {
                        ColorAnimation {
                            duration: 160
                        }
                    }
                }

                Rectangle {
                    visible: workspaceButton.workspaceData
                        && workspaceButton.workspaceData.toplevels
                        && workspaceButton.workspaceData.toplevels.values.length > 0

                    width: 4
                    height: 4

                    radius: 2

                    anchors {
                        top: parent.top
                        right: parent.right
                        topMargin: 5
                        rightMargin: 5
                    }

                    color: workspaceButton.workspaceData
                        && workspaceButton.workspaceData.focused
                        ? theme.primary
                        : theme.textSecondary
                }

                MouseArea {
                    anchors.fill: parent

                    hoverEnabled: true

                    onEntered: {
                        workspaceButton.scale = workspaceButton.workspaceData
                            && workspaceButton.workspaceData.focused
                            ? 1.06
                            : 1.03
                    }

                    onExited: {
                        workspaceButton.scale = workspaceButton.workspaceData
                            && workspaceButton.workspaceData.focused
                            ? 1.04
                            : 1.0
                    }

                    onClicked: {
                        if (workspaceButton.workspaceData)
                            workspaceButton.workspaceData.activate()
                    }

                    onWheel: function(wheel) {
                        if (wheel.angleDelta.y > 0) {
                            HyprlandService.previousWorkspace()
                        } else if (wheel.angleDelta.y < 0) {
                            HyprlandService.nextWorkspace()
                        }
                    }
                }
            }
        }
    }
}