import Vapor
import NIO
import NIOOpenSSL

public enum SmtpSecureChannel {
    case none
    case ssl

    internal func configureChannel(on channel: Channel, hostname: String) -> Future<Void> {
        switch self {
        case .ssl:
            do {
                let sslContext = try SSLContext(configuration: .forClient())
                let sslHandler = try OpenSSLClientHandler(context: sslContext, serverHostname: hostname)
                return channel.pipeline.add(handler: sslHandler)
            } catch {
                return Future.done(on: channel.eventLoop)
            }
        default:
            return Future.done(on: channel.eventLoop)
        }
    }
}
