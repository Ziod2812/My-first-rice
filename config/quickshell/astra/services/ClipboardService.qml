pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string currentText: ""
    property var history: []
    property bool cliphistAvailable: false
    property bool wlClipboardAvailable: false
    property bool loadingHistory: false

    readonly property bool available: root.wlClipboardAvailable
    readonly property int historyCount: root.history.length

    function refreshCurrent() {
        if (clipboardProcess.running)
            return

        clipboardProcess.running = true
    }

    function refreshHistory() {
        if (!root.cliphistAvailable)
            return

        if (historyProcess.running)
            return

        root.loadingHistory = true
        historyProcess.running = true
    }

    function copyText(value) {
        var text = String(value || "")

        if (!text.length)
            return

        Quickshell.execDetached({
            command: [
                "sh",
                "-c",
                "printf '%s' \"$1\" | wl-copy",
                "sh",
                text
            ]
        })

        root.currentText = text
    }

    function copyEntry(entry) {
        if (!root.cliphistAvailable)
            return

        if (!entry)
            return

        var value = String(entry)

        Quickshell.execDetached({
            command: [
                "sh",
                "-c",
                "printf '%s\\n' \"$1\" | cliphist decode | wl-copy",
                "sh",
                value
            ]
        })
    }

    function clearHistory() {
        if (!root.cliphistAvailable)
            return

        Quickshell.execDetached([
            "cliphist",
            "wipe"
        ])

        root.history = []
    }

    Process {
        id: clipboardCheckProcess

        command: [
            "sh",
            "-c",
            "command -v wl-paste >/dev/null 2>&1 && command -v wl-copy >/dev/null 2>&1"
        ]

        running: true

        onExited: function(exitCode) {
            root.wlClipboardAvailable = exitCode === 0

            if (root.wlClipboardAvailable)
                root.refreshCurrent()
        }
    }

    Process {
        id: cliphistCheckProcess

        command: [
            "sh",
            "-c",
            "command -v cliphist >/dev/null 2>&1"
        ]

        running: true

        onExited: function(exitCode) {
            root.cliphistAvailable = exitCode === 0

            if (root.cliphistAvailable)
                root.refreshHistory()
        }
    }

    Process {
        id: clipboardProcess

        command: [
            "wl-paste",
            "--no-newline"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                root.currentText = String(this.text || "")
            }
        }
    }

    Process {
        id: historyProcess

        command: [
            "cliphist",
            "list"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                var value = String(this.text || "").trim()

                if (!value.length) {
                    root.history = []
                    root.loadingHistory = false
                    return
                }

                var lines = value.split("\n")
                var result = []

                for (var i = 0; i < lines.length; i++) {
                    var line = String(lines[i] || "")

                    if (!line.length)
                        continue

                    result.push(line)
                }

                root.history = result
                root.loadingHistory = false
            }
        }
    }

    Timer {
        id: clipboardTimer

        interval: 1000
        repeat: true
        running: root.wlClipboardAvailable

        onTriggered: {
            root.refreshCurrent()
        }
    }

    Component.onCompleted: {
        clipboardCheckProcess.running = true
        cliphistCheckProcess.running = true
    }
}