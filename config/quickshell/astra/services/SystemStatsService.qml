import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property real cpuUsage: 0

    property real memoryUsed: 0
    property real memoryTotal: 0
    property real memoryPercent: 0
    property string memoryType: "RAM"

    property real gpuUsage: -1
    property string gpuVendor: ""

    property real diskPercent: 0
    property string diskType: "DISK"

    property bool ready: false

    implicitWidth: 0
    implicitHeight: 0

    Timer {
        id: refreshTimer

        interval: 1500
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: statsProcess.running = true
    }

    Process {
        id: statsProcess

        command: [
            "bash",
            "-c",
            "read cpu user nice system idle iowait irq softirq steal rest < /proc/stat; " +
            "total1=$((user+nice+system+idle+iowait+irq+softirq+steal)); " +
            "idle1=$((idle+iowait)); " +
            "sleep 0.12; " +
            "read cpu user nice system idle iowait irq softirq steal rest < /proc/stat; " +
            "total2=$((user+nice+system+idle+iowait+irq+softirq+steal)); " +
            "idle2=$((idle+iowait)); " +
            "dt=$((total2-total1)); " +
            "di=$((idle2-idle1)); " +
            "if [ \"$dt\" -gt 0 ]; then cpu=$((100*(dt-di)/dt)); else cpu=0; fi; " +

            "memtotal=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo); " +
            "memavail=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo); " +
            "memused=$((memtotal-memavail)); " +
            "if [ \"$memtotal\" -gt 0 ]; then mempct=$((100*memused/memtotal)); else mempct=0; fi; " +

            "memtype='RAM'; " +
            "if command -v dmidecode >/dev/null 2>&1; then " +
            "dmi=$(dmidecode -t memory 2>/dev/null | awk -F': ' '/^[[:space:]]*Type: / && $2 !~ /Unknown|RAM$/ {print $2; exit}'); " +
            "if [ -n \"$dmi\" ]; then memtype=\"$dmi\"; fi; " +
            "fi; " +

            "disk=$(df -P / 2>/dev/null | awk 'NR==2 {gsub(/%/,\"\",$5); print $5}'); " +
            "case \"$disk\" in ''|*[!0-9]*) disk=0 ;; esac; " +

            "disktype='DISK'; " +
            "source=$(findmnt -n -o SOURCE / 2>/dev/null); " +

            "if [ -n \"$source\" ] && command -v lsblk >/dev/null 2>&1; then " +
            "diskdev=$(lsblk -ndo PKNAME \"$source\" 2>/dev/null | head -n1); " +

            "if [ -z \"$diskdev\" ]; then " +
            "diskdev=$(lsblk -ndo NAME \"$source\" 2>/dev/null | head -n1); " +
            "fi; " +

            "if [ -n \"$diskdev\" ] && [ -r \"/sys/class/block/$diskdev/queue/rotational\" ]; then " +
            "rot=$(cat \"/sys/class/block/$diskdev/queue/rotational\" 2>/dev/null); " +
            "case \"$rot\" in " +
            "0) disktype='SSD' ;; " +
            "1) disktype='HDD' ;; " +
            "esac; " +
            "fi; " +
            "fi; " +

            "if [ \"$disktype\" = 'DISK' ]; then " +
            "for dev in /sys/class/block/*/queue/rotational; do " +
            "if [ -r \"$dev\" ]; then " +
            "rot=$(cat \"$dev\" 2>/dev/null); " +
            "case \"$rot\" in " +
            "0) disktype='SSD'; break ;; " +
            "1) disktype='HDD'; break ;; " +
            "esac; " +
            "fi; " +
            "done; " +
            "fi; " +

            "gpu=-1; " +
            "vendor=''; " +

            "if command -v nvidia-smi >/dev/null 2>&1; then " +
            "value=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1); " +
            "case \"$value\" in ''|*[!0-9]*) ;; *) gpu=$value; vendor='NVIDIA' ;; esac; " +
            "fi; " +

            "if [ \"$gpu\" = '-1' ]; then " +
            "for f in /sys/class/drm/card*/device/gpu_busy_percent; do " +
            "if [ -r \"$f\" ]; then " +
            "value=$(cat \"$f\" 2>/dev/null); " +
            "case \"$value\" in ''|*[!0-9]*) ;; *) gpu=$value; vendor='AMD' ;; esac; " +
            "[ \"$gpu\" != '-1' ] && break; " +
            "fi; " +
            "done; " +
            "fi; " +

            "if [ \"$gpu\" = '-1' ]; then " +
            "for f in /sys/class/drm/card*/device/gt/gt*/busy_percent /sys/class/drm/card*/device/gt_busy_percent; do " +
            "if [ -r \"$f\" ]; then " +
            "value=$(cat \"$f\" 2>/dev/null); " +
            "case \"$value\" in ''|*[!0-9]*) ;; *) gpu=$value; vendor='Intel' ;; esac; " +
            "[ \"$gpu\" != '-1' ] && break; " +
            "fi; " +
            "done; " +
            "fi; " +

            "printf '%s|%s|%s|%s|%s|%s|%s|%s|%s\\n' " +
            "\"$cpu\" " +
            "\"$memused\" " +
            "\"$memtotal\" " +
            "\"$mempct\" " +
            "\"$memtype\" " +
            "\"$gpu\" " +
            "\"$vendor\" " +
            "\"$disk\" " +
            "\"$disktype\""
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                var value = text.trim()

                if (value.length === 0)
                    return

                var parts = value.split("|")

                if (parts.length < 9)
                    return

                var newCpu = Number(parts[0])
                var newMemoryUsed = Number(parts[1])
                var newMemoryTotal = Number(parts[2])
                var newMemoryPercent = Number(parts[3])
                var newGpu = Number(parts[5])
                var newDisk = Number(parts[7])

                if (!isFinite(newCpu))
                    newCpu = 0

                if (!isFinite(newMemoryUsed))
                    newMemoryUsed = 0

                if (!isFinite(newMemoryTotal))
                    newMemoryTotal = 0

                if (!isFinite(newMemoryPercent))
                    newMemoryPercent = 0

                if (!isFinite(newGpu))
                    newGpu = -1

                if (!isFinite(newDisk))
                    newDisk = 0

                root.cpuUsage = newCpu

                root.memoryUsed = newMemoryUsed / 1024
                root.memoryTotal = newMemoryTotal / 1024
                root.memoryPercent = newMemoryPercent

                root.memoryType = parts[4].trim()

                if (root.memoryType.length === 0)
                    root.memoryType = "RAM"

                root.gpuUsage = newGpu
                root.gpuVendor = parts[6].trim()

                root.diskPercent = newDisk

                var detectedDiskType = parts[8].trim()

                if (
                    detectedDiskType === "SSD" ||
                    detectedDiskType === "HDD"
                ) {
                    root.diskType = detectedDiskType
                } else {
                    root.diskType = "DISK"
                }

                root.ready = true
            }
        }
    }
}