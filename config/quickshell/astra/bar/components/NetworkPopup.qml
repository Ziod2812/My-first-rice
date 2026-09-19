import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs
import qs.services

PanelWindow {
    id: root

    property var anchorItem: null

    property string selectedSsid: ""
    property string selectedBssid: ""
    property string selectedSecurity: ""

    property bool passwordMode: false
    property bool cursorInside: false
    property bool networkMenuVisible: false

    property var selectedNetwork: null

    visible: false
    focusable: true

    WlrLayershell.keyboardFocus:
        root.passwordMode
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.OnDemand

    color: "transparent"

    anchors {
        top: true
        right: true
        bottom: true
        left: true
    }

    WlrLayershell.exclusiveZone: -1

    Theme {
        id: theme
    }

    function closePopup() {
        autoCloseTimer.stop()

        root.passwordMode = false
        root.networkMenuVisible = false

        passwordField.clear()

        root.visible = false
    }

    MouseArea {
        id: outsideMouseArea

        anchors.fill: parent

        onClicked: {
            root.closePopup()
        }
    }

    Timer {
        id: autoCloseTimer

        interval: 5000
        repeat: false

        onTriggered: {
            if (
                !root.passwordMode &&
                !root.cursorInside &&
                !root.networkMenuVisible
            ) {
                root.visible = false
            }
        }
    }

    function restartAutoCloseTimer() {
        if (
            root.passwordMode ||
            root.cursorInside ||
            root.networkMenuVisible
        ) {
            autoCloseTimer.stop()
            return
        }

        autoCloseTimer.restart()
    }

    function openNetworkMenu(network) {
        root.selectedNetwork = network
        root.selectedSsid = network.ssid
        root.selectedBssid = network.bssid
        root.selectedSecurity = network.security

        root.networkMenuVisible = true

        autoCloseTimer.stop()
    }

    function closeNetworkMenu() {
        root.networkMenuVisible = false
        root.restartAutoCloseTimer()
    }

    function openPasswordMode() {
        if (!root.selectedNetwork)
            return

        root.passwordMode = true
        root.networkMenuVisible = false

        autoCloseTimer.stop()

        passwordField.clear()

        Qt.callLater(() => {
            passwordField.forceActiveFocus()
        })
    }

    function closePasswordMode() {
        root.passwordMode = false

        passwordField.clear()

        root.restartAutoCloseTimer()
    }

    function connectSelectedNetwork() {
        if (!root.selectedNetwork)
            return

        const network = root.selectedNetwork

        root.networkMenuVisible = false

        if (network.active) {
            root.restartAutoCloseTimer()
            return
        }

        if (
            network.security.length > 0 &&
            !NetworkService.hasSavedProfile(network.ssid)
        ) {
            root.openPasswordMode()
            return
        }

        NetworkService.connectToNetwork(
            network.ssid,
            "",
            network.bssid,
            function(success) {
                if (success) {
                    root.restartAutoCloseTimer()
                }
            }
        )
    }

    function forgetPassword() {
        if (!root.selectedNetwork)
            return

        const ssid = root.selectedNetwork.ssid

        root.networkMenuVisible = false

        NetworkService.forgetPassword(
            ssid,
            function(success) {
                root.restartAutoCloseTimer()
            }
        )
    }

    function forgetAndDisconnect() {
        if (!root.selectedNetwork)
            return

        const ssid = root.selectedNetwork.ssid

        root.networkMenuVisible = false

        NetworkService.forgetAndDisconnect(
            ssid,
            function(success) {
                root.restartAutoCloseTimer()
            }
        )
    }

    function connectPassword() {
        if (!root.selectedSsid)
            return

        if (!passwordField.text)
            return

        NetworkService.connectToNetwork(
            root.selectedSsid,
            passwordField.text,
            root.selectedBssid,
            function(success) {
                if (success) {
                    root.closePasswordMode()
                }
            }
        )
    }

    onVisibleChanged: {
        if (!visible) {
            autoCloseTimer.stop()
            return
        }

        root.restartAutoCloseTimer()
    }

    Rectangle {
        id: background

        width: 340
        height: 500

        anchors.top: parent.top
        anchors.right: parent.right

        anchors.topMargin: 48
        anchors.rightMargin: 12

        radius: 18

        color: Qt.rgba(
            theme.surface.r,
            theme.surface.g,
            theme.surface.b,
            0.88
        )

        border.width: 1

        border.color:
            Qt.rgba(
                theme.outline.r,
                theme.outline.g,
                theme.outline.b,
                0.30
            )

        MouseArea {
            id: insideMouseArea

            anchors.fill: parent

            onClicked: {}
        }

        HoverHandler {
            id: popupHover

            onHoveredChanged: {
                root.cursorInside = hovered

                if (
                    hovered ||
                    root.passwordMode
                ) {
                    autoCloseTimer.stop()
                } else {
                    root.restartAutoCloseTimer()
                }
            }
        }

        Column {
            anchors.fill: parent

            anchors.margins: 14

            spacing: 10

            Row {
                id: header

                width: parent.width
                height: 34

                spacing: 8

                Column {
                    width: parent.width - 44
                    height: parent.height

                    spacing: 1

                    Text {
                        text: "Network"

                        color: "#FFFFFF"

                        font.family:
                            "JetBrainsMono Nerd Font"

                        font.pixelSize: 14

                        font.weight:
                            Font.DemiBold
                    }

                    Text {
                        text:
                            NetworkService.isConnected
                            ? "Connected"
                            : "Disconnected"

                        color:
                            NetworkService.isConnected
                            ? theme.success
                            : theme.error

                        font.family:
                            "JetBrainsMono Nerd Font"

                        font.pixelSize: 8
                    }
                }

                Rectangle {
                    width: 34
                    height: 34

                    radius: 10

                    color:
                        wifiMouse.containsMouse
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
                            0.55
                        )

                    Text {
                        anchors.centerIn: parent

                        text:
                            NetworkService.wifiEnabled
                            ? "󰤨"
                            : "󰖪"

                        color:
                            NetworkService.wifiEnabled
                            ? "#FFFFFF"
                            : theme.error

                        font.family:
                            "Symbols Nerd Font"

                        font.pixelSize: 16
                    }

                    MouseArea {
                        id: wifiMouse

                        anchors.fill: parent

                        hoverEnabled: true

                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked: {
                            NetworkService.toggleWifi()
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 58

                radius: 12

                color:
                    Qt.rgba(
                        theme.surfaceContainer.r,
                        theme.surfaceContainer.g,
                        theme.surfaceContainer.b,
                        0.70
                    )

                Row {
                    anchors.fill: parent

                    anchors.leftMargin: 12
                    anchors.rightMargin: 12

                    spacing: 10

                    Text {
                        anchors.verticalCenter:
                            parent.verticalCenter

                        text:
                            NetworkService.isConnected
                            ? "󰤨"
                            : "󰖪"

                        color:
                            NetworkService.isConnected
                            ? theme.success
                            : theme.error

                        font.family:
                            "Symbols Nerd Font"

                        font.pixelSize: 20
                    }

                    Column {
                        anchors.verticalCenter:
                            parent.verticalCenter

                        width:
                            parent.width - 42

                        spacing: 3

                        Text {
                            width: parent.width

                            text: {
                                const active =
                                    NetworkService.active

                                if (!active)
                                    return "Not connected"

                                return active.ssid
                            }

                            color: "#FFFFFF"

                            font.family:
                                "JetBrainsMono Nerd Font"

                            font.pixelSize: 11

                            font.weight:
                                Font.Medium

                            elide:
                                Text.ElideRight
                        }

                        Text {
                            text:
                                NetworkService.isConnected
                                ? "Internet connection active"
                                : "No active connection"

                            color: "#FFFFFF"

                            font.family:
                                "JetBrainsMono Nerd Font"

                            font.pixelSize: 8
                        }
                    }
                }
            }

            Rectangle {
                visible:
                    passwordMode

                width: parent.width
                height: 126

                radius: 12

                color:
                    Qt.rgba(
                        theme.surfaceContainer.r,
                        theme.surfaceContainer.g,
                        theme.surfaceContainer.b,
                        0.65
                    )

                Column {
                    anchors.fill: parent

                    anchors.margins: 11

                    spacing: 8

                    Text {
                        width: parent.width

                        text:
                            "Connect to " +
                            root.selectedSsid

                        color: "#FFFFFF"

                        font.family:
                            "JetBrainsMono Nerd Font"

                        font.pixelSize: 10

                        font.weight:
                            Font.Medium

                        elide:
                            Text.ElideRight
                    }

                    TextField {
                        id: passwordField

                        width: parent.width
                        height: 36

                        placeholderText:
                            "Wi-Fi password"

                        echoMode:
                            TextInput.Password

                        focus:
                            root.passwordMode

                        activeFocusOnPress: true

                        selectByMouse: true

                        leftPadding: 12
                        rightPadding: 12

                        color: "#FFFFFF"

                        placeholderTextColor:
                            theme.textSecondary

                        font.family:
                            "JetBrainsMono Nerd Font"

                        font.pixelSize: 10

                        onAccepted: {
                            root.connectPassword()
                        }

                        background:
                            Rectangle {
                                radius: 8

                                color:
                                    Qt.rgba(
                                        theme.surfaceContainerLow.r,
                                        theme.surfaceContainerLow.g,
                                        theme.surfaceContainerLow.b,
                                        0.85
                                    )

                                border.width: 1

                                border.color:
                                    passwordField.activeFocus
                                    ? Qt.rgba(
                                        theme.primary.r,
                                        theme.primary.g,
                                        theme.primary.b,
                                        0.65
                                    )
                                    : Qt.rgba(
                                        theme.outline.r,
                                        theme.outline.g,
                                        theme.outline.b,
                                        0.25
                                    )
                            }
                    }

                    Row {
                        width: parent.width
                        height: 32

                        spacing: 7

                        Rectangle {
                            width:
                                (parent.width - 7) / 2

                            height: 32

                            radius: 8

                            color:
                                cancelMouse.containsMouse
                                ? Qt.rgba(
                                    theme.surfaceContainerHigh.r,
                                    theme.surfaceContainerHigh.g,
                                    theme.surfaceContainerHigh.b,
                                    0.85
                                )
                                : Qt.rgba(
                                    theme.surfaceContainer.r,
                                    theme.surfaceContainer.g,
                                    theme.surfaceContainer.b,
                                    0.60
                                )

                            Text {
                                anchors.centerIn: parent

                                text: "Cancel"

                                color: "#FFFFFF"

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                font.pixelSize: 9
                            }

                            MouseArea {
                                id: cancelMouse

                                anchors.fill: parent

                                hoverEnabled: true

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked: {
                                    root.closePasswordMode()
                                }
                            }
                        }

                        Rectangle {
                            width:
                                (parent.width - 7) / 2

                            height: 32

                            radius: 8

                            color:
                                connectMouse.containsMouse
                                ? Qt.rgba(
                                    theme.primary.r,
                                    theme.primary.g,
                                    theme.primary.b,
                                    0.36
                                )
                                : Qt.rgba(
                                    theme.primary.r,
                                    theme.primary.g,
                                    theme.primary.b,
                                    0.20
                                )

                            Text {
                                anchors.centerIn: parent

                                text: "Connect"

                                color: "#FFFFFF"

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                font.pixelSize: 9

                                font.weight:
                                    Font.Medium
                            }

                            MouseArea {
                                id: connectMouse

                                anchors.fill: parent

                                hoverEnabled: true

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked: {
                                    root.connectPassword()
                                }
                            }
                        }
                    }
                }
            }

            Row {
                visible:
                    !passwordMode &&
                    !networkMenuVisible

                width: parent.width
                height: 24

                Text {
                    id: availableNetworksText

                    anchors.verticalCenter:
                        parent.verticalCenter

                    text:
                        NetworkService.scanning
                        ? "Scanning networks..."
                        : "Available networks"

                    color: "#FFFFFF"

                    font.family:
                        "JetBrainsMono Nerd Font"

                    font.pixelSize: 9
                }

                Item {
                    width:
                        Math.max(
                            0,
                            parent.width -
                            availableNetworksText.implicitWidth -
                            networkCountText.implicitWidth -
                            8
                        )

                    height: 1
                }

                Text {
                    id: networkCountText

                    anchors.verticalCenter:
                        parent.verticalCenter

                    text:
                        NetworkService.networks.length +
                        " networks"

                    color: "#FFFFFF"

                    font.family:
                        "JetBrainsMono Nerd Font"

                    font.pixelSize: 8
                }
            }

            Flickable {
                id: networkFlickable

                visible:
                    !passwordMode &&
                    !networkMenuVisible

                width: parent.width

                height:
                    Math.max(
                        80,
                        parent.height -
                        header.height -
                        58 -
                        24 -
                        44 -
                        40
                    )

                contentWidth: width

                contentHeight:
                    networkColumn.height

                clip: true

                boundsBehavior:
                    Flickable.StopAtBounds

                ScrollBar.vertical:
                    ScrollBar {
                        policy:
                            ScrollBar.AsNeeded
                    }

                Column {
                    id: networkColumn

                    width:
                        networkFlickable.width

                    spacing: 5

                    Repeater {
                        model:
                            NetworkService.networks

                        delegate: Rectangle {
                            required property var modelData

                            width:
                                networkColumn.width

                            height: 44

                            radius: 10

                            color:
                                networkMouse.containsMouse
                                ? Qt.rgba(
                                    theme.primary.r,
                                    theme.primary.g,
                                    theme.primary.b,
                                    0.13
                                )
                                : Qt.rgba(
                                    theme.surfaceContainer.r,
                                    theme.surfaceContainer.g,
                                    theme.surfaceContainer.b,
                                    0.42
                                )

                            border.width:
                                modelData.active ? 1 : 0

                            border.color:
                                Qt.rgba(
                                    theme.success.r,
                                    theme.success.g,
                                    theme.success.b,
                                    0.28
                                )

                            Row {
                                anchors.fill: parent

                                anchors.leftMargin: 11
                                anchors.rightMargin: 10

                                spacing: 10

                                Text {
                                    anchors.verticalCenter:
                                        parent.verticalCenter

                                    width: 20

                                    horizontalAlignment:
                                        Text.AlignHCenter

                                    text: {
                                        if (
                                            modelData.strength >= 80
                                        )
                                            return "󰤨"

                                        if (
                                            modelData.strength >= 60
                                        )
                                            return "󰤥"

                                        if (
                                            modelData.strength >= 40
                                        )
                                            return "󰤢"

                                        if (
                                            modelData.strength >= 20
                                        )
                                            return "󰤟"

                                        return "󰤯"
                                    }

                                    color:
                                        modelData.active
                                        ? theme.success
                                        : "#FFFFFF"

                                    font.family:
                                        "Symbols Nerd Font"

                                    font.pixelSize: 16
                                }

                                Column {
                                    anchors.verticalCenter:
                                        parent.verticalCenter

                                    width:
                                        parent.width - 72

                                    spacing: 2

                                    Text {
                                        width: parent.width

                                        text:
                                            modelData.ssid

                                        color:
                                            modelData.active
                                            ? theme.success
                                            : "#FFFFFF"

                                        font.family:
                                            "JetBrainsMono Nerd Font"

                                        font.pixelSize: 10

                                        font.weight:
                                            modelData.active
                                            ? Font.Medium
                                            : Font.Normal

                                        elide:
                                            Text.ElideRight
                                    }

                                    Text {
                                        text:
                                            modelData.active
                                            ? "Connected"
                                            : (
                                                modelData.security
                                                    .length > 0
                                                ? (
                                                    NetworkService
                                                    .hasSavedProfile(
                                                        modelData.ssid
                                                    )
                                                    ? "Saved"
                                                    : "Secured"
                                                )
                                                : "Open"
                                            )

                                        color:
                                            modelData.active
                                            ? theme.success
                                            : "#FFFFFF"

                                        font.family:
                                            "JetBrainsMono Nerd Font"

                                        font.pixelSize: 8
                                    }
                                }

                                Text {
                                    anchors.verticalCenter:
                                        parent.verticalCenter

                                    width: 34

                                    horizontalAlignment:
                                        Text.AlignRight

                                    text:
                                        modelData.strength +
                                        "%"

                                    color:
                                        modelData.active
                                        ? theme.success
                                        : "#FFFFFF"

                                    font.family:
                                        "JetBrainsMono Nerd Font"

                                    font.pixelSize: 8
                                }
                            }

                            MouseArea {
                                id: networkMouse

                                anchors.fill: parent

                                hoverEnabled: true

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked: {
                                    root.openNetworkMenu(
                                        modelData
                                    )
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                visible:
                    !passwordMode &&
                    networkMenuVisible

                width: parent.width
                height: 278

                radius: 12

                color:
                    Qt.rgba(
                        theme.surfaceContainer.r,
                        theme.surfaceContainer.g,
                        theme.surfaceContainer.b,
                        0.78
                    )

                border.width: 1

                border.color:
                    Qt.rgba(
                        theme.outline.r,
                        theme.outline.g,
                        theme.outline.b,
                        0.18
                    )

                Column {
                    anchors.fill: parent

                    anchors.margins: 12

                    spacing: 8

                    Row {
                        width: parent.width
                        height: 34

                        spacing: 9

                        Text {
                            anchors.verticalCenter:
                                parent.verticalCenter

                            text: "󰤨"

                            color:
                                root.selectedNetwork &&
                                root.selectedNetwork.active
                                ? theme.success
                                : "#FFFFFF"

                            font.family:
                                "Symbols Nerd Font"

                            font.pixelSize: 18
                        }

                        Column {
                            anchors.verticalCenter:
                                parent.verticalCenter

                            width:
                                parent.width - 30

                            spacing: 2

                            Text {
                                width: parent.width

                                text:
                                    root.selectedSsid

                                color: "#FFFFFF"

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                font.pixelSize: 10

                                font.weight:
                                    Font.Medium

                                elide:
                                    Text.ElideRight
                            }

                            Text {
                                text:
                                    root.selectedNetwork &&
                                    root.selectedNetwork.active
                                    ? "Connected"
                                    : (
                                        root.selectedNetwork &&
                                        root.selectedNetwork.security
                                            .length > 0
                                        ? (
                                            NetworkService
                                            .hasSavedProfile(
                                                root.selectedSsid
                                            )
                                            ? "Saved network"
                                            : "Password required"
                                        )
                                        : "Open network"
                                    )

                                color:
                                    root.selectedNetwork &&
                                    root.selectedNetwork.active
                                    ? theme.success
                                    : "#FFFFFF"

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                font.pixelSize: 8
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1

                        color:
                            Qt.rgba(
                                theme.outline.r,
                                theme.outline.g,
                                theme.outline.b,
                                0.15
                            )
                    }

                    Rectangle {
                        width: parent.width
                        height: 38

                        radius: 8

                        color:
                            connectActionMouse.containsMouse
                            ? Qt.rgba(
                                theme.primary.r,
                                theme.primary.g,
                                theme.primary.b,
                                0.20
                            )
                            : Qt.rgba(
                                theme.surface.r,
                                theme.surface.g,
                                theme.surface.b,
                                0.35
                            )

                        Row {
                            anchors.fill: parent

                            anchors.leftMargin: 11

                            spacing: 9

                            Text {
                                anchors.verticalCenter:
                                    parent.verticalCenter

                                text: "󰤨"

                                color: theme.primary

                                font.family:
                                    "Symbols Nerd Font"

                                font.pixelSize: 14
                            }

                            Text {
                                anchors.verticalCenter:
                                    parent.verticalCenter

                                text:
                                    root.selectedNetwork &&
                                    root.selectedNetwork.active
                                    ? "Connected"
                                    : "Connect"

                                color: "#FFFFFF"

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                font.pixelSize: 9
                            }
                        }

                        MouseArea {
                            id: connectActionMouse

                            anchors.fill: parent

                            hoverEnabled: true

                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked: {
                                root.connectSelectedNetwork()
                            }
                        }
                    }

                    Rectangle {
                        visible:
                            root.selectedNetwork &&
                            NetworkService.hasSavedProfile(
                                root.selectedSsid
                            )

                        width: parent.width
                        height: 38

                        radius: 8

                        color:
                            forgetPasswordMouse.containsMouse
                            ? Qt.rgba(
                                theme.warning.r,
                                theme.warning.g,
                                theme.warning.b,
                                0.18
                            )
                            : Qt.rgba(
                                theme.surface.r,
                                theme.surface.g,
                                theme.surface.b,
                                0.35
                            )

                        Row {
                            anchors.fill: parent

                            anchors.leftMargin: 11

                            spacing: 9

                            Text {
                                anchors.verticalCenter:
                                    parent.verticalCenter

                                text: "󰌆"

                                color: theme.warning

                                font.family:
                                    "Symbols Nerd Font"

                                font.pixelSize: 14
                            }

                            Text {
                                anchors.verticalCenter:
                                    parent.verticalCenter

                                text: "Forget password"

                                color: "#FFFFFF"

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                font.pixelSize: 9
                            }
                        }

                        MouseArea {
                            id: forgetPasswordMouse

                            anchors.fill: parent

                            hoverEnabled: true

                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked: {
                                root.forgetPassword()
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 38

                        radius: 8

                        color:
                            forgetDisconnectMouse.containsMouse
                            ? Qt.rgba(
                                theme.error.r,
                                theme.error.g,
                                theme.error.b,
                                0.20
                            )
                            : Qt.rgba(
                                theme.surface.r,
                                theme.surface.g,
                                theme.surface.b,
                                0.35
                            )

                        Row {
                            anchors.fill: parent

                            anchors.leftMargin: 11

                            spacing: 9

                            Text {
                                anchors.verticalCenter:
                                    parent.verticalCenter

                                text: "󰆴"

                                color: theme.error

                                font.family:
                                    "Symbols Nerd Font"

                                font.pixelSize: 14
                            }

                            Text {
                                anchors.verticalCenter:
                                    parent.verticalCenter

                                text:
                                    "Forget & Disconnect"

                                color: "#FFFFFF"

                                font.family:
                                    "JetBrainsMono Nerd Font"

                                font.pixelSize: 9
                            }
                        }

                        MouseArea {
                            id: forgetDisconnectMouse

                            anchors.fill: parent

                            hoverEnabled: true

                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked: {
                                root.forgetAndDisconnect()
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 34

                        radius: 8

                        color:
                            backMouse.containsMouse
                            ? Qt.rgba(
                                theme.surfaceContainerHigh.r,
                                theme.surfaceContainerHigh.g,
                                theme.surfaceContainerHigh.b,
                                0.75
                            )
                            : Qt.rgba(
                                theme.surface.r,
                                theme.surface.g,
                                theme.surface.b,
                                0.35
                            )

                        Text {
                            anchors.centerIn: parent

                            text: "Back"

                            color: "#FFFFFF"

                            font.family:
                                "JetBrainsMono Nerd Font"

                            font.pixelSize: 8
                        }

                        MouseArea {
                            id: backMouse

                            anchors.fill: parent

                            hoverEnabled: true

                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked: {
                                root.closeNetworkMenu()
                            }
                        }
                    }
                }
            }

            Row {
                visible:
                    !passwordMode &&
                    !networkMenuVisible

                width: parent.width
                height: 34

                Rectangle {
                    width: parent.width
                    height: 34

                    radius: 9

                    color:
                        refreshMouse.containsMouse
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
                            0.65
                        )

                    Text {
                        anchors.centerIn: parent

                        text:
                            NetworkService.scanning
                            ? "Scanning..."
                            : "Rescan"

                        color:
                            NetworkService.scanning
                            ? theme.primary
                            : "#FFFFFF"

                        font.family:
                            "JetBrainsMono Nerd Font"

                        font.pixelSize: 9
                    }

                    MouseArea {
                        id: refreshMouse

                        anchors.fill: parent

                        hoverEnabled: true

                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked: {
                            NetworkService.rescanWifi()
                            root.restartAutoCloseTimer()
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: NetworkService

        function onPasswordRequired(
            ssid,
            bssid
        ) {
            root.selectedSsid = ssid
            root.selectedBssid = bssid
            root.openPasswordMode()
        }
    }

    Connections {
        target: NetworkService

        function onConnectionFailed(ssid) {
            if (root.passwordMode) {
                root.restartAutoCloseTimer()
            }
        }
    }
}