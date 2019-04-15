import Vapor

public struct SmtpServerConfiguration: Service {
    var hostname: String
    var port: Int
    var username: String
    var password: String
    var secure: SmtpSecureChannel

    public init(hostname: String, port: Int, username: String, password: String, secure: SmtpSecureChannel = .none) {
        self.hostname = hostname
        self.port = port
        self.username = username
        self.password = password
        self.secure = secure
    }
}
