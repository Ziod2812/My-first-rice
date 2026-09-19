pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    property bool enabled: true

    NotificationServer {
        id: server

        bodySupported: true
        bodyMarkupSupported: false
        bodyImagesSupported: true
        imageSupported: true
        actionsSupported: true
        actionIconsSupported: true
        persistenceSupported: true
        keepOnReload: true

        onNotification: function(notification) {
            if (!root.enabled)
                return

            notification.tracked = true
        }
    }

    readonly property var notifications:
        server.trackedNotifications.values

    readonly property int count:
        root.notifications.length

    function dismiss(notification) {
        if (!notification)
            return

        notification.dismiss()
    }

    function expire(notification) {
        if (!notification)
            return

        notification.expire()
    }

    function clearAll() {
        var list = root.notifications.slice()

        for (var i = 0; i < list.length; i++) {
            if (list[i])
                list[i].dismiss()
        }
    }

    function latest() {
        if (root.notifications.length === 0)
            return null

        return root.notifications[
            root.notifications.length - 1
        ]
    }

    function findAction(notification) {
        if (!notification)
            return null

        var actions = notification.actions

        if (!actions || actions.length === 0)
            return null

        for (var i = 0; i < actions.length; i++) {
            var action = actions[i]

            if (!action)
                continue

            if (
                String(action.identifier)
                === "default"
            ) {
                return action
            }
        }

        if (actions.length === 1)
            return actions[0]

        return actions[0]
    }

    function activate(notification) {
        if (!notification)
            return false

        var action = root.findAction(
            notification
        )

        if (action) {
            try {
                action.invoke()
                return true
            } catch (error) {
                return false
            }
        }

        var desktopId = String(
            notification.desktopEntry || ""
        ).trim()

        if (desktopId.length > 0) {
            var entry =
                DesktopEntries.byId(desktopId)

            if (!entry) {
                entry =
                    DesktopEntries.heuristicLookup(
                        String(
                            notification.appName || ""
                        )
                    )
            }

            if (entry) {
                entry.execute()
                return true
            }
        }

        var hints = notification.hints

        if (hints) {
            var urlKeys = [
                "url",
                "link",
                "uri",
                "desktop-url",
                "x-url"
            ]

            for (
                var j = 0;
                j < urlKeys.length;
                j++
            ) {
                var key = urlKeys[j]

                if (
                    hints[key] !== undefined
                    && hints[key] !== null
                ) {
                    var url = String(
                        hints[key]
                    ).trim()

                    if (
                        url.indexOf("http://") === 0
                        || url.indexOf("https://") === 0
                        || url.indexOf("file://") === 0
                    ) {
                        root.openUrl(url)
                        return true
                    }
                }
            }
        }

        var body =
            String(
                notification.body || ""
            ).trim()

        var urlMatch =
            body.match(
                /(https?:\/\/[^\s<>"']+)/
            )

        if (urlMatch && urlMatch.length > 0) {
            root.openUrl(
                urlMatch[1]
            )

            return true
        }

        return false
    }

    function openUrl(url) {
        var value =
            String(url || "").trim()

        if (!value.length)
            return

        if (
            value.indexOf("http://") !== 0
            && value.indexOf("https://") !== 0
            && value.indexOf("file://") !== 0
        ) {
            return
        }

        Quickshell.execDetached([
            "xdg-open",
            value
        ])
    }
}