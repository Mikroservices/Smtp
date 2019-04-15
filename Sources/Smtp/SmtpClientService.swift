import Foundation
import NIO
import NIOOpenSSL
import Vapor

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
