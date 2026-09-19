import QtQuick
import qs
import qs.services

Item {
    id: root

    implicitWidth:
        networkRow.implicitWidth + 10

    implicitHeight: 26

    Theme {
        id: theme
    }

    Rectangle {
        id: networkButton

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

        Behavior on border.color {
            ColorAnimation {
                duration: 120
            }
        }

        Row {
            id: networkRow

            anchors.centerIn: parent

            spacing: 5

            Text {
                id: networkIcon

                anchors.verticalCenter:
                    parent.verticalCenter

                text: {
                    if (
                        !NetworkService.wifiEnabled
                    ) {
                        return "󰖪"
                    }

                    if (
                        NetworkService.connecting
                    ) {
                        return "󰤨"
                    }

                    if (
                        !NetworkService.isConnected
                    ) {
                        return "󰤯"
                    }

                    const active =
                        NetworkService.active

                    if (!active)
                        return "󰤨"

                    if (
                        active.strength >= 80
                    )
                        return "󰤨"

                    if (
                        active.strength >= 60
                    )
                        return "󰤥"

                    if (
                        active.strength >= 40
                    )
                        return "󰤢"

                    if (
                        active.strength >= 20
                    )
                        return "󰤟"

                    return "󰤯"
                }

                color: {
                    if (
                        !NetworkService.wifiEnabled
                    ) {
                        return theme.error
                    }

                    if (
                        NetworkService.connecting
                    ) {
                        return theme.primary
                    }

                    if (
                        !NetworkService.isConnected
                    ) {
                        return theme.error
                    }

                    return "#FFFFFF"
                }

                font.family:
                    "Symbols Nerd Font"

                font.pixelSize: 15

                font.weight:
                    Font.Normal

                Behavior on color {
                    ColorAnimation {
                        duration: 180
                    }
                }
            }

            Text {
                id: networkText

                anchors.verticalCenter:
                    parent.verticalCenter

                text: {
                    if (
                        !NetworkService.wifiEnabled
                    ) {
                        return "Off"
                    }

                    if (
                        NetworkService.connecting
                    ) {
                        return "Connecting"
                    }

                    if (
                        !NetworkService.isConnected
                    ) {
                        return "Disconnected"
                    }

                    const active =
                        NetworkService.active

                    if (!active) {
                        return "Connected"
                    }

                    if (
                        active.ssid.length > 18
                    ) {
                        return active.ssid.substring(
                            0,
                            18
                        ) + "…"
                    }

                    return active.ssid
                }

                color: {
                    if (
                        !NetworkService.wifiEnabled
                    ) {
                        return theme.error
                    }

                    if (
                        NetworkService.connecting
                    ) {
                        return theme.primary
                    }

                    if (
                        !NetworkService.isConnected
                    ) {
                        return theme.error
                    }

                    return "#FFFFFF"
                }

                font.family:
                    "JetBrainsMono Nerd Font"

                font.pixelSize: 10

                font.weight:
                    Font.Normal

                elide:
                    Text.ElideRight

                Behavior on color {
                    ColorAnimation {
                        duration: 180
                    }
                }
            }
        }

        MouseArea {
            id: mouseArea

            anchors.fill: parent

            hoverEnabled: true

            cursorShape:
                Qt.PointingHandCursor

            onClicked: {
                if (!popupLoader.item) {
                    popupLoader.active = true
                    return
                }

                popupLoader.item.visible =
                    !popupLoader.item.visible
            }
        }
    }

    Loader {
        id: popupLoader

        active: false

        asynchronous: false

        source:
            "./NetworkPopup.qml"

        onLoaded: {
            if (item) {
                item.anchorItem = root
                item.visible = true
            }
        }
    }

    Connections {
        target: NetworkService

        function onPasswordRequired(
            ssid,
            bssid
        ) {
            popupLoader.active = true

            if (popupLoader.item) {
                popupLoader.item.visible = true
            }
        }
    }
}