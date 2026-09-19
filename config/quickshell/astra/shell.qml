//@ pragma UseQApplication
import Quickshell
import "./bar"

Scope {
    id: root

    Launcher {
        id: launcher
    }

    Variants {
        model: Quickshell.screens

        Bar {
            property var modelData
        }
    }
}