import Vapor
import NIO
import NIOSSL

public enum SmtpSecureChannel {

    /// Communication without any encryption (even password is send as a plain text).
    case none

    /// The connection should use SSL or TLS encryption immediately.
    case ssl

    /// Elevates the connection to use TLS encryption immediately after
    /// reading the greeting and capabilities of the server. If the server
    /// does not support the STARTTLS extension, then the connection will
    /// fail and error will be thrown.
    case startTls

    /// Elevates the connection to use TLS encryption immediately after
    /// reading the greeting and capabilities of the server, but only if
    /// the server supports the STARTTLS extension.
    case startTlsWhenAvailable

    internal func configureChannel(on channel: Channel, hostname: String) -> EventLoopFuture<Void> {
        switch self {
        case .ssl:
            do {
                let sslContext = try NIOSSLContext(configuration: .forClient())
                let sslHandler = try NIOSSLClientHandler(context: sslContext, serverHostname: hostname)
                return channel.pipeline.addHandler(sslHandler)
            } catch {
                return channel.eventLoop.makeSucceededFuture(())
            }
        default:
            return channel.eventLoop.makeSucceededFuture(())
        }
    }
}
