pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    PwObjectTracker {
        id: tracker

        objects:
            Pipewire.nodes.values
    }

    ScriptModel {
        id: applicationStreamModel

        values:
            Pipewire.nodes.values.filter(function(node) {
                if (!node)
                    return false

                if (!node.isStream)
                    return false

                if (node.isSink)
                    return false

                if (node.type !== "Stream/Output/Audio")
                    return false

                return true
            })
    }

    readonly property var applicationStreams:
        applicationStreamModel.values

    readonly property var defaultSink:
        Pipewire.defaultAudioSink

    PwObjectTracker {
        id: defaultSinkTracker

        objects: [
            root.defaultSink
        ]
    }

    readonly property real masterVolume:
        root.defaultSink &&
        root.defaultSink.ready &&
        root.defaultSink.audio
            ? root.defaultSink.audio.volume
            : 0

    readonly property bool masterMuted:
        root.defaultSink &&
        root.defaultSink.ready &&
        root.defaultSink.audio
            ? root.defaultSink.audio.muted
            : false

    function setMasterVolume(value) {
        if (
            !root.defaultSink ||
            !root.defaultSink.ready ||
            !root.defaultSink.audio
        ) {
            return
        }

        root.defaultSink.audio.volume =
            Math.max(
                0,
                Math.min(
                    1.5,
                    Number(value)
                )
            )
    }

    function toggleMasterMute() {
        if (
            !root.defaultSink ||
            !root.defaultSink.ready ||
            !root.defaultSink.audio
        ) {
            return
        }

        root.defaultSink.audio.muted =
            !root.defaultSink.audio.muted
    }

    function setApplicationVolume(node, value) {
        if (
            !node ||
            !node.ready ||
            !node.audio
        ) {
            return
        }

        node.audio.volume =
            Math.max(
                0,
                Math.min(
                    1.5,
                    Number(value)
                )
            )
    }

    function toggleApplicationMute(node) {
        if (
            !node ||
            !node.ready ||
            !node.audio
        ) {
            return
        }

        node.audio.muted =
            !node.audio.muted
    }

    function applicationName(node) {
        if (!node)
            return "Unknown application"

        if (
            node.properties &&
            node.properties["application.name"]
        ) {
            return String(
                node.properties["application.name"]
            )
        }

        if (node.description)
            return String(node.description)

        if (node.name)
            return String(node.name)

        return "Unknown application"
    }

    function applicationIcon(node) {
        if (
            !node ||
            !node.properties
        ) {
            return ""
        }

        return String(
            node.properties["application.icon-name"] || ""
        )
    }

    function debugStreams() {
        console.log(
            "Astra AudioService: " +
            root.applicationStreams.length +
            " application stream(s)"
        )

        for (
            const node of root.applicationStreams
        ) {
            console.log(
                "Audio stream:",
                node.id,
                root.applicationName(node),
                node.name,
                "ready:",
                node.ready
            )
        }
    }

    Connections {
        target: Pipewire

        function onReadyChanged() {
            if (Pipewire.ready)
                root.debugStreams()
        }
    }

    Connections {
        target: applicationStreamModel

        function onValuesChanged() {
            if (Pipewire.ready)
                root.debugStreams()
        }
    }

    Component.onCompleted: {
        if (Pipewire.ready)
            root.debugStreams()
    }
}