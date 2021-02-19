import NIO
import Vapor

public struct SMTPServerConfiguration {
    public var hostname: String
    public var port: Int
    public var username: String
    public var password: String
    public var secure: SMTPSecureChannel
    public var connectTimeout:TimeAmount
    public var helloMethod: HelloMethod

    public init(hostname: String = "",
                port: Int = 465,
                username: String = "",
                password: String = "",
                secure: SMTPSecureChannel = .none,
                connectTimeout: TimeAmount = TimeAmount.seconds(10),
                helloMethod: HelloMethod = .helo
    ) {
        self.hostname = hostname
        self.port = port
        self.username = username
        self.password = password
        self.secure = secure
        self.connectTimeout = connectTimeout
        self.helloMethod = helloMethod
    }
}
