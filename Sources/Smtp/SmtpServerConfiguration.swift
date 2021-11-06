//
//  https://mczachurski.dev
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import NIO
import Vapor

public struct SmtpServerConfiguration {
    public var hostname: String
    public var port: Int
    public var secure: SmtpSecureChannel
    public var connectTimeout:TimeAmount
    public var helloMethod: HelloMethod
    public var signInMethod: SignInMethod

    public init(hostname: String = "",
                port: Int = 465,
                signInMethod: SignInMethod = .anonymous,
                secure: SmtpSecureChannel = .none,
                connectTimeout: TimeAmount = TimeAmount.seconds(10),
                helloMethod: HelloMethod = .helo
    ) {
        self.hostname = hostname
        self.port = port
        self.secure = secure
        self.connectTimeout = connectTimeout
        self.helloMethod = helloMethod
        self.signInMethod = signInMethod
    }
}
