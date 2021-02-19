import NIO
import NIOSSL

internal final class InboundSendEmailHandler: ChannelInboundHandler {
    typealias InboundIn = SMTPResponse
    typealias OutboundOut = SMTPRequest

    enum Expect {
        case initialMessageFromServer
        case okAfterHello
        case okAfterStartTLS
        case okAfterStartTLSHello
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
    private let serverConfiguration: SMTPServerConfiguration
    private let allDonePromise: EventLoopPromise<Void>
    private var recipients: [EmailAddress]

    init(configuration: SMTPServerConfiguration, email: Email, allDonePromise: EventLoopPromise<Void>) {
        self.email = email
        self.allDonePromise = allDonePromise
        self.serverConfiguration = configuration

        self.recipients = self.email.to
        if let cc = self.email.cc {
            self.recipients += cc
        }
    }

    func send(context: ChannelHandlerContext, command: SMTPRequest) {
        context.writeAndFlush(self.wrapOutboundOut(command)).cascadeFailure(to: self.allDonePromise)
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let result = self.unwrapInboundIn(data)
        switch result {
        case .error(let message):
            self.allDonePromise.fail(SMTPError(message))
            return
        case .ok:
            () // cool
        }

        switch self.currentlyWaitingFor {
        case .initialMessageFromServer:
            self.send(context: context,
                      command: .sayHello(serverName: self.serverConfiguration.hostname,
                                         helloMethod: self.serverConfiguration.helloMethod
                )
            )
            self.currentlyWaitingFor = .okAfterHello
        case .okAfterHello:

            if self.shouldInitializeTLS() {
                self.send(context: context, command: .startTLS)
                self.currentlyWaitingFor = .okAfterStartTLS
            } else {
                self.send(context: context, command: .beginAuthentication)
                self.currentlyWaitingFor = .okAfterAuthBegin
            }

        case .okAfterStartTLS:
            self.send(context: context, command: .sayHelloAfterTLS(serverName: self.serverConfiguration.hostname, helloMethod:  self.serverConfiguration.helloMethod))
            self.currentlyWaitingFor = .okAfterStartTLSHello
        case .okAfterStartTLSHello:
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
            self.allDonePromise.fail(SMTPError("Communication error state"))
        }
    }

    private func shouldInitializeTLS() -> Bool {
        return self.serverConfiguration.secure == .startTLS || self.serverConfiguration.secure == .startTLSWhenAvailable
    }
}
