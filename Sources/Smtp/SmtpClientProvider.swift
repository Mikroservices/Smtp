import Vapor

public final class SmtpClientProvider: Provider {

    public func boot(_ config: Config) throws {}

    public func didBoot(_ worker: Container) throws -> EventLoopFuture<Void> {
        return .done(on: worker)
    }

    public func register(_ services: inout Services) throws {
        services.register { (container) -> SmtpClientService in
            let smtpServerConfiguration = try container.make(SmtpServerConfiguration.self)
            return SmtpClientService(configuration: smtpServerConfiguration)
        }
    }
}
