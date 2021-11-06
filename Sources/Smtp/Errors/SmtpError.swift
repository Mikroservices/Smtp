//
//  https://mczachurski.dev
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

struct SmtpError: Error {
    let message: String

    init(_ message: String) {
        self.message = message
    }
}
