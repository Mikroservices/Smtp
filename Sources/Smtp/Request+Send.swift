//
//  https://mczachurski.dev
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import NIO
import NIOSSL
import Vapor

public extension Request {
    var smtp: Smtp {
        .init(request: self)
    }

    struct Smtp {
        let request: Request

        public func send(_ email: Email, logHandler: ((String) -> Void)? = nil) -> EventLoopFuture<Result<Bool, Error>> {
            return self.request.application.smtp.send(email, eventLoop: self.request.eventLoop, logHandler: logHandler)
        }
    }
}

#if compiler(>=5.5) && canImport(_Concurrency)

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
public extension Request.Smtp {
    func send(_ email: Email, logHandler: ((String) -> Void)? = nil) async throws {
        return try await self.request.application.smtp.send(email, eventLoop: self.request.eventLoop, logHandler: logHandler)
    }
}

#endif
