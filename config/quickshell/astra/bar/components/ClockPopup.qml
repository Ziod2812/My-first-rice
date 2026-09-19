import QtQuick
import Quickshell
import Quickshell.Wayland
import qs

PanelWindow {
    id: root

    visible: false

    property string currentTime: ""
    property string currentDate: ""

    property real popupX: 8

    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.keyboardFocus:
        WlrKeyboardFocus.Exclusive

    Theme {
        id: theme
    }

    Rectangle {
        id: popupCard

        width: 320

        height:
            contentColumn.implicitHeight +
            theme.spacingXLarge * 2

        x: root.popupX
        y: 48

        radius: theme.radiusLarge

        color: theme.glassStrong

        border.width: theme.borderWidth

        border.color: theme.glassBorder

        opacity: root.visible ? 1 : 0

        scale: root.visible ? 1 : 0.97

        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 170
                easing.type: Easing.OutCubic
            }
        }

        Column {
            id: contentColumn

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }

            anchors.margins: theme.spacingXLarge

            spacing: theme.spacingLarge

            Text {
                width: parent.width

                text: root.currentTime

                color: theme.text

                horizontalAlignment:
                    Text.AlignHCenter

                font.family:
                    "JetBrainsMono Nerd Font"

                font.pixelSize: 30

                font.weight:
                    Font.DemiBold
            }

            Text {
                width: parent.width

                text: root.currentDate

                color: theme.textSecondary

                horizontalAlignment:
                    Text.AlignHCenter

                wrapMode:
                    Text.Wrap

                font.family:
                    "JetBrainsMono Nerd Font"

                font.pixelSize: 10

                font.weight:
                    Font.Normal
            }

            Rectangle {
                width: parent.width
                height: theme.borderWidth

                radius: 1

                color:
                    Qt.rgba(
                        theme.outline.r,
                        theme.outline.g,
                        theme.outline.b,
                        0.20
                    )
            }

            Calendar {
                width: parent.width
                height: 230
            }

            Rectangle {
                width: parent.width
                height: 34

                radius: theme.radiusSmall

                color:
                    closeMouseArea.containsMouse
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

                border.width:
                    closeMouseArea.containsMouse
                        ? theme.borderWidth
                        : 0

                border.color:
                    Qt.rgba(
                        theme.primary.r,
                        theme.primary.g,
                        theme.primary.b,
                        0.35
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

                Text {
                    anchors.centerIn: parent

                    text: "Close"

                    color:
                        closeMouseArea.containsMouse
                            ? theme.primary
                            : theme.text

                    font.family:
                        "JetBrainsMono Nerd Font"

                    font.pixelSize: 10

                    font.weight:
                        closeMouseArea.containsMouse
                            ? Font.DemiBold
                            : Font.Normal

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }
                    }
                }

                MouseArea {
                    id: closeMouseArea

                    anchors.fill: parent

                    hoverEnabled: true

                    cursorShape:
                        Qt.PointingHandCursor

                    acceptedButtons:
                        Qt.LeftButton

                    onClicked: {
                        root.visible = false
                        root.closed()
                    }
                }
            }
        }
    }

    MouseArea {
        id: outsideMouseArea

        anchors.fill: parent

        z: -1

        acceptedButtons:
            Qt.LeftButton

        onClicked: {
            root.visible = false
            root.closed()
        }
    }

    component Calendar: Item {
        id: calendar

        property date today: new Date()

        property int month:
            today.getMonth()

        property int year:
            today.getFullYear()

        function daysInMonth(y, m) {
            return new Date(
                y,
                m + 1,
                0
            ).getDate()
        }

        function firstDay(y, m) {
            return new Date(
                y,
                m,
                1
            ).getDay()
        }

        Column {
            anchors.fill: parent

            spacing: theme.spacingSmall

            Text {
                width: parent.width

                text:
                    Qt.formatDate(
                        new Date(
                            calendar.year,
                            calendar.month,
                            1
                        ),
                        "MMMM yyyy"
                    )

                color:
                    theme.text

                horizontalAlignment:
                    Text.AlignHCenter

                font.family:
                    "JetBrainsMono Nerd Font"

                font.pixelSize: 12

                font.weight:
                    Font.DemiBold
            }

            Row {
                width: parent.width

                Repeater {
                    model: [
                        "Sun",
                        "Mon",
                        "Tue",
                        "Wed",
                        "Thu",
                        "Fri",
                        "Sat"
                    ]

                    delegate: Text {
                        width:
                            calendar.width / 7

                        height: 20

                        text: modelData

                        color:
                            theme.textSecondary

                        horizontalAlignment:
                            Text.AlignHCenter

                        verticalAlignment:
                            Text.AlignVCenter

                        font.family:
                            "JetBrainsMono Nerd Font"

                        font.pixelSize: 8

                        font.weight:
                            Font.Normal
                    }
                }
            }

            Grid {
                width: parent.width

                columns: 7

                rows: 6

                spacing: 2

                Repeater {
                    model: 42

                    delegate: Rectangle {
                        width:
                            (
                                calendar.width - 12
                            ) / 7

                        height: 25

                        radius:
                            theme.radiusSmall

                        property int dayOffset:
                            index -
                            calendar.firstDay(
                                calendar.year,
                                calendar.month
                            )

                        property int day:
                            dayOffset + 1

                        property bool validDay:
                            dayOffset >= 0 &&
                            dayOffset <
                                calendar.daysInMonth(
                                    calendar.year,
                                    calendar.month
                                )

                        property bool isToday:
                            validDay &&
                            day ===
                                calendar.today.getDate() &&
                            calendar.month ===
                                calendar.today.getMonth() &&
                            calendar.year ===
                                calendar.today.getFullYear()

                        color:
                            isToday
                                ? Qt.rgba(
                                    theme.primary.r,
                                    theme.primary.g,
                                    theme.primary.b,
                                    0.24
                                )
                                : "transparent"

                        border.width:
                            isToday
                                ? theme.borderWidth
                                : 0

                        border.color:
                            Qt.rgba(
                                theme.primary.r,
                                theme.primary.g,
                                theme.primary.b,
                                0.38
                            )

                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                            }
                        }

                        Text {
                            anchors.centerIn: parent

                            text:
                                parent.validDay
                                    ? parent.day
                                    : ""

                            color:
                                parent.isToday
                                    ? theme.primary
                                    : theme.text

                            font.family:
                                "JetBrainsMono Nerd Font"

                            font.pixelSize: 9

                            font.weight:
                                parent.isToday
                                    ? Font.DemiBold
                                    : Font.Normal
                        }
                    }
                }
            }
        }
    }
}