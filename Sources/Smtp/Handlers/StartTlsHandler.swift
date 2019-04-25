import NIO
import NIOOpenSSL

internal final class StartTlsHandler: ChannelDuplexHandler {
    typealias InboundIn = SmtpResponse
    typealias InboundOut = SmtpResponse
    typealias OutboundIn = SmtpRequest
    typealias OutboundOut = SmtpRequest

    private let serverConfiguration: SmtpServerConfiguration
    private let allDonePromise: EventLoopPromise<Void>
    private var waitingForStartTlsResponse = false

    init(configuration: SmtpServerConfiguration, allDonePromise: EventLoopPromise<Void>) {
        self.serverConfiguration = configuration
        self.allDonePromise = allDonePromise
    }

    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {

        if self.startTlsDisabled() {
            ctx.fireChannelRead(data)
            return
        }

        if waitingForStartTlsResponse {
            self.waitingForStartTlsResponse = false

            let result = self.unwrapInboundIn(data)
            switch result {
            case .error(let message):
                if self.serverConfiguration.secure == .startTls {
                    // Fail only if tls is required.
                    self.allDonePromise.fail(error: SmtpError(message))
                    return
                }

                // Tls is not required, we can continue without encryption.
                let startTlsResult = self.wrapInboundOut(.ok(200, "STARTTLS is not supported"))
                ctx.fireChannelRead(startTlsResult)
                return
            case .ok:
                self.initializeTlsHandler(ctx: ctx, data: data)
            }
        } else {
            ctx.fireChannelRead(data)
        }
    }

    func write(ctx: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {

        if self.startTlsDisabled() {
            ctx.write(data, promise: promise)
            return
        }

        let command = self.unwrapOutboundIn(data)
        switch command {
        case .startTls:
            self.waitingForStartTlsResponse = true
        default:
            break
        }


        ctx.write(data, promise: promise)
    }

    private func initializeTlsHandler(ctx: ChannelHandlerContext, data: NIOAny) {
        do {
            let sslContext = try SSLContext(configuration: .forClient())
            let sslHandler = try OpenSSLClientHandler(context: sslContext, serverHostname: self.serverConfiguration.hostname)
            _ = ctx.channel.pipeline.addHandlers(sslHandler, first: true)

            ctx.fireChannelRead(data)
            _ = ctx.channel.pipeline.remove(handler: self)
        } catch let error {
            self.allDonePromise.fail(error: error)
        }
    }

    private func startTlsDisabled() -> Bool {
        return self.serverConfiguration.secure != .startTls && self.serverConfiguration.secure != .startTlsWhenAvailable
    }
}
