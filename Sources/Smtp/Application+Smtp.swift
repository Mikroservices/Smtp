import Vapor

extension Application {
    public var smtp: Smtp {
        .init(application: self)
    }

    public struct Smtp {
        let application: Application

        struct ConfigurationKey: StorageKey {
            typealias Value = SmtpServerConfiguration
        }

        public var configuration: SmtpServerConfiguration {
            get {
                self.application.storage[ConfigurationKey.self] ?? .init()
            }
            nonmutating set {
                self.application.storage[ConfigurationKey.self] = newValue
            }
        }
    }
}
