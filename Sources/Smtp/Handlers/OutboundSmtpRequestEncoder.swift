import NIO
import NIOFoundationCompat
import Foundation

internal final class OutboundSmtpRequestEncoder: MessageToByteEncoder {
    typealias OutboundIn = SmtpRequest

    func encode(data: SmtpRequest, out: inout ByteBuffer) throws {
        switch data {
        case .sayHello(serverName: let server):
            out.writeString("HELO \(server)")
        case .startTls:
            out.writeString("STARTTLS")
        case .mailFrom(let from):
            out.writeString("MAIL FROM:<\(from)>")
        case .recipient(let rcpt):
            out.writeString("RCPT TO:<\(rcpt)>")
        case .data:
            out.writeString("DATA")
        case .transferData(let email):
            email.write(to: &out)
        case .quit:
            out.writeString("QUIT")
        case .beginAuthentication:
            out.writeString("AUTH LOGIN")
        case .authUser(let user):
            let userData = Data(user.utf8)
            out.writeBytes(userData.base64EncodedData())
        case .authPassword(let password):
            let passwordData = Data(password.utf8)
            out.writeBytes(passwordData.base64EncodedData())
        }

        out.writeString("\r\n")
    }
}
