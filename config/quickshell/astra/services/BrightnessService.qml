pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property bool available:
        root.device.length > 0

    readonly property string device:
        root.deviceName

    readonly property string deviceClass:
        root.deviceClassName

    readonly property int brightness:
        root.currentBrightness

    readonly property int maximum:
        root.maximumBrightness

    readonly property real percentage:
        root.currentPercentage

    property string deviceName: ""
    property string deviceClassName: ""
    property int currentBrightness: 0
    property int maximumBrightness: 0
    property real currentPercentage: 0

    function parseOutput(value) {
        const lines =
            String(value)
            .trim()
            .split("\n")

        if (
            lines.length === 0 ||
            !lines[0]
        ) {
            root.deviceName = ""
            root.deviceClassName = ""
            root.currentBrightness = 0
            root.maximumBrightness = 0
            root.currentPercentage = 0
            return
        }

        const parts =
            lines[0].split(",")

        if (parts.length < 5)
            return

        root.deviceName =
            String(parts[0])

        root.deviceClassName =
            String(parts[1])

        root.currentBrightness =
            Number(parts[2])

        root.currentPercentage =
            Number(
                String(parts[3])
                .replace("%", "")
            )

        root.maximumBrightness =
            Number(parts[4])
    }

    function refresh() {
        if (readProcess.running)
            return

        readProcess.running = true
    }

    function setBrightness(value) {
        if (!root.available)
            return

        const target =
            Math.max(
                1,
                Math.min(
                    100,
                    Number(value)
                )
            )

        setProcess.exec([
            "brightnessctl",
            "-q",
            "-c",
            "backlight",
            "set",
            Math.round(target) + "%"
        ])
    }

    function increase(step) {
        if (!root.available)
            return

        const amount =
            Math.max(
                1,
                Number(step || 5)
            )

        setProcess.exec([
            "brightnessctl",
            "-q",
            "-c",
            "backlight",
            "set",
            "+" + amount + "%"
        ])
    }

    function decrease(step) {
        if (!root.available)
            return

        const amount =
            Math.max(
                1,
                Number(step || 5)
            )

        setProcess.exec([
            "brightnessctl",
            "-q",
            "-c",
            "backlight",
            "set",
            amount + "%-"
        ])
    }

    Process {
        id: readProcess

        command: [
            "brightnessctl",
            "-m",
            "-c",
            "backlight"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.parseOutput(this.text)
            }
        }
    }

    Process {
        id: setProcess

        onExited: {
            root.refresh()
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            root.refresh()
        }
    }

    Component.onCompleted: {
        root.refresh()
    }
}