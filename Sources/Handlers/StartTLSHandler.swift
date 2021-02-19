import NIO
import NIOSSL

internal final class StartTLSHandler: ChannelDuplexHandler, RemovableChannelHandler {
    typealias InboundIn = SMTPResponse
    typealias InboundOut = SMTPResponse
    typealias OutboundIn = SMTPRequest
    typealias OutboundOut = SMTPRequest

    private let serverConfiguration: SMTPServerConfiguration
    private let allDonePromise: EventLoopPromise<Void>
    private var waitingForStartTLSResponse = false

    init(configuration: SMTPServerConfiguration, allDonePromise: EventLoopPromise<Void>) {
        self.serverConfiguration = configuration
        self.allDonePromise = allDonePromise
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {

        if self.startTLSDisabled() {
            context.fireChannelRead(data)
            return
        }

        if waitingForStartTLSResponse {
            self.waitingForStartTLSResponse = false

            let result = self.unwrapInboundIn(data)
            switch result {
            case .error(let message):
                if self.serverConfiguration.secure == .startTLS {
                    // Fail only if tls is required.
                    self.allDonePromise.fail(SMTPError(message))
                    return
                }

                // TLS is not required, we can continue without encryption.
                let startTLSResult = self.wrapInboundOut(.ok(200, "STARTTLS is not supported"))
                context.fireChannelRead(startTLSResult)
                return
            case .ok:
                self.initializeTLSHandler(context: context, data: data)
            }
        } else {
            context.fireChannelRead(data)
        }
    }

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {

        if self.startTLSDisabled() {
            context.write(data, promise: promise)
            return
        }

        let command = self.unwrapOutboundIn(data)
        switch command {
        case .startTLS:
            self.waitingForStartTLSResponse = true
        default:
            break
        }


        context.write(data, promise: promise)
    }

    private func initializeTLSHandler(context: ChannelHandlerContext, data: NIOAny) {
        do {
            let sslContext = try NIOSSLContext(configuration: .forClient())
            let sslHandler = try NIOSSLClientHandler(context: sslContext, serverHostname: self.serverConfiguration.hostname)
            _ = context.channel.pipeline.addHandler(sslHandler, name: "NIOSSLClientHandler", position: .first)

            context.fireChannelRead(data)
            _ = context.channel.pipeline.removeHandler(self)
        } catch let error {
            self.allDonePromise.fail(error)
        }
    }

    private func startTLSDisabled() -> Bool {
        return self.serverConfiguration.secure != .startTLS && self.serverConfiguration.secure != .startTLSWhenAvailable
    }
}
