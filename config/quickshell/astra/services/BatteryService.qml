import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property bool available: false

    property int percentage: 0

    property string status: "Unknown"
    property string capacityLevel: "Unknown"
    property string chargeTypes: ""

    property int cycleCount: -1

    property real energyNow: -1
    property real energyFull: -1
    property real energyFullDesign: -1

    property real chargeNow: -1
    property real chargeFull: -1
    property real chargeFullDesign: -1

    property real powerNow: -1
    property real voltageNow: -1

    property real batteryHealth: -1

    property string manufacturer: ""
    property string modelName: ""
    property string technology: ""

    property string batteryPath: ""

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            if (!batteryProcess.running)
                batteryProcess.running = true
        }
    }

    Process {
        id: batteryProcess

        command: [
            "bash",
            "-c",
            "battery=''; " +
            "for d in /sys/class/power_supply/*; do " +
            "    [ -d \"$d\" ] || continue; " +
            "    type=$(cat \"$d/type\" 2>/dev/null); " +
            "    [ \"$type\" = 'Battery' ] || continue; " +
            "    present=$(cat \"$d/present\" 2>/dev/null); " +
            "    [ \"$present\" = '0' ] && continue; " +
            "    [ -r \"$d/capacity\" ] || continue; " +
            "    battery=\"$d\"; " +
            "    break; " +
            "done; " +

            "if [ -z \"$battery\" ]; then " +
            "    exit 0; " +
            "fi; " +

            "capacity=$(cat \"$battery/capacity\" 2>/dev/null); " +
            "status=$(cat \"$battery/status\" 2>/dev/null); " +
            "level=$(cat \"$battery/capacity_level\" 2>/dev/null); " +
            "charge_types=$(cat \"$battery/charge_types\" 2>/dev/null); " +
            "cycles=$(cat \"$battery/cycle_count\" 2>/dev/null); " +

            "energy_now=$(cat \"$battery/energy_now\" 2>/dev/null); " +
            "energy_full=$(cat \"$battery/energy_full\" 2>/dev/null); " +
            "energy_design=$(cat \"$battery/energy_full_design\" 2>/dev/null); " +

            "charge_now=$(cat \"$battery/charge_now\" 2>/dev/null); " +
            "charge_full=$(cat \"$battery/charge_full\" 2>/dev/null); " +
            "charge_design=$(cat \"$battery/charge_full_design\" 2>/dev/null); " +

            "power_now=$(cat \"$battery/power_now\" 2>/dev/null); " +
            "voltage_now=$(cat \"$battery/voltage_now\" 2>/dev/null); " +

            "manufacturer=$(cat \"$battery/manufacturer\" 2>/dev/null); " +
            "model=$(cat \"$battery/model_name\" 2>/dev/null); " +
            "technology=$(cat \"$battery/technology\" 2>/dev/null); " +

            "printf '%s\\t%s\\t%s\\t%s\\t%s\\t%s\\t%s\\t%s\\t%s\\t%s\\t%s\\t%s\\t%s\\t%s\\t%s\\t%s\\t%s\\n' " +
            "\"$battery\" " +
            "\"$capacity\" " +
            "\"$status\" " +
            "\"$level\" " +
            "\"$charge_types\" " +
            "\"$cycles\" " +
            "\"$energy_now\" " +
            "\"$energy_full\" " +
            "\"$energy_design\" " +
            "\"$charge_now\" " +
            "\"$charge_full\" " +
            "\"$charge_design\" " +
            "\"$power_now\" " +
            "\"$voltage_now\" " +
            "\"$manufacturer\" " +
            "\"$model\" " +
            "\"$technology\""
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const value = text.trim()

                if (value.length === 0) {
                    root.available = false
                    return
                }

                const parts = value.split("\t")

                if (parts.length < 17) {
                    root.available = false
                    return
                }

                root.batteryPath = parts[0].trim()

                const newPercentage =
                    parseInt(parts[1].trim())

                if (!isNaN(newPercentage)) {
                    root.percentage =
                        Math.max(
                            0,
                            Math.min(
                                100,
                                newPercentage
                            )
                        )
                }

                root.status =
                    parts[2].trim() || "Unknown"

                root.capacityLevel =
                    parts[3].trim() || "Unknown"

                root.chargeTypes =
                    parts[4].trim()

                const newCycles =
                    parseInt(parts[5].trim())

                root.cycleCount =
                    isNaN(newCycles)
                        ? -1
                        : newCycles

                const newEnergyNow =
                    Number(parts[6].trim())

                const newEnergyFull =
                    Number(parts[7].trim())

                const newEnergyDesign =
                    Number(parts[8].trim())

                root.energyNow =
                    isNaN(newEnergyNow)
                        ? -1
                        : newEnergyNow / 1000000

                root.energyFull =
                    isNaN(newEnergyFull)
                        ? -1
                        : newEnergyFull / 1000000

                root.energyFullDesign =
                    isNaN(newEnergyDesign)
                        ? -1
                        : newEnergyDesign / 1000000

                const newChargeNow =
                    Number(parts[9].trim())

                const newChargeFull =
                    Number(parts[10].trim())

                const newChargeDesign =
                    Number(parts[11].trim())

                root.chargeNow =
                    isNaN(newChargeNow)
                        ? -1
                        : newChargeNow / 1000000

                root.chargeFull =
                    isNaN(newChargeFull)
                        ? -1
                        : newChargeFull / 1000000

                root.chargeFullDesign =
                    isNaN(newChargeDesign)
                        ? -1
                        : newChargeDesign / 1000000

                const newPower =
                    Number(parts[12].trim())

                const newVoltage =
                    Number(parts[13].trim())

                root.powerNow =
                    isNaN(newPower)
                        ? -1
                        : newPower / 1000000

                root.voltageNow =
                    isNaN(newVoltage)
                        ? -1
                        : newVoltage / 1000000

                root.manufacturer =
                    parts[14].trim()

                root.modelName =
                    parts[15].trim()

                root.technology =
                    parts[16].trim()

                if (
                    root.energyFull > 0 &&
                    root.energyFullDesign > 0
                ) {
                    root.batteryHealth =
                        Math.max(
                            0,
                            Math.min(
                                100,
                                (
                                    root.energyFull /
                                    root.energyFullDesign
                                ) * 100
                            )
                        )
                } else if (
                    root.chargeFull > 0 &&
                    root.chargeFullDesign > 0
                ) {
                    root.batteryHealth =
                        Math.max(
                            0,
                            Math.min(
                                100,
                                (
                                    root.chargeFull /
                                    root.chargeFullDesign
                                ) * 100
                            )
                        )
                } else {
                    root.batteryHealth = -1
                }

                root.available = true
            }
        }
    }
}