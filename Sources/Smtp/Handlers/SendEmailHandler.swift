import NIO
import NIOOpenSSL

internal final class SendEmailHandler: ChannelInboundHandler {
    typealias InboundIn = SmtpResponse
    typealias OutboundIn = Email
    typealias OutboundOut = SmtpRequest

    enum Expect {
        case initialMessageFromServer
        case okForOurHello
        case okForOurStartTLS
        case okForOurAuthBegin
        case okAfterUsername
        case okAfterPassword
        case okAfterMailFrom
        case okAfterRecipient
        case okAfterDataCommand
        case okAfterMailData
        case okAfterQuit
        case nothing

        case error
    }

    private var currentlyWaitingFor = Expect.initialMessageFromServer
    private let email: Email
    private let serverConfiguration: SmtpServerConfiguration
    private let allDonePromise: EventLoopPromise<Void>

    init(configuration: SmtpServerConfiguration, email: Email, allDonePromise: EventLoopPromise<Void>) {
        self.email = email
        self.allDonePromise = allDonePromise
        self.serverConfiguration = configuration
    }

    func send(ctx: ChannelHandlerContext, command: SmtpRequest) {
        ctx.writeAndFlush(self.wrapOutboundOut(command)).cascadeFailure(promise: self.allDonePromise)
    }

    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let result = self.unwrapInboundIn(data)
        switch result {
        case .error(let message):
            self.allDonePromise.fail(error: SmtpError(message))
            return
        case .ok:
            () // cool
        }

        switch self.currentlyWaitingFor {
        case .initialMessageFromServer:
            self.send(ctx: ctx, command: .sayHello(serverName: self.serverConfiguration.hostname))
            self.currentlyWaitingFor = .okForOurHello
        case .okForOurHello:
            self.send(ctx: ctx, command: .beginAuthentication)
            self.currentlyWaitingFor = .okForOurAuthBegin
        case .okForOurStartTLS:
            self.send(ctx: ctx, command: .beginAuthentication)
            self.currentlyWaitingFor = .okForOurAuthBegin
        case .okForOurAuthBegin:
            self.send(ctx: ctx, command: .authUser(self.serverConfiguration.username))
            self.currentlyWaitingFor = .okAfterUsername
        case .okAfterUsername:
            self.send(ctx: ctx, command: .authPassword(self.serverConfiguration.password))
            self.currentlyWaitingFor = .okAfterPassword
        case .okAfterPassword:
            self.send(ctx: ctx, command: .mailFrom(self.email.from))
            self.currentlyWaitingFor = .okAfterMailFrom
        case .okAfterMailFrom:
            self.send(ctx: ctx, command: .recipient(self.email.to))
            self.currentlyWaitingFor = .okAfterRecipient
        case .okAfterRecipient:
            self.send(ctx: ctx, command: .data)
            self.currentlyWaitingFor = .okAfterDataCommand
        case .okAfterDataCommand:
            self.send(ctx: ctx, command: .transferData(email))
            self.currentlyWaitingFor = .okAfterMailData
        case .okAfterMailData:
            self.send(ctx: ctx, command: .quit)
            self.currentlyWaitingFor = .okAfterQuit
        case .okAfterQuit:
            ctx.close(promise: self.allDonePromise)
            self.currentlyWaitingFor = .nothing
        case .nothing:
            () // ignoring more data whilst quit (it's odd though)
        case .error:
            fatalError("error state")
        }
    }
}
