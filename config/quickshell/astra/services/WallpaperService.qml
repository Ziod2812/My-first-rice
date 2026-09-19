pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string currentWallpaper: ""
    property string pendingWallpaper: ""

    property string transitionType: "fade"
    property real transitionDuration: 0.65
    property int transitionFps: 60

    property bool awwwAvailable: false
    property bool wallustAvailable: false
    property bool daemonReady: false
    property bool applying: false

    readonly property bool available:
        root.awwwAvailable

    readonly property string homeDirectory:
        String(Quickshell.env("HOME") || "")

    readonly property string stateDirectory:
        root.homeDirectory.length > 0
        ? root.homeDirectory + "/.local/state/quickshell/astra"
        : ""

    readonly property string stateFile:
        root.stateDirectory.length > 0
        ? root.stateDirectory + "/wallpaper"
        : ""

    readonly property string settingsFile:
        root.stateDirectory.length > 0
        ? root.stateDirectory + "/wallpaper-settings"
        : ""

    readonly property string wallpaperDirectory:
        root.homeDirectory.length > 0
        ? root.homeDirectory + "/Pictures/Wallpapers"
        : ""

    readonly property var transitions: [
        {
            id: "fade",
            name: "Fade"
        },
        {
            id: "left",
            name: "Left"
        },
        {
            id: "right",
            name: "Right"
        },
        {
            id: "top",
            name: "Top"
        },
        {
            id: "bottom",
            name: "Bottom"
        },
        {
            id: "wipe",
            name: "Wipe"
        },
        {
            id: "wave",
            name: "Wave"
        },
        {
            id: "grow",
            name: "Grow"
        },
        {
            id: "center",
            name: "Center"
        },
        {
            id: "outer",
            name: "Outer"
        },
        {
            id: "simple",
            name: "Simple"
        },
        {
            id: "none",
            name: "None"
        }
    ]

    function setTransition(value) {
        var transition = String(value || "").trim()

        for (var i = 0; i < root.transitions.length; i++) {
            if (root.transitions[i].id === transition) {
                root.transitionType = transition
                root.saveSettings()
                return
            }
        }

        root.transitionType = "fade"
        root.saveSettings()
    }

    function setTransitionDuration(value) {
        var duration = Number(value)

        if (!isFinite(duration))
            return

        root.transitionDuration = Math.max(
            0,
            Math.min(5, duration)
        )

        root.saveSettings()
    }

    function setTransitionFps(value) {
        var fps = Math.round(Number(value))

        if (!isFinite(fps))
            return

        root.transitionFps = Math.max(
            15,
            Math.min(120, fps)
        )

        root.saveSettings()
    }

    function setWallpaper(path) {
        var value = String(path || "").trim()

        if (!value.length)
            return

        if (!root.awwwAvailable)
            return

        root.pendingWallpaper = value
        root.applying = true

        queryProcess.exec([
            "awww",
            "query"
        ])
    }

    function randomWallpaper(list) {
        if (!list || list.length === 0)
            return

        var candidates = []

        for (var i = 0; i < list.length; i++) {
            var path = String(list[i] || "").trim()

            if (!path.length)
                continue

            if (
                list.length > 1
                && path === root.currentWallpaper
            ) {
                continue
            }

            candidates.push(path)
        }

        if (candidates.length === 0)
            candidates = list

        if (candidates.length === 0)
            return

        var index = Math.floor(
            Math.random() * candidates.length
        )

        var selected = String(
            candidates[index] || ""
        ).trim()

        if (!selected.length)
            return

        root.setWallpaper(selected)
    }

    function restore() {
        var value =
            String(root.currentWallpaper || "").trim()

        if (!value.length)
            return

        if (!root.awwwAvailable)
            return

        root.pendingWallpaper = value
        root.applying = true

        queryProcess.exec([
            "awww",
            "query"
        ])
    }

    function saveState(path) {
        if (!root.stateDirectory.length)
            return

        saveStateProcess.exec([
            "sh",
            "-c",
            "mkdir -p \"$1\" && printf '%s' \"$2\" > \"$1/wallpaper\"",
            "sh",
            root.stateDirectory,
            path
        ])
    }

    function saveSettings() {
        if (!root.stateDirectory.length)
            return

        saveSettingsProcess.exec([
            "sh",
            "-c",
            "mkdir -p \"$1\" && printf '%s\\n%s\\n%s' \"$2\" \"$3\" \"$4\" > \"$1/wallpaper-settings\"",
            "sh",
            root.stateDirectory,
            root.transitionType,
            String(root.transitionDuration),
            String(root.transitionFps)
        ])
    }

    function clearState() {
        if (root.stateFile.length > 0)
            clearStateProcess.exec([
                "rm",
                "-f",
                root.stateFile
            ])

        root.currentWallpaper = ""
    }

    function startDaemon() {
        if (!root.awwwAvailable)
            return

        if (daemonProcess.running)
            return

        root.daemonReady = false
        daemonProcess.running = true
    }

    function applyWallpaper() {
        var value =
            String(root.pendingWallpaper || "").trim()

        if (!value.length) {
            root.applying = false
            return
        }

        if (!root.daemonReady) {
            root.applying = false
            return
        }

        var command = [
            "awww",
            "img",
            value,
            "--transition-type",
            root.transitionType,
            "--transition-fps",
            String(root.transitionFps),
            "--transition-duration",
            String(root.transitionDuration)
        ]

        applyProcess.exec(command)
    }

    function applyWallust(path) {
        if (!root.wallustAvailable)
            return

        wallustProcess.exec([
            "wallust",
            "run",
            path
        ])
    }

    Process {
        id: awwwCheckProcess

        command: [
            "sh",
            "-c",
            "command -v awww >/dev/null 2>&1"
        ]

        onExited: function(exitCode) {
            root.awwwAvailable =
                exitCode === 0

            if (!root.awwwAvailable) {
                root.daemonReady = false
                return
            }

            queryStartupProcess.exec([
                "awww",
                "query"
            ])
        }
    }

    Process {
        id: wallustCheckProcess

        command: [
            "sh",
            "-c",
            "command -v wallust >/dev/null 2>&1"
        ]

        onExited: function(exitCode) {
            root.wallustAvailable =
                exitCode === 0
        }
    }

    Process {
        id: queryStartupProcess

        stdout: StdioCollector {
        }

        onExited: function(exitCode) {
            if (exitCode === 0) {
                root.daemonReady = true
                return
            }

            root.startDaemon()
        }
    }

    Process {
        id: queryProcess

        stdout: StdioCollector {
        }

        onExited: function(exitCode) {
            if (exitCode === 0) {
                root.daemonReady = true
                root.applyWallpaper()
                return
            }

            root.startDaemon()
            daemonWaitTimer.restart()
        }
    }

    Process {
        id: daemonProcess

        command: [
            "awww-daemon"
        ]

        onExited: {
            root.daemonReady = false
        }
    }

    Timer {
        id: daemonWaitTimer

        interval: 500
        repeat: false

        onTriggered: {
            daemonQueryProcess.exec([
                "awww",
                "query"
            ])
        }
    }

    Process {
        id: daemonQueryProcess

        stdout: StdioCollector {
        }

        onExited: function(exitCode) {
            if (exitCode !== 0) {
                root.daemonReady = false
                root.applying = false
                return
            }

            root.daemonReady = true
            root.applyWallpaper()
        }
    }

    Process {
        id: applyProcess

        onExited: function(exitCode) {
            if (exitCode !== 0) {
                root.applying = false
                return
            }

            root.currentWallpaper =
                root.pendingWallpaper

            root.saveState(
                root.pendingWallpaper
            )

            root.applyWallust(
                root.pendingWallpaper
            )

            root.applying = false
        }
    }

    Process {
        id: wallustProcess
    }

    Process {
        id: saveStateProcess
    }

    Process {
        id: saveSettingsProcess
    }

    Process {
        id: clearStateProcess
    }

    Process {
        id: stateProcess

        command: [
            "cat",
            root.stateFile
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                var value =
                    String(this.text || "").trim()

                if (value.length > 0)
                    root.currentWallpaper = value
            }
        }

        onExited: function(exitCode) {
            if (exitCode !== 0)
                return

            restoreDelay.restart()
        }
    }

    Process {
        id: settingsProcess

        command: [
            "cat",
            root.settingsFile
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                var value =
                    String(this.text || "").trim()

                if (!value.length)
                    return

                var lines = value.split("\n")

                if (lines.length > 0) {
                    var type =
                        String(lines[0] || "").trim()

                    for (
                        var i = 0;
                        i < root.transitions.length;
                        i++
                    ) {
                        if (
                            root.transitions[i].id
                            === type
                        ) {
                            root.transitionType = type
                            break
                        }
                    }
                }

                if (lines.length > 1) {
                    var duration =
                        Number(lines[1])

                    if (isFinite(duration)) {
                        root.transitionDuration =
                            Math.max(
                                0,
                                Math.min(5, duration)
                            )
                    }
                }

                if (lines.length > 2) {
                    var fps =
                        Math.round(
                            Number(lines[2])
                        )

                    if (isFinite(fps)) {
                        root.transitionFps =
                            Math.max(
                                15,
                                Math.min(120, fps)
                            )
                    }
                }
            }
        }
    }

    Process {
        id: fileCheckProcess

        onExited: function(exitCode) {
            if (exitCode !== 0)
                return

            root.restore()
        }
    }

    Timer {
        id: restoreDelay

        interval: 300
        repeat: false

        onTriggered: {
            fileCheckProcess.exec([
                "test",
                "-f",
                root.currentWallpaper
            ])
        }
    }

    Component.onCompleted: {
        awwwCheckProcess.running = true
        wallustCheckProcess.running = true

        if (root.stateFile.length > 0)
            stateProcess.running = true

        if (root.settingsFile.length > 0)
            settingsProcess.running = true
    }
}