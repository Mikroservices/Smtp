import Foundation
import NIO

public struct Email {
    public let from: EmailAddress
    public let to: [EmailAddress]
    public let cc: [EmailAddress]?
    public let bcc: [EmailAddress]?
    public let subject: String
    public let body: String
    public let isBodyHtml: Bool
    public let replyTo: EmailAddress?
    internal var attachments: [Attachment] = []

    public init(from: EmailAddress,
                to: [EmailAddress],
                cc: [EmailAddress]? = nil,
                bcc: [EmailAddress]? = nil,
                subject: String,
                body: String,
                isBodyHtml: Bool = false,
                replyTo: EmailAddress? = nil
    ) {
        self.from = from
        self.to = to
        self.cc = cc
        self.bcc = bcc
        self.subject = subject
        self.body = body
        self.isBodyHtml = isBodyHtml
        self.replyTo = replyTo
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

        out.writeString("From: \(self.formatMIME(emailAddress: self.from))\r\n")

        let toAddresses = self.to.map { self.formatMIME(emailAddress: $0) }.joined(separator: ", ")
        out.writeString("To: \(toAddresses)\r\n")

        if let cc = self.cc {
            let ccAddresses = cc.map { self.formatMIME(emailAddress: $0) }.joined(separator: ", ")
            out.writeString("Cc: \(ccAddresses)\r\n")
        }

        if let replyTo = self.replyTo {
            out.writeString("Reply-to: \(self.formatMIME(emailAddress:replyTo))\r\n")
        }

        out.writeString("Subject: \(self.subject)\r\n")
        out.writeString("Date: \(dateFormatted)\r\n")
        out.writeString("Message-ID: <\(date.timeIntervalSince1970)\(self.from.address.drop { $0 != "@" })>\r\n")

        let boundary = self.boundary()
        if self.attachments.count > 0 {
            out.writeString("Content-type: multipart/mixed; boundary=\"\(boundary)\"\r\n")
            out.writeString("Mime-Version: 1.0\r\n\r\n")
        } else if self.isBodyHtml {
            out.writeString("Content-Type: text/html; charset=\"UTF-8\"\r\n")
            out.writeString("Mime-Version: 1.0\r\n\r\n")
        } else {
            out.writeString("Content-Type: text/plain; charset=\"UTF-8\"\r\n")
            out.writeString("Mime-Version: 1.0\r\n\r\n")
        }

        if self.attachments.count > 0 {

            if self.isBodyHtml {
                out.writeString("--\(boundary)\r\n")
                out.writeString("Content-Type: text/html; charset=\"UTF-8\"\r\n\r\n")
                out.writeString("\(self.body)\r\n")
                out.writeString("--\(boundary)\r\n")
            } else {
                out.writeString("--\(boundary)\r\n\r\n")
                out.writeString("\(self.body)\r\n")
                out.writeString("--\(boundary)\r\n")
            }

            for attachment in self.attachments {
                out.writeString("Content-type: \(attachment.contentType)\r\n")
                out.writeString("Content-Transfer-Encoding: base64\r\n")
                out.writeString("Content-Disposition: attachment; filename=\"\(attachment.name)\"\r\n\r\n")
                out.writeString("\(attachment.data.base64EncodedString())\r\n")
                out.writeString("--\(boundary)\r\n")
            }

        } else {
            out.writeString(self.body)
        }

        out.writeString("\r\n.")
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
