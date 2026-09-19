import QtQuick
import Quickshell
import qs
import qs.services

Item {
    id: root

    implicitWidth: statsRow.implicitWidth
    implicitHeight: 26

    Theme {
        id: theme
    }

    SystemStatsService {
        id: stats
    }

    Row {
        id: statsRow

        anchors.centerIn: parent

        spacing: 7

        Text {
            id: cpuText

            text: "CPU " + Math.round(stats.cpuUsage) + "%"

            color: "#FFFFFF"

            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 10
            font.weight: Font.Normal
        }

        Rectangle {
            width: 1
            height: 8

            anchors.verticalCenter: parent.verticalCenter

            color: Qt.rgba(
                theme.outline.r,
                theme.outline.g,
                theme.outline.b,
                0.28
            )
        }

        Text {
            id: ramText

            text: {
                if (stats.memoryTotal <= 0)
                    return "RAM --"

                const ram = Math.round(stats.memoryUsed * 10) / 10

                return "RAM " + ram + "G " + stats.memoryType
            }

            color: "#FFFFFF"

            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 10
            font.weight: Font.Normal
        }

        Rectangle {
            width: 1
            height: 8

            anchors.verticalCenter: parent.verticalCenter

            color: Qt.rgba(
                theme.outline.r,
                theme.outline.g,
                theme.outline.b,
                0.28
            )
        }

        Text {
            id: gpuText

            visible: stats.gpuUsage >= 0

            text: "GPU " + Math.round(stats.gpuUsage) + "%"

            color: "#FFFFFF"

            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 10
            font.weight: Font.Normal
        }

        Rectangle {
            visible: stats.gpuUsage >= 0

            width: 1
            height: 8

            anchors.verticalCenter: parent.verticalCenter

            color: Qt.rgba(
                theme.outline.r,
                theme.outline.g,
                theme.outline.b,
                0.28
            )
        }

        Text {
            id: diskText

            text: stats.diskType + " " + Math.round(stats.diskPercent) + "%"

            color: "#FFFFFF"

            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 10
            font.weight: Font.Normal
        }
    }

    MouseArea {
        id: statsMouseArea

        anchors.fill: parent

        acceptedButtons: Qt.LeftButton

        cursorShape: Qt.PointingHandCursor

        hoverEnabled: true

        onClicked: {
            Quickshell.execDetached([
                "alacritty",
                "-e",
                "btop"
            ])
        }
    }
}