import QtQuick
import qs
import "./components"

Row {
    id: root

    property var trayWindow: null

    spacing: 10

    SystemStats {
        anchors.verticalCenter: parent.verticalCenter
    }

    Network {
        anchors.verticalCenter: parent.verticalCenter
    }

    Volume {
        anchors.verticalCenter: parent.verticalCenter
    }

    Battery {
        anchors.verticalCenter: parent.verticalCenter
    }

    SystemTray {
        trayWindow: root.trayWindow
        anchors.verticalCenter: parent.verticalCenter
    }
}