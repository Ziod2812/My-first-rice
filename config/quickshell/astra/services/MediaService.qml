pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property var players:
        Mpris.players.values

    property var activePlayer: null

    readonly property bool available:
        root.activePlayer !== null

    readonly property string playerName:
        root.activePlayer
        ? String(
            root.activePlayer.identity ||
            "Media"
        )
        : "Media"

    readonly property string title:
        root.activePlayer
        ? String(
            root.activePlayer.trackTitle ||
            "Nothing playing"
        )
        : "Nothing playing"

    readonly property string artist:
        root.activePlayer
        ? String(
            root.activePlayer.trackArtist ||
            "Unknown Artist"
        )
        : "Unknown Artist"

    readonly property string album:
        root.activePlayer
        ? String(
            root.activePlayer.trackAlbum ||
            "Unknown Album"
        )
        : "Unknown Album"

    readonly property string artwork:
        root.activePlayer
        ? String(
            root.activePlayer.trackArtUrl ||
            ""
        )
        : ""

    readonly property bool playing:
        root.activePlayer
        ? root.activePlayer.isPlaying
        : false

    readonly property real position:
        root.activePlayer
        ? Number(
            root.activePlayer.position || 0
        )
        : 0

    readonly property real length:
        root.activePlayer
        ? Number(
            root.activePlayer.length || 0
        )
        : 0

    readonly property real progress:
        root.length > 0
        ? Math.max(
            0,
            Math.min(
                1,
                root.position /
                root.length
            )
        )
        : 0

    readonly property bool canPrevious:
        root.activePlayer
        ? root.activePlayer.canGoPrevious
        : false

    readonly property bool canNext:
        root.activePlayer
        ? root.activePlayer.canGoNext
        : false

    readonly property bool canPlayPause:
        root.activePlayer
        ? root.activePlayer.canTogglePlaying
        : false

    readonly property bool canSeek:
        root.activePlayer
        ? root.activePlayer.canSeek &&
          root.activePlayer.positionSupported
        : false

    readonly property bool volumeSupported:
        root.activePlayer
        ? root.activePlayer.volumeSupported
        : false

    readonly property real volume:
        root.activePlayer
        ? Math.max(
            0,
            Math.min(
                1,
                Number(
                    root.activePlayer.volume
                )
            )
        )
        : 1

    readonly property bool shuffleSupported:
        root.activePlayer
        ? root.activePlayer.shuffleSupported
        : false

    readonly property bool shuffle:
        root.activePlayer
        ? Boolean(
            root.activePlayer.shuffle
        )
        : false

    function selectActivePlayer() {
        const list =
            root.players

        if (
            !list ||
            list.length === 0
        ) {
            root.activePlayer = null
            return
        }

        for (
            const player of list
        ) {
            if (
                player &&
                player.isPlaying
            ) {
                root.activePlayer =
                    player

                return
            }
        }

        if (
            root.activePlayer &&
            list.indexOf(
                root.activePlayer
            ) !== -1
        ) {
            return
        }

        root.activePlayer =
            list[0]
    }

    function togglePlaying() {
        if (
            !root.activePlayer ||
            !root.activePlayer.canTogglePlaying
        ) {
            return
        }

        root.activePlayer.togglePlaying()
    }

    function previous() {
        if (
            !root.activePlayer ||
            !root.activePlayer.canGoPrevious
        ) {
            return
        }

        root.activePlayer.previous()
    }

    function next() {
        if (
            !root.activePlayer ||
            !root.activePlayer.canGoNext
        ) {
            return
        }

        root.activePlayer.next()
    }

    function seekTo(value) {
        if (
            !root.activePlayer ||
            !root.activePlayer.canSeek ||
            !root.activePlayer.positionSupported
        ) {
            return
        }

        root.activePlayer.position =
            Math.max(
                0,
                Math.min(
                    root.length,
                    Number(value)
                )
            )
    }

    function seekBy(value) {
        if (
            !root.activePlayer ||
            !root.activePlayer.canSeek
        ) {
            return
        }

        root.activePlayer.seek(
            Number(value)
        )
    }

    function setVolume(value) {
        if (
            !root.activePlayer ||
            !root.activePlayer.canControl ||
            !root.activePlayer.volumeSupported
        ) {
            return
        }

        root.activePlayer.volume =
            Math.max(
                0,
                Math.min(
                    1,
                    Number(value)
                )
            )
    }

    function toggleShuffle() {
        if (
            !root.activePlayer ||
            !root.activePlayer.canControl ||
            !root.activePlayer.shuffleSupported
        ) {
            return
        }

        root.activePlayer.shuffle =
            !root.activePlayer.shuffle
    }

    function raisePlayer() {
        if (
            !root.activePlayer ||
            !root.activePlayer.canRaise
        ) {
            return
        }

        root.activePlayer.raise()
    }

    function formatTime(value) {
        const seconds =
            Math.max(
                0,
                Math.floor(
                    Number(value) || 0
                )
            )

        const minutes =
            Math.floor(
                seconds / 60
            )

        const remaining =
            seconds % 60

        return (
            minutes +
            ":" +
            remaining
                .toString()
                .padStart(
                    2,
                    "0"
                )
        )
    }

    Timer {
        id: playerTimer

        interval: 500

        running: true

        repeat: true

        onTriggered: {
            root.selectActivePlayer()
        }
    }

    Connections {
        target: Mpris.players

        function onObjectInsertedPost() {
            root.selectActivePlayer()
        }

        function onObjectRemovedPost() {
            root.selectActivePlayer()
        }
    }

    Component.onCompleted: {
        root.selectActivePlayer()
    }
}