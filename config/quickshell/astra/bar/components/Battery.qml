import QtQuick
import Quickshell
import qs
import qs.services

Item {
    id: root

    implicitWidth: batteryButton.width
    implicitHeight: 26

    Theme {
        id: theme
    }

    BatteryService {
        id: battery
    }

    property bool popupVisible: false

    Rectangle {
        id: batteryButton

        width: batteryRow.implicitWidth + 16
        height: 26

        radius: 7

        color: mouseArea.containsMouse
            ? Qt.rgba(
                theme.surfaceContainer.r,
                theme.surfaceContainer.g,
                theme.surfaceContainer.b,
                0.55
            )
            : "transparent"

        border.width:
            mouseArea.containsMouse ? 1 : 0

        border.color:
            Qt.rgba(
                0,
                0,
                0,
                mouseArea.containsMouse ? 0.28 : 0
            )

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }

        Row {
            id: batteryRow

            anchors.centerIn: parent

            spacing: 5

            Text {
                id: batteryIcon

                anchors.verticalCenter:
                    parent.verticalCenter

                text: "BAT"

                color: "#FFFFFF"

                font.family:
                    "JetBrainsMono Nerd Font"

                font.pixelSize: 9

                font.weight:
                    Font.DemiBold
            }

            Text {
                id: batteryText

                anchors.verticalCenter:
                    parent.verticalCenter

                text:
                    battery.available
                        ? battery.percentage + "%"
                        : "--"

                color: "#FFFFFF"

                font.family:
                    "JetBrainsMono Nerd Font"

                font.pixelSize: 10

                font.weight:
                    Font.Normal
            }
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
                if (!battery.available)
                    return

                root.popupVisible =
                    !root.popupVisible

                batteryPopup.visible =
                    root.popupVisible
            }
        }
    }

    BatteryPopup {
        id: batteryPopup

        visible: root.popupVisible

        batteryService: battery

        onClosed: {
            root.popupVisible = false
            batteryPopup.visible = false
        }
    }
}