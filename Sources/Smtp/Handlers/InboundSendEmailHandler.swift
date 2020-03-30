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

    func send(context: ChannelHandlerContext, command: SmtpRequest) {
        context.writeAndFlush(self.wrapOutboundOut(command)).cascadeFailure(to: self.allDonePromise)
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
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
            self.send(context: context, command: .sayHello(serverName: self.serverConfiguration.hostname))
            self.currentlyWaitingFor = .okAfterHello
        case .okAfterHello:

            if self.shouldInitializeTls() {
                self.send(context: context, command: .startTls)
                self.currentlyWaitingFor = .okAfterStartTls
            } else {
                self.send(context: context, command: .beginAuthentication)
                self.currentlyWaitingFor = .okAfterAuthBegin
            }

        case .okAfterStartTls:
            self.send(context: context, command: .beginAuthentication)
            self.currentlyWaitingFor = .okAfterAuthBegin
        case .okAfterAuthBegin:
            self.send(context: context, command: .authUser(self.serverConfiguration.username))
            self.currentlyWaitingFor = .okAfterUsername
        case .okAfterUsername:
            self.send(context: context, command: .authPassword(self.serverConfiguration.password))
            self.currentlyWaitingFor = .okAfterPassword
        case .okAfterPassword:
            self.send(context: context, command: .mailFrom(self.email.from.address))
            self.currentlyWaitingFor = .okAfterMailFrom
        case .okAfterMailFrom:
            if let recipient = self.recipients.popLast() {
                self.send(context: context, command: .recipient(recipient.address))
            } else {
                fallthrough
            }
        case .okAfterRecipient:
            self.send(context: context, command: .data)
            self.currentlyWaitingFor = .okAfterDataCommand
        case .okAfterDataCommand:
            self.send(context: context, command: .transferData(email))
            self.currentlyWaitingFor = .okAfterMailData
        case .okAfterMailData:
            self.send(context: context, command: .quit)
            self.currentlyWaitingFor = .okAfterQuit
        case .okAfterQuit:
            self.allDonePromise.succeed(())
            self.currentlyWaitingFor = .nothing
        case .nothing:
            () // ignoring more data whilst quit (it's odd though)
        case .error:
            self.allDonePromise.fail(SmtpError("Communication error state"))
        }
    }

    private func shouldInitializeTls() -> Bool {
        return self.serverConfiguration.secure == .startTls || self.serverConfiguration.secure == .startTlsWhenAvailable
    }
}
