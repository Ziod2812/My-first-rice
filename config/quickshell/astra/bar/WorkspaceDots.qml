import QtQuick
import Quickshell
import Quickshell.Io
import qs

Row {
    id: root

    spacing: 5

    property int workspaceCount: 9
    property int activeWorkspace: 1

    Theme {
        id: theme
    }

    Process {
        id: workspaceProcess

        command: [
            "hyprctl",
            "activeworkspace",
            "-j"
        ]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(this.text)

                    if (data && data.id !== undefined) {
                        root.activeWorkspace = Number(data.id)
                    }
                } catch (error) {
                }
            }
        }
    }

    Timer {
        interval: 250
        running: true
        repeat: true

        onTriggered: {
            if (!workspaceProcess.running) {
                workspaceProcess.running = true
            }
        }
    }

    Repeater {
        model: root.workspaceCount

        delegate: Rectangle {
            id: dot

            required property int index

            readonly property int workspaceId: index + 1
            readonly property bool active:
                root.activeWorkspace === workspaceId

            width: active ? 18 : 7
            height: 7
            radius: 4

            color: active
                ? theme.primary
                : theme.outlineVariant

            opacity: active ? 1.0 : 0.62

            Behavior on width {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 180
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 180
                }
            }

            MouseArea {
                anchors.fill: parent

                hoverEnabled: false
                cursorShape: Qt.ArrowCursor

                onClicked: {
                    Quickshell.execDetached([
                        "hyprctl",
                        "dispatch",
                        'hl.dsp.focus({ workspace = "' +
                        String(dot.workspaceId) +
                        '" })'
                    ])
                }
            }
        }
    }
}