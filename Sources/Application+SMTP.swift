import Vapor

extension Application {
    public var smtp: SMTP {
        .init(application: self)
    }

    public struct SMTP {
        let application: Application

        struct ConfigurationKey: StorageKey {
            typealias Value = SMTPServerConfiguration
        }

        public var configuration: SMTPServerConfiguration {
            get {
                self.application.storage[ConfigurationKey.self] ?? .init()
            }
            nonmutating set {
                self.application.storage[ConfigurationKey.self] = newValue
            }
        }
    }
}
