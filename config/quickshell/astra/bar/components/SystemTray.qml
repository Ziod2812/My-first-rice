import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs

Item {
    id: root

    property var trayWindow: null

    implicitWidth: trayRow.implicitWidth
    implicitHeight: 26

    Loader {
        id: menuLoader

        active: true
        asynchronous: false
        source: "./TrayContextMenu.qml"
    }

    Row {
        id: trayRow

        anchors.centerIn: parent

        spacing: 3

        Repeater {
            model: SystemTray.items

            delegate: Item {
                required property var modelData

                width: 24
                height: 24

                Image {
                    id: trayIcon

                    anchors.centerIn: parent

                    width: 15
                    height: 15

                    source: modelData.icon

                    sourceSize.width: 32
                    sourceSize.height: 32

                    smooth: true

                    scale:
                        trayMouseArea.pressed
                        ? 0.85
                        : 1.0

                    Behavior on scale {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.OutQuad
                        }
                    }
                }

                MouseArea {
                    id: trayMouseArea

                    anchors.fill: parent

                    hoverEnabled: true

                    cursorShape:
                        Qt.PointingHandCursor

                    acceptedButtons:
                        Qt.LeftButton |
                        Qt.RightButton

                    onClicked: mouse => {
                        if (
                            mouse.button ===
                            Qt.LeftButton
                        ) {
                            modelData.activate()
                            return
                        }

                        if (
                            mouse.button ===
                            Qt.RightButton
                        ) {
                            if (
                                !modelData.hasMenu ||
                                !menuLoader.item
                            ) {
                                return
                            }

                            const absPos =
                                trayMouseArea.mapToItem(
                                    null,
                                    mouse.x,
                                    mouse.y
                                )

                            const barBottom =
                                root.trayWindow
                                ? root.trayWindow.height
                                : absPos.y

                            menuLoader.item.openMenu(
                                modelData.menu,
                                absPos.x,
                                barBottom
                            )
                        }
                    }
                }
            }
        }
    }
}