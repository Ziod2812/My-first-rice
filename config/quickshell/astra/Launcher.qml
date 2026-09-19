import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs

Item {
    id: root

    property bool visibleLauncher: false
    property string searchText: ""
    property int selectedIndex: 0

    readonly property color bg: "#2A2A3C"
    readonly property color panel: "#33334A"
    readonly property color panelDark: "#26263A"
    readonly property color panelHover: "#3B3B54"
    readonly property color selected: "#3A3550"
    readonly property color border: "#2E313D"

    readonly property color text: "#E3E1E9"
    readonly property color brightText: "#F7F6FB"
    readonly property color title: "#ECE9F5"
    readonly property color muted: "#8C8FA3"
    readonly property color graphText: "#B9B7D6"

    readonly property color purple: "#D0BCFF"
    readonly property color blue: "#89B4FA"
    readonly property color cyan: "#74D7F7"
    readonly property color green: "#A6E3A1"
    readonly property color pink: "#F5C2E7"
    readonly property color red: "#F38BA8"
    readonly property color process: "#AFA8FF"

    readonly property string monoFont: "JetBrainsMono Nerd Font"

    function openLauncher() {
        root.visibleLauncher = true
        root.searchText = ""
        root.selectedIndex = 0
        launcherWindow.visible = true

        Qt.callLater(function() {
            searchInput.forceActiveFocus()
        })
    }

    function closeLauncher() {
        root.visibleLauncher = false
        launcherWindow.visible = false
        root.searchText = ""
        root.selectedIndex = 0
    }

    function toggleLauncher() {
        if (root.visibleLauncher)
            root.closeLauncher()
        else
            root.openLauncher()
    }

    function launchSelected() {
        const apps = filteredApps.values

        if (apps.length === 0)
            return

        if (
            root.selectedIndex < 0 ||
            root.selectedIndex >= apps.length
        )
            return

        const entry = apps[root.selectedIndex]

        if (!entry)
            return

        root.closeLauncher()
        entry.execute()
    }

    function moveSelection(delta) {
        const count = filteredApps.values.length

        if (count <= 0) {
            root.selectedIndex = 0
            return
        }

        root.selectedIndex += delta

        if (root.selectedIndex < 0)
            root.selectedIndex = count - 1

        if (root.selectedIndex >= count)
            root.selectedIndex = 0

        Qt.callLater(function() {
            appList.positionViewAtIndex(
                root.selectedIndex,
                ListView.Contain
            )
        })
    }

    function moveHorizontal(delta) {
        const count = filteredApps.values.length

        if (count <= 0) {
            root.selectedIndex = 0
            return
        }

        root.selectedIndex += delta

        if (root.selectedIndex < 0)
            root.selectedIndex = count - 1

        if (root.selectedIndex >= count)
            root.selectedIndex = 0

        Qt.callLater(function() {
            appList.positionViewAtIndex(
                root.selectedIndex,
                ListView.Contain
            )
        })
    }

    ScriptModel {
        id: filteredApps

        objectProp: "id"

        values: {
            const query =
                root.searchText
                    .trim()
                    .toLowerCase()

            const apps =
                [...DesktopEntries.applications.values]

            if (query.length === 0) {
                return apps.sort(function(a, b) {
                    return String(a.name || "")
                        .localeCompare(
                            String(b.name || "")
                        )
                })
            }

            return apps
                .filter(function(entry) {
                    const name =
                        String(
                            entry.name || ""
                        ).toLowerCase()

                    const genericName =
                        String(
                            entry.genericName || ""
                        ).toLowerCase()

                    const comment =
                        String(
                            entry.comment || ""
                        ).toLowerCase()

                    return (
                        name.includes(query) ||
                        genericName.includes(query) ||
                        comment.includes(query)
                    )
                })
                .sort(function(a, b) {
                    return String(a.name || "")
                        .localeCompare(
                            String(b.name || "")
                        )
                })
        }
    }

    IpcHandler {
        target: "launcher"

        function open(): void {
            root.openLauncher()
        }

        function close(): void {
            root.closeLauncher()
        }

        function toggle(): void {
            root.toggleLauncher()
        }
    }

    PanelWindow {
        id: launcherWindow

        visible: false

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        exclusiveZone: -1
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        Item {
            anchors.fill: parent

            MouseArea {
                anchors.fill: parent

                onClicked: function(mouse) {
                    const insidePanel =
                        mouse.x >= launcherPanel.x &&
                        mouse.x <=
                            launcherPanel.x +
                            launcherPanel.width &&
                        mouse.y >= launcherPanel.y &&
                        mouse.y <=
                            launcherPanel.y +
                            launcherPanel.height

                    if (!insidePanel)
                        root.closeLauncher()
                }
            }

            Rectangle {
                id: launcherPanel

                anchors.centerIn: parent

                width: 580
                height: 440

                radius: 22

                color: Qt.rgba(
                    root.bg.r,
                    root.bg.g,
                    root.bg.b,
                    0.88
                )

                border.width: 1
                border.color:
                    Qt.rgba(
                        root.border.r,
                        root.border.g,
                        root.border.b,
                        0.30
                    )

                opacity:
                    root.visibleLauncher
                    ? 1
                    : 0

                scale:
                    root.visibleLauncher
                    ? 1
                    : 0.96

                Behavior on opacity {
                    NumberAnimation {
                        duration: 120
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 140
                        easing.type: Easing.OutCubic
                    }
                }

                Item {
                    id: content

                    anchors {
                        fill: parent
                        margins: 18
                    }

                    Text {
                        id: title

                        anchors {
                            top: parent.top
                            left: parent.left
                        }

                        text: "Launcher"

                        color: root.brightText

                        font.family: root.monoFont
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                    }

                    Text {
                        anchors {
                            left: title.right
                            bottom: title.bottom
                            leftMargin: 10
                            bottomMargin: 3
                        }

                        text:
                            root.searchText.length > 0
                            ? filteredApps.values.length + " results"
                            : filteredApps.values.length + " apps"

                        color: root.muted

                        font.family: root.monoFont
                        font.pixelSize: 9
                    }

                    Rectangle {
                        id: searchBox

                        anchors {
                            top: title.bottom
                            left: parent.left
                            right: parent.right
                            topMargin: 12
                        }

                        height: 44

                        radius: 15

                        color: root.panelDark

                        border.width: 1.5

                        border.color:
                            root.searchText.length > 0
                            ? Qt.rgba(
                                root.purple.r,
                                root.purple.g,
                                root.purple.b,
                                0.55
                            )
                            : root.border

                        Behavior on border.color {
                            ColorAnimation {
                                duration: 100
                            }
                        }

                        Rectangle {
                            id: searchIconBadge

                            anchors {
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                                leftMargin: 8
                            }

                            width: 28
                            height: 28
                            radius: 9

                            color:
                                root.searchText.length > 0
                                ? Qt.rgba(
                                    root.purple.r,
                                    root.purple.g,
                                    root.purple.b,
                                    0.16
                                )
                                : "transparent"

                            Text {
                                anchors.centerIn: parent

                                text: "󰍉"

                                color:
                                    root.searchText.length > 0
                                    ? root.purple
                                    : root.muted

                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 14
                            }
                        }

                        TextInput {
                            id: searchInput

                            anchors {
                                left: searchIconBadge.right
                                right: clearButton.left
                                top: parent.top
                                bottom: parent.bottom
                                leftMargin: 10
                                rightMargin: 10
                            }

                            color: root.text

                            selectionColor: root.selected
                            selectedTextColor: root.brightText

                            font.family: root.monoFont
                            font.pixelSize: 11

                            verticalAlignment:
                                Text.AlignVCenter

                            clip: true

                            onTextChanged: {
                                if (
                                    root.searchText !== text
                                )
                                    root.searchText = text

                                root.selectedIndex = 0
                            }

                            Keys.onPressed: function(event) {
                                if (
                                    event.key ===
                                    Qt.Key_Escape
                                ) {
                                    root.closeLauncher()
                                    event.accepted = true
                                    return
                                }

                                if (
                                    event.key ===
                                    Qt.Key_Down
                                ) {
                                    root.moveSelection(1)
                                    event.accepted = true
                                    return
                                }

                                if (
                                    event.key ===
                                    Qt.Key_Up
                                ) {
                                    root.moveSelection(-1)
                                    event.accepted = true
                                    return
                                }

                                if (
                                    event.key ===
                                    Qt.Key_Right
                                ) {
                                    root.moveHorizontal(1)
                                    event.accepted = true
                                    return
                                }

                                if (
                                    event.key ===
                                    Qt.Key_Left
                                ) {
                                    root.moveHorizontal(-1)
                                    event.accepted = true
                                    return
                                }

                                if (
                                    event.key ===
                                    Qt.Key_Return ||
                                    event.key ===
                                    Qt.Key_Enter
                                ) {
                                    root.launchSelected()
                                    event.accepted = true
                                }
                            }

                            Text {
                                anchors {
                                    left: parent.left
                                    verticalCenter:
                                        parent.verticalCenter
                                }

                                visible:
                                    searchInput.text.length === 0

                                text:
                                    "Search applications..."

                                color: root.muted

                                font.family: root.monoFont
                                font.pixelSize: 11
                            }
                        }

                        Rectangle {
                            id: clearButton

                            anchors {
                                right: parent.right
                                verticalCenter:
                                    parent.verticalCenter
                                rightMargin: 10
                            }

                            width: 24
                            height: 24

                            radius: 12

                            visible:
                                root.searchText.length > 0

                            color: root.selected

                            MouseArea {
                                anchors.fill: parent

                                onClicked: {
                                    searchInput.text = ""
                                    searchInput.forceActiveFocus()
                                }
                            }

                            Text {
                                anchors.centerIn: parent

                                text: "×"

                                color: root.brightText

                                font.family: root.monoFont
                                font.pixelSize: 13
                            }
                        }
                    }

                    Item {
                        id: section

                        anchors {
                            top: searchBox.bottom
                            left: searchBox.left
                            right: searchBox.right
                            topMargin: 16
                        }

                        height: 18

                        Text {
                            anchors {
                                left: parent.left
                                verticalCenter:
                                    parent.verticalCenter
                            }

                            text: "APPLICATIONS"

                            color: root.graphText

                            font.family: root.monoFont
                            font.pixelSize: 7
                            font.weight: Font.DemiBold

                            opacity: 0.7
                        }

                        Text {
                            anchors {
                                right: parent.right
                                verticalCenter:
                                    parent.verticalCenter
                            }

                            text:
                                root.searchText.length > 0
                                ? "FILTERED"
                                : "ALL"

                            color:
                                root.searchText.length > 0
                                ? root.purple
                                : root.muted

                            font.family: root.monoFont
                            font.pixelSize: 7
                            font.weight: Font.DemiBold
                        }
                    }

                    ListView {
                        id: appList

                        anchors {
                            top: section.bottom
                            bottom: footer.top
                            left: parent.left
                            right: parent.right
                            topMargin: 6
                            bottomMargin: 6
                        }

                        clip: true
                        spacing: 3
                        snapMode: ListView.SnapToItem

                        model: filteredApps

                        boundsBehavior:
                            Flickable.StopAtBounds

                        interactive:
                            contentHeight > height

                        delegate: Item {
                            id: appRow

                            required property var modelData
                            required property int index

                            width: appList.width
                            height: 48

                            Rectangle {
                                id: card

                                anchors.fill: parent

                                radius: 16

                                color:
                                    index ===
                                    root.selectedIndex
                                    ? root.selected
                                    : (rowHover.containsMouse
                                        ? root.panelHover
                                        : "transparent")

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 80
                                    }
                                }

                                Rectangle {
                                    id: iconBox

                                    anchors {
                                        left: parent.left
                                        verticalCenter:
                                            parent.verticalCenter
                                        leftMargin: 12
                                    }

                                    width: 32
                                    height: 32

                                    radius: 10

                                    color:
                                        index ===
                                        root.selectedIndex
                                        ? Qt.rgba(
                                            root.purple.r,
                                            root.purple.g,
                                            root.purple.b,
                                            0.16
                                        )
                                        : root.panel

                                    IconImage {
                                        anchors.centerIn:
                                            parent

                                        width: 20
                                        height: 20

                                        source:
                                            modelData &&
                                            modelData.icon !== ""
                                            ? Quickshell.iconPath(
                                                modelData.icon,
                                                true
                                            )
                                            : ""

                                        mipmap: true
                                    }
                                }

                                Column {
                                    id: labels

                                    anchors {
                                        left: iconBox.right
                                        right: arrow.left
                                        verticalCenter:
                                            parent.verticalCenter
                                        leftMargin: 10
                                        rightMargin: 8
                                    }

                                    spacing: 1

                                    Text {
                                        width: parent.width

                                        text:
                                            modelData
                                            ? String(
                                                modelData.name || ""
                                            )
                                            : ""

                                        color:
                                            index ===
                                            root.selectedIndex
                                            ? root.brightText
                                            : root.text

                                        font.family: root.monoFont
                                        font.pixelSize: 10

                                        font.weight:
                                            index ===
                                            root.selectedIndex
                                            ? Font.DemiBold
                                            : Font.Normal

                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        width: parent.width

                                        text:
                                            modelData
                                            ? String(
                                                modelData.genericName ||
                                                modelData.comment ||
                                                ""
                                            )
                                            : ""

                                        visible: text.length > 0

                                        color: root.muted

                                        font.family: root.monoFont
                                        font.pixelSize: 7

                                        elide: Text.ElideRight
                                    }
                                }

                                Text {
                                    id: arrow

                                    anchors {
                                        right: parent.right
                                        verticalCenter:
                                            parent.verticalCenter
                                        rightMargin: 16
                                    }

                                    text: "›"

                                    color: root.purple

                                    font.family: root.monoFont
                                    font.pixelSize: 18
                                    font.weight:
                                        Font.DemiBold

                                    visible:
                                        index ===
                                        root.selectedIndex
                                }

                                MouseArea {
                                    id: rowHover

                                    anchors.fill: parent

                                    hoverEnabled: true

                                    onEntered: {
                                        root.selectedIndex =
                                            index
                                    }

                                    onClicked: {
                                        root.selectedIndex =
                                            index
                                        root.launchSelected()
                                    }
                                }
                            }
                        }

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                            width: 3
                        }
                    }

                    Rectangle {
                        anchors.centerIn: appList

                        visible:
                            filteredApps.values.length === 0

                        width: 250
                        height: 82

                        radius: 16

                        color: root.panelDark

                        Text {
                            anchors {
                                top: parent.top
                                horizontalCenter:
                                    parent.horizontalCenter
                                topMargin: 13
                            }

                            text: "󰍉"

                            color: root.muted

                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 19
                        }

                        Text {
                            anchors {
                                bottom: parent.bottom
                                horizontalCenter:
                                    parent.horizontalCenter
                                bottomMargin: 14
                            }

                            text: "No applications found"

                            color: root.muted

                            font.family: root.monoFont
                            font.pixelSize: 8
                        }
                    }

                    Item {
                        id: footer

                        anchors {
                            bottom: parent.bottom
                            left: parent.left
                            right: parent.right
                        }

                        height: 20

                        Row {
                            anchors {
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                            }

                            spacing: 6

                            Rectangle {
                                width: hintNav.width + 14
                                height: 18
                                radius: 9
                                color: root.panelDark

                                Text {
                                    id: hintNav
                                    anchors.centerIn: parent
                                    text: "↑↓ NAVIGATE"
                                    color: root.muted
                                    font.family: root.monoFont
                                    font.pixelSize: 7
                                }
                            }
                        }

                        Row {
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                                verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: hintEnter.width + 14
                                height: 18
                                radius: 9
                                color: Qt.rgba(
                                    root.cyan.r,
                                    root.cyan.g,
                                    root.cyan.b,
                                    0.14
                                )

                                Text {
                                    id: hintEnter
                                    anchors.centerIn: parent
                                    text: "ENTER OPEN"
                                    color: root.cyan
                                    font.family: root.monoFont
                                    font.pixelSize: 7
                                    font.weight: Font.DemiBold
                                }
                            }
                        }

                        Row {
                            anchors {
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                            }

                            Rectangle {
                                width: hintEsc.width + 14
                                height: 18
                                radius: 9
                                color: Qt.rgba(
                                    root.red.r,
                                    root.red.g,
                                    root.red.b,
                                    0.14
                                )

                                Text {
                                    id: hintEsc
                                    anchors.centerIn: parent
                                    text: "ESC CLOSE"
                                    color: root.red
                                    font.family: root.monoFont
                                    font.pixelSize: 7
                                    font.weight: Font.DemiBold
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        root.visibleLauncher = false
        launcherWindow.visible = false
    }
}