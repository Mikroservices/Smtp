import Foundation
import NIO
import NIOSSL
import Vapor

/// This is simple implementation of SMTP client service.
/// The implementation was based on Apple SwiftNIO.
///
/// # Usage
///
/// **Using SMTP client**
///
///```swift
/// let configuration = SmtpServerConfiguration(hostname: "smtp.server",
///                                             port: 465,
///                                             username: "johndoe",
///                                             password: "passw0rd",
///                                             secure: .ssl)
///
/// let email = Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
///                   to: [EmailAddress("ben.doe@testxx.com")],
///                   subject: "The subject (text)",
///                   body: "This is email body.")
///
/// request.send(email, configuration: configuration).map { result in
///     switch result {
///     case .success:
///         print("Email has been sent")
///     case .failure(let error):
///         print("Email has not been sent: \(error)")
///     }
/// }
///```
///
/// Channel pipeline:
///
/// ```
/// +-------------------------------------------------------------------+
/// |                                                                   |
/// |       [ Socket.read ]                    [ Socket.write ]         |
/// |              |                                  |                 |
/// +--------------+----------------------------------+-----------------+
///                |                                 /|\
///               \|/                                 |
///          +-----+----------------------------------+-----+
///          |    OpenSSLClientHandler (enabled/disabled)   |
///          +-----+----------------------------------+-----+
///                |                                 /|\
///               \|/                                 |
///          +-----+----------------------------------+-----+
///          |             DuplexMessagesHandler            |
///          +-----+----------------------------------+-----+
///                |                                 /|\
///               \|/                                 |
///          +-----+--------------------------+       |
///          |  InboundLineBasedFrameDecoder  |       |
///          +-----+--------------------------+       |
///                |                                  |
///               \|/                                 |
///          +-----+--------------------------+       |
///          |   InboundSmtpResponseDecoder   |       |
///          +-----+--------------------------+       |
///                |                                  |
///                |                                  |
///                |       +--------------------------+-----+
///                |       |  OutboundSmtpRequestEncoder    |
///                |       +--------------------------+-----+
///                |                                 /|\
///               \|/                                 |
///          +-----+----------------------------------+-----+
///          |               StartTlsHandler                |
///          +-----+----------------------------------+-----+
///                |                                 /|\
///                |                                  |
///               \|/                                 | [write]
///          +-----+--------------------------+       |
///          |   InboundSendEmailHandler      +-------+
///          +--------------------------------+
///```
/// `OpenSSLClientHandler` is enabled only when `.ssl` secure is defined. For `.none` that
/// handler is not added to the pipeline.
///
/// `StartTlsHandler` is responsible for establishing SSL encryption after `STARTTLS`
/// command (this handler adds dynamically `OpenSSLClientHandler` to the pipeline if
/// server supports that encryption.
public extension Request {

    /// Sending an email.
    ///
    /// - parameters:
    ///     - email: Email which will be send.
    ///     - configuration: Configuration of SMTP server.
    ///     - logHandler: Callback which can be used for logging/printing of sending status messages.
    /// - returns: An `Future<Result>` with information about sent email.
    func send(_ email: Email, configuration: SmtpServerConfiguration, logHandler: ((String) -> Void)? = nil) -> EventLoopFuture<Result<Bool, Error>> {
        let emailSentPromise: EventLoopPromise<Void> = self.eventLoop.makePromise()

        // Client configuration
        let bootstrap = ClientBootstrap(group: self.eventLoop)
            .connectTimeout(configuration.connectTimeout)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .channelInitializer { channel in

                let secureChannelFuture = configuration.secure.configureChannel(on: channel, hostname: configuration.hostname)
                return secureChannelFuture.flatMap {

                    let defaultHandlers: [ChannelHandler] = [
                        DuplexMessagesHandler(handler: logHandler),
                        ByteToMessageHandler(InboundLineBasedFrameDecoder()),
                        InboundSmtpResponseDecoder(),
                        MessageToByteHandler(OutboundSmtpRequestEncoder()),
                        StartTlsHandler(configuration: configuration, allDonePromise: emailSentPromise),
                        InboundSendEmailHandler(configuration: configuration,
                                                email: email,
                                                allDonePromise: emailSentPromise)
                    ]

                    return channel.pipeline.addHandlers(defaultHandlers, position: .last)
                }
            }

        // Connect and send email.
        let connection = bootstrap.connect(host: configuration.hostname, port: configuration.port)
        
        connection.cascadeFailure(to: emailSentPromise)
        
        return emailSentPromise.futureResult.map { () -> Result<Bool, Error> in
            connection.whenSuccess { $0.close(promise: nil) }
            return Result.success(true)
        }.flatMapError { error -> EventLoopFuture<Result<Bool, Error>> in
            return self.eventLoop.makeSucceededFuture(Result.failure(error))
        }
    }
}
