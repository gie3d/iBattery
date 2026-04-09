import Foundation

// ANSI color codes
private let reset  = "\u{001B}[0m"
private let bold   = "\u{001B}[1m"
private let green  = "\u{001B}[32m"
private let yellow = "\u{001B}[33m"
private let red    = "\u{001B}[31m"
private let cyan   = "\u{001B}[36m"
private let dim    = "\u{001B}[2m"

func printDeviceInfo(_ info: DeviceBatteryInfo) {
    print("\(bold)\(cyan)\(info.deviceName)\(reset) \(dim)(\(info.productType))\(reset)")
    printRow("Battery Health", value: info.healthPercent.map { formatBar($0, colored: true) } ?? "N/A")
    printRow("Cycle Count",    value: info.cycleCount.map { "\($0)" } ?? "N/A")
    printRow("Current Charge", value: info.currentCharge.map { formatBar($0, colored: false) } ?? "N/A")
    printRow("Charging",       value: chargingLabel(info))
    print()
}

// MARK: - Helpers

private func printRow(_ label: String, value: String) {
    let padded = label.padding(toLength: 16, withPad: " ", startingAt: 0)
    print("  \(dim)\(padded)\(reset)  \(value)")
}

private func formatBar(_ percent: Int, colored: Bool) -> String {
    let clamped = max(0, min(100, percent))
    let filled = clamped / 10
    let empty  = 10 - filled
    let bar = String(repeating: "█", count: filled) + String(repeating: "░", count: empty)

    if colored {
        let color = clamped >= 80 ? green : clamped >= 60 ? yellow : red
        return "\(color)\(percent)%\(reset)  \(color)\(bar)\(reset)"
    } else {
        return "\(percent)%  \(bar)"
    }
}

private func chargingLabel(_ info: DeviceBatteryInfo) -> String {
    switch (info.isCharging, info.isPluggedIn) {
    case (true, _):       return "\(green)Yes\(reset)"
    case (false, true):   return "No \(dim)(plugged in, full)\(reset)"
    case (false, false):  return "No"
    default:              return "N/A"
    }
}
