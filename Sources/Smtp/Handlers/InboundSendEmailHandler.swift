import NIO
import NIOSSL

internal final class InboundSendEmailHandler: ChannelInboundHandler {
    typealias InboundIn = SmtpResponse
    typealias OutboundOut = SmtpRequest

    enum Expect {
        case initialMessageFromServer
        case okAfterHello
        case okAfterStartTls
        case okAfterAuthBegin
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
    private var recipients: [EmailAddress]

    init(configuration: SmtpServerConfiguration, email: Email, allDonePromise: EventLoopPromise<Void>) {
        self.email = email
        self.allDonePromise = allDonePromise
        self.serverConfiguration = configuration

        self.recipients = self.email.to
        if let cc = self.email.cc {
            self.recipients += cc
        }
    }

    func send(ctx: ChannelHandlerContext, command: SmtpRequest) {
        ctx.writeAndFlush(self.wrapOutboundOut(command)).cascadeFailure(to: self.allDonePromise)
    }

    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let result = self.unwrapInboundIn(data)
        switch result {
        case .error(let message):
            self.allDonePromise.fail(SmtpError(message))
            return
        case .ok:
            () // cool
        }

        switch self.currentlyWaitingFor {
        case .initialMessageFromServer:
            self.send(ctx: ctx, command: .sayHello(serverName: self.serverConfiguration.hostname))
            self.currentlyWaitingFor = .okAfterHello
        case .okAfterHello:

            if self.shouldInitializeTls() {
                self.send(ctx: ctx, command: .startTls)
                self.currentlyWaitingFor = .okAfterStartTls
            } else {
                self.send(ctx: ctx, command: .beginAuthentication)
                self.currentlyWaitingFor = .okAfterAuthBegin
            }

        case .okAfterStartTls:
            self.send(ctx: ctx, command: .beginAuthentication)
            self.currentlyWaitingFor = .okAfterAuthBegin
        case .okAfterAuthBegin:
            self.send(ctx: ctx, command: .authUser(self.serverConfiguration.username))
            self.currentlyWaitingFor = .okAfterUsername
        case .okAfterUsername:
            self.send(ctx: ctx, command: .authPassword(self.serverConfiguration.password))
            self.currentlyWaitingFor = .okAfterPassword
        case .okAfterPassword:
            self.send(ctx: ctx, command: .mailFrom(self.email.from.address))
            self.currentlyWaitingFor = .okAfterMailFrom
        case .okAfterMailFrom:
            if let recipient = self.recipients.popLast() {
                self.send(ctx: ctx, command: .recipient(recipient.address))
            } else {
                fallthrough
            }
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
            self.allDonePromise.succeed(())
            self.currentlyWaitingFor = .nothing
        case .nothing:
            () // ignoring more data whilst quit (it's odd though)
        case .error:
            fatalError("error state")
        }
    }

    private func shouldInitializeTls() -> Bool {
        return self.serverConfiguration.secure == .startTls || self.serverConfiguration.secure == .startTlsWhenAvailable
    }
}
