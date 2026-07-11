import Foundation

final class JiezhiCommandController {
    struct CommandError: LocalizedError {
        let executable: String
        let status: Int32
        let output: String

        var errorDescription: String? {
            let detail = output.trimmingCharacters(in: .whitespacesAndNewlines)
            return detail.isEmpty ? "命令执行失败（\(status)）" : "命令执行失败：\(detail)"
        }
    }

    private let queue = DispatchQueue(label: "com.puzige.Jiezhi.commands")

    func readDisabled(completion: @escaping (Bool) -> Void) {
        queue.async {
            let disabled: Bool
            do {
                let output = try Self.run(
                    executable: "/usr/bin/defaults",
                    arguments: ["-currentHost", "read", "com.apple.universalcontrol", "Disable"]
                )
                disabled = ["1", "true", "yes"].contains(
                    output.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                )
            } catch {
                disabled = false
            }
            DispatchQueue.main.async { completion(disabled) }
        }
    }

    func setDisabled(_ disabled: Bool, completion: @escaping (Result<Bool, Error>) -> Void) {
        queue.async {
            do {
                try Self.run(
                    executable: "/usr/bin/defaults",
                    arguments: [
                        "-currentHost", "write", "com.apple.universalcontrol", "Disable",
                        "-bool", disabled ? "true" : "false"
                    ]
                )
                try Self.run(executable: "/usr/bin/killall", arguments: ["UniversalControl"])
                DispatchQueue.main.async { completion(.success(disabled)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }

    @discardableResult
    private static func run(executable: String, arguments: [String]) throws -> String {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
        } catch {
            throw CommandError(executable: executable, status: -1, output: error.localizedDescription)
        }
        process.waitUntilExit()
        let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        guard process.terminationStatus == 0 else {
            throw CommandError(executable: executable, status: process.terminationStatus, output: output)
        }
        return output
    }
}
