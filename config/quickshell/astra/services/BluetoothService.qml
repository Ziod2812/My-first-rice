pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    readonly property var adapter:
        Bluetooth.defaultAdapter

    readonly property bool available:
        root.adapter !== null

    readonly property bool enabled:
        root.adapter
        ? root.adapter.enabled
        : false

    readonly property bool scanning:
        root.adapter
        ? root.adapter.discovering
        : false

    readonly property var devices:
        root.adapter
        ? root.adapter.devices.values
        : []

    readonly property var pairedDevices:
        root.devices.filter(function(device) {
            return device && device.paired
        })

    readonly property var connectedDevices:
        root.devices.filter(function(device) {
            return device && device.connected
        })

    readonly property var connectedDevice:
        root.connectedDevices.length > 0
            ? root.connectedDevices[0]
            : null

    readonly property int deviceCount:
        root.devices.length

    readonly property int pairedDeviceCount:
        root.pairedDevices.length

    readonly property int connectedDeviceCount:
        root.connectedDevices.length

    function toggleBluetooth() {
        if (!root.adapter)
            return

        root.adapter.enabled =
            !root.adapter.enabled
    }

    function setBluetoothEnabled(value) {
        if (!root.adapter)
            return

        root.adapter.enabled =
            Boolean(value)
    }

    function startScan() {
        if (
            !root.adapter ||
            !root.adapter.enabled
        ) {
            return
        }

        root.adapter.discovering = true
    }

    function stopScan() {
        if (!root.adapter)
            return

        root.adapter.discovering = false
    }

    function toggleScan() {
        if (!root.adapter)
            return

        if (!root.adapter.enabled)
            return

        root.adapter.discovering =
            !root.adapter.discovering
    }

    function connectDevice(device) {
        if (
            !device ||
            !root.enabled
        ) {
            return
        }

        if (device.connected)
            return

        device.connect()
    }

    function disconnectDevice(device) {
        if (!device)
            return

        if (!device.connected)
            return

        device.disconnect()
    }

    function pairDevice(device) {
        if (
            !device ||
            !root.enabled
        ) {
            return
        }

        if (device.paired)
            return

        if (device.pairing)
            return

        device.pair()
    }

    function cancelPairing(device) {
        if (!device)
            return

        if (!device.pairing)
            return

        device.cancelPair()
    }

    function forgetDevice(device) {
        if (!device)
            return

        if (device.connected)
            device.disconnect()

        device.forget()
    }

    function setTrusted(device, value) {
        if (!device)
            return

        device.trusted =
            Boolean(value)
    }

    function blockDevice(device, value) {
        if (!device)
            return

        device.blocked =
            Boolean(value)
    }

    function deviceName(device) {
        if (!device)
            return "Unknown device"

        if (device.name)
            return String(device.name)

        if (device.deviceName)
            return String(device.deviceName)

        if (device.address)
            return String(device.address)

        return "Unknown device"
    }

    function deviceAddress(device) {
        if (
            !device ||
            !device.address
        ) {
            return ""
        }

        return String(
            device.address
        )
    }

    function deviceIcon(device) {
        if (
            !device ||
            !device.icon
        ) {
            return ""
        }

        return String(
            device.icon
        )
    }

    function deviceBattery(device) {
        if (
            !device ||
            !device.batteryAvailable
        ) {
            return -1
        }

        return Math.max(
            0,
            Math.min(
                1,
                Number(device.battery)
            )
        )
    }

    function isConnected(device) {
        return Boolean(
            device &&
            device.connected
        )
    }

    function isPaired(device) {
        return Boolean(
            device &&
            device.paired
        )
    }

    function isPairing(device) {
        return Boolean(
            device &&
            device.pairing
        )
    }

    function debug() {
        console.log(
            "Astra BluetoothService:",
            "available=" + root.available,
            "enabled=" + root.enabled,
            "scanning=" + root.scanning,
            "devices=" + root.deviceCount,
            "paired=" + root.pairedDeviceCount,
            "connected=" + root.connectedDeviceCount
        )

        for (
            const device of root.devices
        ) {
            console.log(
                "Bluetooth device:",
                root.deviceName(device),
                root.deviceAddress(device),
                "paired=" + device.paired,
                "connected=" + device.connected,
                "pairing=" + device.pairing
            )
        }
    }

    Component.onCompleted: {
        root.debug()
    }
}