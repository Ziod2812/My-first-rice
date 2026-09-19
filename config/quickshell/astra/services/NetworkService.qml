pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool wifiEnabled: true
    property bool scanning: false
    property bool isConnected: false
    property bool connecting: false

    property string activeInterface: ""
    property string activeConnection: ""

    property var networks: []
    property var savedConnections: []
    property var wirelessInterfaces: []
    property var ethernetInterfaces: []

    readonly property var active: networks.find(n => n.active) ?? null

    signal connectionFailed(string ssid)
    signal passwordRequired(string ssid, string bssid)

    property var processes: []

    function execute(args, callback) {
        const proc = commandProc.createObject(root)

        proc.args = args
        proc.callback = callback

        root.processes.push(proc)

        proc.finished.connect(() => {
            const index = root.processes.indexOf(proc)

            if (index >= 0)
                root.processes.splice(index, 1)

            proc.destroy()
        })

        Qt.callLater(() => proc.run())
    }

    function parseDeviceStatus(output) {
        if (!output)
            return []

        return output
            .trim()
            .split("\n")
            .filter(line => line.length > 0)
            .map(line => {
                const parts = line.split(":")

                return {
                    device: parts[0] || "",
                    type: parts[1] || "",
                    state: parts[2] || "",
                    connection: parts.slice(3).join(":") || ""
                }
            })
    }

    function refreshInterfaces() {
        execute(
            [
                "-t",
                "-f",
                "DEVICE,TYPE,STATE,CONNECTION",
                "device",
                "status"
            ],
            result => {
                const devices =
                    parseDeviceStatus(
                        result.output
                    )

                root.wirelessInterfaces =
                    devices.filter(
                        device =>
                            device.type === "wifi"
                    )

                root.ethernetInterfaces =
                    devices.filter(
                        device =>
                            device.type === "ethernet"
                    )

                const activeWifi =
                    root.wirelessInterfaces.find(
                        device =>
                            device.state.startsWith(
                                "connected"
                            )
                    )

                const activeEthernet =
                    root.ethernetInterfaces.find(
                        device =>
                            device.state.startsWith(
                                "connected"
                            )
                    )

                if (activeWifi) {
                    root.isConnected = true
                    root.activeInterface =
                        activeWifi.device
                    root.activeConnection =
                        activeWifi.connection
                } else if (activeEthernet) {
                    root.isConnected = true
                    root.activeInterface =
                        activeEthernet.device
                    root.activeConnection =
                        activeEthernet.connection
                } else {
                    root.isConnected = false
                    root.activeInterface = ""
                    root.activeConnection = ""
                }
            }
        )
    }

    function parseNetworks(output) {
        if (!output)
            return []

        const placeholder =
            "ASTRA_ESCAPED_COLON"

        const escapedColon =
            new RegExp("\\\\:", "g")

        const placeholderRegex =
            new RegExp(
                placeholder,
                "g"
            )

        const result =
            output
            .trim()
            .split("\n")
            .filter(
                line =>
                    line.length > 0
            )
            .map(line => {
                const network =
                    line
                    .replace(
                        escapedColon,
                        placeholder
                    )
                    .split(":")

                const security =
                    (
                        network[5] ||
                        ""
                    ).trim()

                return {
                    active:
                        network[0] ===
                        "yes",

                    strength:
                        parseInt(
                            network[1] ||
                            "0",
                            10
                        ) || 0,

                    frequency:
                        parseInt(
                            network[2] ||
                            "0",
                            10
                        ) || 0,

                    ssid:
                        (
                            network[3] ||
                            ""
                        )
                        .replace(
                            placeholderRegex,
                            ":"
                        )
                        .trim(),

                    bssid:
                        (
                            network[4] ||
                            ""
                        )
                        .replace(
                            placeholderRegex,
                            ":"
                        )
                        .trim(),

                    security:
                        security,

                    isSecure:
                        security.length >
                        0
                }
            })
            .filter(
                network =>
                    network.ssid.length >
                    0
            )

        const map = new Map()

        for (const network of result) {
            const existing =
                map.get(
                    network.ssid
                )

            if (!existing) {
                map.set(
                    network.ssid,
                    network
                )
                continue
            }

            if (
                network.active &&
                !existing.active
            ) {
                map.set(
                    network.ssid,
                    network
                )
                continue
            }

            if (
                !network.active &&
                !existing.active &&
                network.strength >
                    existing.strength
            ) {
                map.set(
                    network.ssid,
                    network
                )
            }
        }

        return Array.from(
            map.values()
        ).sort((a, b) => {
            if (
                a.active !==
                b.active
            ) {
                return a.active
                    ? -1
                    : 1
            }

            return (
                b.strength -
                a.strength
            )
        })
    }

    function refreshNetworks() {
        if (!root.wifiEnabled)
            return

        if (root.scanning)
            return

        root.scanning = true

        execute(
            [
                "-t",
                "-f",
                "ACTIVE,SIGNAL,FREQ,SSID,BSSID,SECURITY",
                "device",
                "wifi",
                "list",
                "--rescan",
                "yes"
            ],
            result => {
                root.networks =
                    parseNetworks(
                        result.output
                    )

                root.scanning = false

                root.refreshInterfaces()
            }
        )
    }

    function refreshWifiState() {
        execute(
            [
                "-t",
                "radio",
                "wifi"
            ],
            result => {
                root.wifiEnabled =
                    result.output
                    .trim() ===
                    "enabled"

                if (
                    !root.wifiEnabled
                ) {
                    root.isConnected =
                        false
                    root.activeInterface =
                        ""
                    root.activeConnection =
                        ""
                }
            }
        )
    }

    function enableWifi(enabled) {
        execute(
            [
                "radio",
                "wifi",
                enabled
                    ? "on"
                    : "off"
            ],
            result => {
                if (
                    result.exitCode !==
                    0
                )
                    return

                root.wifiEnabled =
                    enabled

                if (enabled) {
                    root.rescanWifi()
                } else {
                    root.networks = []
                    root.scanning = false
                    root.isConnected =
                        false
                    root.activeInterface =
                        ""
                    root.activeConnection =
                        ""
                }

                root.refreshInterfaces()
            }
        )
    }

    function toggleWifi() {
        root.enableWifi(
            !root.wifiEnabled
        )
    }

    function rescanWifi() {
        if (!root.wifiEnabled)
            return

        root.refreshNetworks()
        networkScanTimer.restart()
    }

    function hasSavedProfile(ssid) {
        return root.savedConnections.some(
            connection =>
                connection.ssid ===
                ssid
        )
    }

    function refreshSavedConnections() {
        execute(
            [
                "-t",
                "-f",
                "NAME,TYPE",
                "connection",
                "show"
            ],
            result => {
                root.savedConnections =
                    result.output
                    .trim()
                    .split("\n")
                    .filter(
                        line =>
                            line.length >
                            0
                    )
                    .map(line => {
                        const parts =
                            line.split(":")

                        return {
                            name:
                                parts[0] ||
                                "",

                            type:
                                parts[1] ||
                                "",

                            ssid:
                                parts[0] ||
                                ""
                        }
                    })
                    .filter(
                        connection =>
                            connection.type ===
                            "802-11-wireless"
                    )
            }
        )
    }

    function connectToNetwork(
        ssid,
        password,
        bssid,
        callback
    ) {
        if (!ssid)
            return

        if (
            password === undefined
        )
            password = ""

        if (
            bssid === undefined
        )
            bssid = ""

        if (
            callback === undefined
        )
            callback = null

        root.connecting = true

        const args = [
            "device",
            "wifi",
            "connect",
            ssid
        ]

        if (
            password.length > 0
        ) {
            args.push(
                "password"
            )
            args.push(
                password
            )
        }

        if (
            bssid.length > 0
        ) {
            args.push(
                "bssid"
            )
            args.push(
                bssid
            )
        }

        execute(
            args,
            result => {
                root.connecting =
                    false

                if (
                    result.exitCode ===
                    0
                ) {
                    root.refreshSavedConnections()
                    root.refreshNetworks()
                    root.refreshInterfaces()

                    if (callback)
                        callback(
                            true,
                            result
                        )

                    return
                }

                const error =
                    (
                        result.error ||
                        ""
                    ) +
                    " " +
                    (
                        result.output ||
                        ""
                    )

                if (
                    error.includes(
                        "Secrets were required"
                    ) ||
                    error.includes(
                        "No secrets provided"
                    ) ||
                    error
                        .toLowerCase()
                        .includes(
                            "password"
                        ) ||
                    error.includes(
                        "802-11-wireless-security"
                    )
                ) {
                    root.passwordRequired(
                        ssid,
                        bssid
                    )
                } else {
                    root.connectionFailed(
                        ssid
                    )
                }

                if (callback)
                    callback(
                        false,
                        result
                    )
            }
        )
    }

    function connectToNetworkWithPasswordCheck(
        ssid,
        secure,
        callback,
        bssid
    ) {
        if (!ssid)
            return

        if (
            bssid === undefined
        )
            bssid = ""

        if (!secure) {
            root.connectToNetwork(
                ssid,
                "",
                bssid,
                callback
            )

            return
        }

        if (
            root.hasSavedProfile(
                ssid
            )
        ) {
            root.connectToNetwork(
                ssid,
                "",
                bssid,
                callback
            )

            return
        }

        root.passwordRequired(
            ssid,
            bssid
        )

        if (callback) {
            callback({
                needsPassword: true
            })
        }
    }

    function disconnectFromNetwork(
        callback
    ) {
        if (
            callback === undefined
        )
            callback = null

        if (
            !root.activeInterface
        ) {
            root.isConnected =
                false
            root.activeConnection =
                ""

            if (callback)
                callback(null)

            return
        }

        const interfaceName =
            root.activeInterface

        root.isConnected = false
        root.activeInterface = ""
        root.activeConnection = ""

        root.networks =
            root.networks.map(
                network => {
                    const updated = {
                        active:
                            false,
                        strength:
                            network.strength,
                        frequency:
                            network.frequency,
                        ssid:
                            network.ssid,
                        bssid:
                            network.bssid,
                        security:
                            network.security,
                        isSecure:
                            network.isSecure
                    }

                    return updated
                }
            )

        execute(
            [
                "device",
                "disconnect",
                interfaceName
            ],
            result => {
                root.refreshInterfaces()

                if (callback)
                    callback(result)
            }
        )
    }

    function disconnect(
        interfaceName,
        callback
    ) {
        if (!interfaceName)
            return

        if (
            callback === undefined
        )
            callback = null

        if (
            interfaceName ===
            root.activeInterface
        ) {
            root.isConnected =
                false
            root.activeInterface =
                ""
            root.activeConnection =
                ""

            root.networks =
                root.networks.map(
                    network => {
                        return {
                            active:
                                false,
                            strength:
                                network.strength,
                            frequency:
                                network.frequency,
                            ssid:
                                network.ssid,
                            bssid:
                                network.bssid,
                            security:
                                network.security,
                            isSecure:
                                network.isSecure
                        }
                    }
                )
        }

        execute(
            [
                "device",
                "disconnect",
                interfaceName
            ],
            result => {
                root.refreshInterfaces()

                if (callback)
                    callback(result)
            }
        )
    }

    function forgetPassword(
        ssid,
        callback
    ) {
        if (!ssid)
            return

        if (
            callback === undefined
        )
            callback = null

        execute(
            [
                "connection",
                "delete",
                ssid
            ],
            result => {
                root.refreshSavedConnections()
                root.refreshInterfaces()
                root.refreshNetworks()

                if (callback)
                    callback(
                        result.exitCode ===
                            0,
                        result
                    )
            }
        )
    }

    function forgetAndDisconnect(
        ssid,
        callback
    ) {
        if (!ssid) {
            if (callback)
                callback(false)

            return
        }

        if (
            callback === undefined
        )
            callback = null

        function deleteProfile() {
            execute(
                [
                    "connection",
                    "delete",
                    ssid
                ],
                result => {
                    root.refreshSavedConnections()
                    root.refreshInterfaces()
                    root.refreshNetworks()

                    if (callback)
                        callback(
                            result.exitCode ===
                                0,
                            result
                        )
                }
            )
        }

        if (
            root.isConnected &&
            root.activeConnection ===
                ssid &&
            root.activeInterface
        ) {
            const interfaceName =
                root.activeInterface

            root.isConnected =
                false

            root.activeInterface =
                ""

            root.activeConnection =
                ""

            root.networks =
                root.networks.map(
                    network => {
                        return {
                            active:
                                network.ssid ===
                                ssid
                                    ? false
                                    : network.active,
                            strength:
                                network.strength,
                            frequency:
                                network.frequency,
                            ssid:
                                network.ssid,
                            bssid:
                                network.bssid,
                            security:
                                network.security,
                            isSecure:
                                network.isSecure
                        }
                    }
                )

            execute(
                [
                    "device",
                    "disconnect",
                    interfaceName
                ],
                () => {
                    deleteProfile()
                }
            )

            return
        }

        deleteProfile()
    }

    function connectEthernet(
        connectionName,
        interfaceName,
        callback
    ) {
        if (!connectionName)
            return

        if (
            interfaceName ===
            undefined
        )
            interfaceName = ""

        if (
            callback ===
            undefined
        )
            callback = null

        const args = [
            "connection",
            "up",
            connectionName
        ]

        if (interfaceName) {
            args.push(
                "ifname"
            )
            args.push(
                interfaceName
            )
        }

        execute(
            args,
            result => {
                root.refreshInterfaces()

                if (callback)
                    callback(result)
            }
        )
    }

    function disconnectEthernet(
        connectionName,
        callback
    ) {
        if (!connectionName)
            return

        if (
            callback ===
            undefined
        )
            callback = null

        execute(
            [
                "connection",
                "down",
                connectionName
            ],
            result => {
                if (
                    result.exitCode ===
                        0 &&
                    root.activeConnection ===
                        connectionName
                ) {
                    root.isConnected =
                        false
                    root.activeInterface =
                        ""
                    root.activeConnection =
                        ""
                }

                root.refreshInterfaces()

                if (callback)
                    callback(result)
            }
        )
    }

    Component {
        id: commandProc

        Process {
            property list<string> args: []
            property var callback: null

            signal finished

            stdout:
                StdioCollector {}

            stderr:
                StdioCollector {}

            function run() {
                command = [
                    "nmcli"
                ]

                for (
                    let i = 0;
                    i < args.length;
                    ++i
                ) {
                    command.push(
                        args[i]
                    )
                }

                running = true
            }

            onExited: exitCode => {
                const result = {
                    output:
                        stdout.text ||
                        "",
                    error:
                        stderr.text ||
                        "",
                    exitCode:
                        exitCode
                }

                if (callback)
                    callback(result)

                finished()
            }
        }
    }

    Component.onCompleted: {
        root.refreshWifiState()
        root.refreshInterfaces()
        root.refreshSavedConnections()
        root.refreshNetworks()
    }

    Timer {
        id: interfaceTimer

        interval: 5000

        running: true

        repeat: true

        onTriggered: {
            root.refreshInterfaces()
        }
    }

    Timer {
        id: networkScanTimer

        interval: 300000

        running: true

        repeat: true

        onTriggered: {
            root.refreshNetworks()
        }
    }
}