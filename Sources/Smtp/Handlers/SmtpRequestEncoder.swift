import NIO
import NIOFoundationCompat
import Foundation

internal final class SmtpRequestEncoder: MessageToByteEncoder {
    typealias OutboundIn = SmtpRequest

    func encode(ctx: ChannelHandlerContext, data: SmtpRequest, out: inout ByteBuffer) throws {
        switch data {
        case .sayHello(serverName: let server):
            out.write(string: "HELO \(server)")
        case .mailFrom(let from):
            out.write(string: "MAIL FROM:<\(from)>")
        case .recipient(let rcpt):
            out.write(string: "RCPT TO:<\(rcpt)>")
        case .data:
            out.write(string: "DATA")
        case .transferData(let email):
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US")

            dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
            let dateFormatted = dateFormatter.string(from: date)

            out.write(string: "From: \(formatMIME(emailAddress: email.from, name: email.fromName ?? email.from))\r\n")
            out.write(string: "To: \(formatMIME(emailAddress: email.to, name: email.toName ?? email.to))\r\n")
            out.write(string: "Date: \(dateFormatted)\r\n")
            out.write(string: "Message-ID: <\(date.timeIntervalSince1970)\(email.from.drop { $0 != "@" })>\r\n")

            if email.isBodyHtml {
                out.write(string: "Content-Type: text/html; charset=\"UTF-8\"\r\n")
                out.write(string: "Mime-Version: 1.0\r\n")
            }

            out.write(string: "Subject: \(email.subject)\r\n\r\n")
            out.write(string: email.body)
            out.write(string: "\r\n.")
        case .quit:
            out.write(string: "QUIT")
        case .beginAuthentication:
            out.write(string: "AUTH LOGIN")
        case .authUser(let user):
            let userData = Data(user.utf8)
            out.write(bytes: userData.base64EncodedData())
        case .authPassword(let password):
            let passwordData = Data(password.utf8)
            out.write(bytes: passwordData.base64EncodedData())
        }

        out.write(string: "\r\n")
    }

    func formatMIME(emailAddress: String, name: String?) -> String {
        if let name = name {
            return "\(name) <\(emailAddress)>"
        } else {
            return emailAddress
        }
    }
}
