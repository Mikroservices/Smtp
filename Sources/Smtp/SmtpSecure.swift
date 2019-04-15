import Vapor
import NIO
import NIOOpenSSL

public enum SmtpSecureChannel {

    /// Communication withiut any encryption (even password is send as a plain text).
    case none

    /// Communication over SSL.
    case ssl

    // SMTP Service Extension for Secure SMTP over Transport Layer Security: https://tools.ietf.org/html/rfc3207
    // case tls

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
