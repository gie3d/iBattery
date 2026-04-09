import Foundation

struct DeviceBatteryInfo {
    let udid: String
    let deviceName: String
    let productType: String
    let healthPercent: Int?
    let cycleCount: Int?
    let currentCharge: Int?
    let isCharging: Bool?
    let isPluggedIn: Bool?
}

func fetchBatteryInfo(udid: String, ideviceinfo: String, idevicediagnostics: String) -> DeviceBatteryInfo {
    let deviceName = run(ideviceinfo, args: ["-u", udid, "-k", "DeviceName"]) ?? "Unknown"
    let productType = run(ideviceinfo, args: ["-u", udid, "-k", "ProductType"]) ?? "Unknown"

    // Basic battery info (key: value format)
    var currentCharge: Int?
    var isCharging: Bool?
    var isPluggedIn: Bool?

    if let basicOutput = run(ideviceinfo, args: ["-u", udid, "-q", "com.apple.mobile.battery"]) {
        let kvPairs = parseKeyValue(basicOutput)
        currentCharge = kvPairs["BatteryCurrentCapacity"].flatMap { Int($0) }
        isCharging = kvPairs["BatteryIsCharging"].map { $0.lowercased() == "true" }
        isPluggedIn = kvPairs["ExternalConnected"].map { $0.lowercased() == "true" }
    }

    // Battery health and cycle count from diagnostics
    var healthPercent: Int?
    var cycleCount: Int?

    let entries = ["AppleSmartBattery", "AppleARMPMUCharger"]
    for entry in entries {
        if let diagOutput = run(idevicediagnostics, args: ["-u", udid, "ioregentry", entry]),
           let dict = parsePlist(diagOutput) {
            cycleCount = dict["CycleCount"] as? Int
            if let rawMax = dict["AppleRawMaxCapacity"] as? Int,
               let design = dict["DesignCapacity"] as? Int,
               design > 0 {
                healthPercent = Int(Double(rawMax) / Double(design) * 100)
            }
            if healthPercent != nil || cycleCount != nil { break }
        }
    }

    return DeviceBatteryInfo(
        udid: udid,
        deviceName: deviceName,
        productType: productType,
        healthPercent: healthPercent,
        cycleCount: cycleCount,
        currentCharge: currentCharge,
        isCharging: isCharging,
        isPluggedIn: isPluggedIn
    )
}

// MARK: - Parsing helpers

private func parseKeyValue(_ output: String) -> [String: String] {
    var result: [String: String] = [:]
    for line in output.split(separator: "\n", omittingEmptySubsequences: true) {
        let parts = line.split(separator: ":", maxSplits: 1)
        guard parts.count == 2 else { continue }
        let key = parts[0].trimmingCharacters(in: .whitespaces)
        let value = parts[1].trimmingCharacters(in: .whitespaces)
        result[key] = value
    }
    return result
}

private func parsePlist(_ output: String) -> [String: Any]? {
    // idevicediagnostics wraps the entry in a top-level dict like:
    // { "AppleSmartBattery": { ... } }
    // We want the inner dictionary.
    guard let data = output.data(using: .utf8),
          let top = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
    else { return nil }

    // Return the first nested dictionary found
    for (_, value) in top {
        if let inner = value as? [String: Any] { return inner }
    }
    return top
}
