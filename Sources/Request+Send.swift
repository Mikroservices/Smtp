import Foundation
import NIO
import NIOSSL
import Vapor

public extension Request {
    var smtp: SMTP {
        .init(request: self)
    }

    struct SMTP {
        let request: Request

        public func send(_ email: Email, logHandler: ((String) -> Void)? = nil) -> EventLoopFuture<Result<Bool, Error>> {
            return self.request.application.smtp.send(email, eventLoop: self.request.eventLoop, logHandler: logHandler)
        }
    }
    
    @available(*, deprecated, message: "Function is depraceted and will be deleted in SMTP 3.0. Please use: request.smtp.send() instead.")
    func send(_ email: Email, logHandler: ((String) -> Void)? = nil) -> EventLoopFuture<Result<Bool, Error>> {
        return self.application.smtp.send(email, eventLoop: self.eventLoop, logHandler: logHandler)
    }
}
