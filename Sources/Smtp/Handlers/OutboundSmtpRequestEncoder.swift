import NIO
import NIOFoundationCompat
import Foundation

internal final class OutboundSmtpRequestEncoder: MessageToByteEncoder {
    typealias OutboundIn = SmtpRequest

    func encode(ctx: ChannelHandlerContext, data: SmtpRequest, out: inout ByteBuffer) throws {
        switch data {
        case .sayHello(serverName: let server):
            out.write(string: "HELO \(server)")
        case .startTLS:
            out.write(string: "STARTTLS")
        case .mailFrom(let from):
            out.write(string: "MAIL FROM:<\(from)>")
        case .recipient(let rcpt):
            out.write(string: "RCPT TO:<\(rcpt)>")
        case .data:
            out.write(string: "DATA")
        case .transferData(let email):
            email.write(to: &out)
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
}
