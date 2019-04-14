import Foundation

struct SmtpError: Error {
    let message: String

    init(_ message: String) {
        self.message = message
    }
}
