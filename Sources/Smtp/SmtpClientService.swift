import Foundation
import NIO
import NIOOpenSSL
import Vapor

public class SmtpClientService: Service {

    let connectTimeout: TimeAmount = TimeAmount.seconds(10)
    let smtpServerConfiguration: SmtpServerConfiguration

    public init(configuration smtpServerConfiguration: SmtpServerConfiguration) {
        self.smtpServerConfiguration = smtpServerConfiguration
    }

    public func send(_ email: Email, on worker: Worker, logHandler: ((String) -> Void)? = nil) throws -> Future<Result<Bool, Error>> {

        let emailSentPromise: EventLoopPromise<Void> = worker.eventLoop.newPromise()

        // Client configuration
        let bootstrap = ClientBootstrap(group: worker.eventLoop)
            .connectTimeout(self.connectTimeout)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .channelInitializer { channel in

                return self.smtpServerConfiguration.secure.configureChannel(on: channel,
                                                                            hostname: self.smtpServerConfiguration.hostname).then {

                    let defaultHandlers: [ChannelHandler] = [
                        DuplexMessagesHandler(handler: logHandler),
                        InboundLineBasedFrameDecoder(),
                        InboundSmtpResponseDecoder(),
                        OutboundSmtpRequestEncoder(),
                        InboundSendEmailHandler(configuration: self.smtpServerConfiguration,
                                                email: email,
                                                allDonePromise: emailSentPromise)
                    ]

                    return channel.pipeline.addHandlers(defaultHandlers, first: false)
                }
            }

        // Connect and send email.
        let connection = bootstrap.connect(host: smtpServerConfiguration.hostname,
                                           port: smtpServerConfiguration.port)

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
