import Foundation
import NIO

public struct Email {
    public let from: EmailAddress
    public let to: EmailAddress
    public let cc: [String]?
    public let bcc: [String]?
    public let subject: String
    public let body: String
    public let isBodyHtml: Bool
    internal var attachments: [Attachment] = []

    public init(from: EmailAddress,
                to: EmailAddress,
                cc: [String]? = nil,
                bcc: [String]? = nil,
                subject: String,
                body: String,
                isBodyHtml: Bool = false
    ) {
        self.from = from
        self.to = to
        self.cc = cc
        self.bcc = bcc
        self.subject = subject
        self.body = body
        self.isBodyHtml = isBodyHtml
    }

    public mutating func addAttachment(_ attachment: Attachment) {
        self.attachments.append(attachment)
    }
}

extension Email {
    internal func write(to out: inout ByteBuffer) {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")

        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        let dateFormatted = dateFormatter.string(from: date)

        out.write(string: "From: \(self.formatMIME(emailAddress: self.from))\r\n")
        out.write(string: "To: \(self.formatMIME(emailAddress: self.to))\r\n")
        out.write(string: "Subject: \(self.subject)\r\n")
        out.write(string: "Date: \(dateFormatted)\r\n")
        out.write(string: "Message-ID: <\(date.timeIntervalSince1970)\(self.from.address.drop { $0 != "@" })>\r\n")

        let boundary = self.boundary()
        if self.attachments.count > 0 {
            out.write(string: "Content-type: multipart/mixed; boundary=\"\(boundary)\"\r\n")
            out.write(string: "Mime-Version: 1.0\r\n\r\n")
        } else if self.isBodyHtml {
            out.write(string: "Content-Type: text/html; charset=\"UTF-8\"\r\n")
            out.write(string: "Mime-Version: 1.0\r\n\r\n")
        } else {
            out.write(string: "Content-Type: text/plain; charset=\"UTF-8\"\r\n")
            out.write(string: "Mime-Version: 1.0\r\n\r\n")
        }

        if self.attachments.count > 0 {

            if self.isBodyHtml {
                out.write(string: "--\(boundary)\r\n")
                out.write(string: "Content-Type: text/html; charset=\"UTF-8\"\r\n\r\n")
                out.write(string: "\(self.body)\r\n")
                out.write(string: "--\(boundary)\r\n")
            } else {
                out.write(string: "--\(boundary)\r\n\r\n")
                out.write(string: "\(self.body)\r\n")
                out.write(string: "--\(boundary)\r\n")
            }

            for attachment in self.attachments {
                out.write(string: "Content-type: \(attachment.contentType)\r\n")
                out.write(string: "Content-Transfer-Encoding: base64\r\n")
                out.write(string: "Content-Disposition: attachment; filename=\"\(attachment.name)\"\r\n\r\n")
                out.write(string: "\(attachment.data.base64EncodedString())\r\n")
                out.write(string: "--\(boundary)\r\n")
            }

        } else {
            out.write(string: self.body)
        }

        out.write(string: "\r\n.")
    }

    private func boundary() -> String {
        return UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
    }

    func formatMIME(emailAddress: EmailAddress) -> String {
        if let name = emailAddress.name {
            return "\(name) <\(emailAddress.address)>"
        } else {
            return emailAddress.address
        }
    }
}
