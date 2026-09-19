import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var alarms: []

    property string lastTriggeredKey: ""

    signal alarmTriggered(
        string label,
        int hour,
        int minute
    )

    FileView {
        id: alarmFile

        path:
            Quickshell.statePath(
                "astra/alarms.json"
            )

        preload: true

        watchChanges: false

        adapter: JsonAdapter {
            property var alarms: []
        }

        onLoaded: {
            root.loadAlarms()
        }

        onAdapterUpdated: {
            root.loadAlarms()
        }
    }

    Timer {
        interval: 10000

        running: true

        repeat: true

        triggeredOnStart: true

        onTriggered: {
            root.checkAlarms()
        }
    }

    function loadAlarms() {
        const value =
            alarmFile.adapter.alarms

        if (Array.isArray(value)) {
            root.alarms = value
        } else {
            root.alarms = []
        }
    }

    function saveAlarms() {
        alarmFile.adapter.alarms =
            root.alarms

        alarmFile.writeAdapter()
    }

    function nextId() {
        let highest = 0

        for (
            const alarm of root.alarms
        ) {
            const value =
                Number(alarm.id)

            if (
                !isNaN(value) &&
                value > highest
            ) {
                highest = value
            }
        }

        return highest + 1
    }

    function addAlarm(
        hour,
        minute,
        label,
        repeatMode
    ) {
        const safeHour =
            Math.max(
                0,
                Math.min(
                    23,
                    Number(hour)
                )
            )

        const safeMinute =
            Math.max(
                0,
                Math.min(
                    59,
                    Number(minute)
                )
            )

        const newAlarm = {
            id: root.nextId(),
            hour: safeHour,
            minute: safeMinute,
            label:
                String(label).trim() ||
                "Alarm",
            repeat:
                repeatMode ||
                "once",
            enabled: true
        }

        root.alarms =
            root.alarms.concat([
                newAlarm
            ])

        root.saveAlarms()
    }

    function removeAlarm(id) {
        root.alarms =
            root.alarms.filter(
                function(alarm) {
                    return (
                        Number(alarm.id) !==
                        Number(id)
                    )
                }
            )

        root.saveAlarms()
    }

    function toggleAlarm(id) {
        root.alarms =
            root.alarms.map(
                function(alarm) {
                    if (
                        Number(alarm.id) ===
                        Number(id)
                    ) {
                        return {
                            id: alarm.id,
                            hour: alarm.hour,
                            minute: alarm.minute,
                            label: alarm.label,
                            repeat: alarm.repeat,
                            enabled:
                                !Boolean(
                                    alarm.enabled
                                )
                        }
                    }

                    return alarm
                }
            )

        root.saveAlarms()
    }

    function checkAlarms() {
        const now =
            new Date()

        const hour =
            now.getHours()

        const minute =
            now.getMinutes()

        const weekday =
            now.getDay()

        const dateKey =
            Qt.formatDateTime(
                now,
                "yyyy-MM-dd"
            )

        for (
            const alarm of root.alarms
        ) {
            if (!alarm.enabled)
                continue

            if (
                Number(alarm.hour) !==
                hour
            )
                continue

            if (
                Number(alarm.minute) !==
                minute
            )
                continue

            if (
                !root.shouldTrigger(
                    alarm,
                    weekday
                )
            )
                continue

            const triggerKey =
                String(alarm.id) +
                "-" +
                dateKey +
                "-" +
                hour +
                "-" +
                minute

            if (
                root.lastTriggeredKey ===
                triggerKey
            ) {
                continue
            }

            root.lastTriggeredKey =
                triggerKey

            root.fireAlarm(alarm)
        }
    }

    function shouldTrigger(
        alarm,
        weekday
    ) {
        const repeat =
            String(alarm.repeat)

        if (
            repeat === "daily"
        ) {
            return true
        }

        if (
            repeat === "weekdays"
        ) {
            return (
                weekday >= 1 &&
                weekday <= 5
            )
        }

        if (
            repeat === "weekends"
        ) {
            return (
                weekday === 0 ||
                weekday === 6
            )
        }

        return repeat === "once"
    }

    function fireAlarm(alarm) {
        root.alarmTriggered(
            String(alarm.label),
            Number(alarm.hour),
            Number(alarm.minute)
        )

        Quickshell.execDetached([
            "notify-send",
            "-u",
            "critical",
            "-i",
            "alarm",
            "Astra Alarm",
            String(alarm.label)
        ])

        if (
            String(alarm.repeat) ===
            "once"
        ) {
            root.alarms =
                root.alarms.map(
                    function(item) {
                        if (
                            Number(item.id) ===
                            Number(alarm.id)
                        ) {
                            return {
                                id: item.id,
                                hour: item.hour,
                                minute: item.minute,
                                label: item.label,
                                repeat: item.repeat,
                                enabled: false
                            }
                        }

                        return item
                    }
                )

            root.saveAlarms()
        }
    }
}