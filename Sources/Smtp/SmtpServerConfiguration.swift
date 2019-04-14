import Vapor

public struct SmtpServerConfiguration: Service {
    var hostname: String
    var port: Int
    var username: String
    var password: String

    public init(hostname: String, port: Int, username: String, password: String) {
        self.hostname = hostname
        self.port = port
        self.username = username
        self.password = password
    }
}
