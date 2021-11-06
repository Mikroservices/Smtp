//
//  https://mczachurski.dev
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

internal enum SmtpResponse {
    case ok(Int, String)
    case error(String)
}
