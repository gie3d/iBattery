import Foundation

func run(_ executable: String, args: [String]) -> String? {
    let process = Process()
    let pipe = Pipe()

    process.executableURL = URL(fileURLWithPath: executable)
    process.arguments = args
    process.standardOutput = pipe
    process.standardError = Pipe() // suppress stderr

    do {
        try process.run()
        process.waitUntilExit()
    } catch {
        return nil
    }

    guard process.terminationStatus == 0 else { return nil }

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
}

/// Locate a tool in common Homebrew paths and /usr/bin.
func which(_ name: String) -> String? {
    let candidates = [
        "/opt/homebrew/bin/\(name)",
        "/usr/local/bin/\(name)",
        "/usr/bin/\(name)"
    ]
    return candidates.first { FileManager.default.isExecutableFile(atPath: $0) }
}
