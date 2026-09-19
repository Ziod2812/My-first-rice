pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property bool available: true

    function lock() {
        Quickshell.execDetached([
            "loginctl",
            "lock-session"
        ])
    }

    function logout() {
        var user = String(Quickshell.env("USER") || "")

        if (!user.length)
            return

        Quickshell.execDetached([
            "loginctl",
            "terminate-user",
            user
        ])
    }

    function suspend() {
        Quickshell.execDetached([
            "systemctl",
            "suspend"
        ])
    }

    function hibernate() {
        Quickshell.execDetached([
            "systemctl",
            "hibernate"
        ])
    }

    function reboot() {
        Quickshell.execDetached([
            "systemctl",
            "reboot"
        ])
    }

    function poweroff() {
        Quickshell.execDetached([
            "systemctl",
            "poweroff"
        ])
    }
}