import NIO
import Vapor

public struct SmtpServerConfiguration {
    var hostname: String
    var port: Int
    var username: String
    var password: String
    var secure: SmtpSecureChannel
    var connectTimeout:TimeAmount

    public init(hostname: String = "",
                port: Int = 465,
                username: String = "",
                password: String = "",
                secure: SmtpSecureChannel = .none,
                connectTimeout: TimeAmount = TimeAmount.seconds(10)
    ) {
        self.hostname = hostname
        self.port = port
        self.username = username
        self.password = password
        self.secure = secure
        self.connectTimeout = connectTimeout
    }
}
