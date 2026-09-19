pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    readonly property var workspaces: Hyprland.workspaces.values
    readonly property var monitors: Hyprland.monitors.values
    readonly property var windows: Hyprland.toplevels.values

    readonly property var focusedWorkspace: Hyprland.focusedWorkspace
    readonly property var focusedMonitor: Hyprland.focusedMonitor
    readonly property var activeWindow: Hyprland.activeToplevel

    readonly property int focusedWorkspaceId:
        root.focusedWorkspace
        ? root.focusedWorkspace.id
        : 0

    readonly property string focusedWorkspaceName:
        root.focusedWorkspace
        ? String(root.focusedWorkspace.name || root.focusedWorkspace.id)
        : ""

    readonly property string focusedMonitorName:
        root.focusedMonitor
        ? String(root.focusedMonitor.name || "")
        : ""

    readonly property string activeWindowTitle:
        root.activeWindow
        ? String(root.activeWindow.title || "")
        : ""

    readonly property string activeWindowAddress:
        root.activeWindow
        ? String(root.activeWindow.address || "")
        : ""

    readonly property int workspaceCount:
        root.workspaces.length

    readonly property int monitorCount:
        root.monitors.length

    readonly property int windowCount:
        root.windows.length

    function dispatch(request) {
        if (!request)
            return

        Hyprland.dispatch(String(request))
    }

    function workspace(id) {
        Hyprland.dispatch("workspace " + String(id))
    }

    function previousWorkspace() {
        Hyprland.dispatch("workspace m-1")
    }

    function nextWorkspace() {
        Hyprland.dispatch("workspace m+1")
    }

    function moveToWorkspace(id) {
        Hyprland.dispatch("movetoworkspace " + String(id))
    }

    function moveToWorkspaceSilent(id) {
        Hyprland.dispatch("movetoworkspacesilent " + String(id))
    }

    function focusDirection(direction) {
        Hyprland.dispatch("movefocus " + String(direction))
    }

    function moveWindowDirection(direction) {
        Hyprland.dispatch("movewindow " + String(direction))
    }

    function toggleFloating() {
        Hyprland.dispatch("togglefloating")
    }

    function toggleFullscreen() {
        Hyprland.dispatch("fullscreen 0")
    }

    function closeActiveWindow() {
        Hyprland.dispatch("killactive")
    }

    function togglePseudo() {
        Hyprland.dispatch("pseudo")
    }

    function toggleSplit() {
        Hyprland.dispatch("togglesplit")
    }

    function centerActiveWindow() {
        Hyprland.dispatch("centerwindow")
    }

    function toggleSpecialWorkspace(name) {
        Hyprland.dispatch(
            "togglespecialworkspace " + String(name || "")
        )
    }

    function moveToSpecialWorkspace(name) {
        Hyprland.dispatch(
            "movetoworkspacesilent special:" + String(name || "")
        )
    }

    function refresh() {
        Hyprland.refreshMonitors()
        Hyprland.refreshWorkspaces()
        Hyprland.refreshToplevels()
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            root.refresh()
        }
    }

    Component.onCompleted: {
        root.refresh()
    }
}