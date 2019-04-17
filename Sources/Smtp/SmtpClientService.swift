import Foundation
import NIO
import NIOOpenSSL
import Vapor

/// This is simple implementation of SMTP client service.
/// The implementation was based on Apple SwiftNIO.
///
/// # Usage
///
/// **Register in Vapor**
///
///```swift
/// let configuration = SmtpServerConfiguration(hostname: "smtp.server",
///                                             port: 465,
///                                             username: "johndoe",
///                                             password: "passw0rd",
///                                             secure: .ssl)
///
/// services.register(configuration)
/// try services.register(SmtpClientProvider())
///```
///
/// **Using SMTP client**
///
///```swift
/// let smtpClientService = try app.make(SmtpClientService.self)
///
/// let email = Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
///                   to: [EmailAddress("ben.doe@testxx.com")],
///                   subject: "The subject (text)",
///                   body: "This is email body.")
///
/// smtpClientService.send(email, on: request).map { result in
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
///                |                                  |
///               \|/                                 | [write]
///          +-----+--------------------------+       |
///          |   InboundSendEmailHandler      +-------+
///          +--------------------------------+
///```
/// `OpenSSLClientHandler` is enabled only when `.ssl` secure is defined. For `.none` that
/// handler is not added to the pipeline.
public class SmtpClientService: Service {

    let connectTimeout: TimeAmount = TimeAmount.seconds(10)
    let configuration: SmtpServerConfiguration

    /// Initialization of client.
    ///
    /// - parameters:
    ///     - configuration: Email SMTP server configuration.
    public init(configuration: SmtpServerConfiguration) {
        self.configuration = configuration
    }

    /// Sending an email.
    ///
    /// - parameters:
    ///     - email: Email which will be send.
    ///     - worker: EventLoop which will be used to send email.
    /// - returns: An `Future<Result>` with information about sent email.
    public func send(_ email: Email, on worker: Worker, logHandler: ((String) -> Void)? = nil) -> Future<Result<Bool, Error>> {

        let emailSentPromise: EventLoopPromise<Void> = worker.eventLoop.newPromise()

        // Client configuration
        let bootstrap = ClientBootstrap(group: worker.eventLoop)
            .connectTimeout(self.connectTimeout)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .channelInitializer { channel in

                let secureChannelFuture = self.configuration.secure.configureChannel(on: channel, hostname: self.configuration.hostname)
                return secureChannelFuture.then {

                    let defaultHandlers: [ChannelHandler] = [
                        DuplexMessagesHandler(handler: logHandler),
                        InboundLineBasedFrameDecoder(),
                        InboundSmtpResponseDecoder(),
                        OutboundSmtpRequestEncoder(),
                        InboundSendEmailHandler(configuration: self.configuration,
                                                email: email,
                                                allDonePromise: emailSentPromise)
                    ]

                    return channel.pipeline.addHandlers(defaultHandlers, first: false)
                }
            }

        // Connect and send email.
        let connection = bootstrap.connect(host: configuration.hostname, port: configuration.port)

        connection.cascadeFailure(promise: emailSentPromise)

        return emailSentPromise.futureResult.map {
            connection.whenSuccess { $0.close(promise: nil) }
            return Result.success(true)
        }.catchMap { error -> Result<Bool, Error> in
            connection.whenSuccess { $0.close(promise: nil) }
            return Result.failure(error)
        }
    }
}
