import Foundation

struct ProcessResult: Sendable {
    let output: String
    let error: String
    let status: Int32
}

enum ProcessRunnerError: LocalizedError {
    case failed(String)

    var errorDescription: String? {
        switch self {
        case .failed(let message):
            return message
        }
    }
}

enum ProcessRunner {
    static func run(
        executable: String,
        arguments: [String],
        requireSuccess: Bool = true
    ) throws -> ProcessResult {
        let process = Process()
        let stdout = Pipe()
        let stderr = Pipe()

        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.standardOutput = stdout
        process.standardError = stderr

        try process.run()
        process.waitUntilExit()

        let output = String(
            data: stdout.fileHandleForReading.readDataToEndOfFile(),
            encoding: .utf8
        ) ?? ""

        let error = String(
            data: stderr.fileHandleForReading.readDataToEndOfFile(),
            encoding: .utf8
        ) ?? ""

        let result = ProcessResult(
            output: output,
            error: error,
            status: process.terminationStatus
        )

        if requireSuccess && result.status != 0 {
            let message = result.error.trimmingCharacters(in: .whitespacesAndNewlines)
            throw ProcessRunnerError.failed(message.isEmpty ? "Command failed with exit code \(result.status)." : message)
        }

        return result
    }
}
