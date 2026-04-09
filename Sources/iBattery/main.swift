import Foundation

// MARK: - Tool availability check

guard let ideviceId      = which("idevice_id"),
      let ideviceinfo    = which("ideviceinfo"),
      let idevicediag    = which("idevicediagnostics") else {
    fputs("""
    Error: libimobiledevice tools not found.
    Install with:  brew install libimobiledevice
    """, stderr)
    exit(1)
}

// MARK: - Device discovery

guard let rawUdids = run(ideviceId, args: ["-l"]), !rawUdids.isEmpty else {
    print("No devices connected.")
    print("Connect an iPhone or iPad via USB and trust this Mac.")
    exit(0)
}

let udids = rawUdids
    .split(separator: "\n", omittingEmptySubsequences: true)
    .map(String.init)

print()

for udid in udids {
    let info = fetchBatteryInfo(udid: udid, ideviceinfo: ideviceinfo, idevicediagnostics: idevicediag)
    printDeviceInfo(info)
}
