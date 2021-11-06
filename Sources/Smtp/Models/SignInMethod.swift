//
//  https://mczachurski.dev
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

public enum SignInMethod {
    case anonymous
    case credentials(username: String, password: String)
}
