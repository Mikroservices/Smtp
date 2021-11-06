//
//  https://mczachurski.dev
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

public struct EmailAddress {
    public let address: String
    public let name: String?

    public init(address: String, name: String? = nil) {
        self.address = address
        self.name = name
    }
}
