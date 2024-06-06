//
//  https://mczachurski.dev
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

public struct Attachment {
    public let name: String
    public let contentType: String
    public let data: Data
    public let contentID: String?

    public init(name: String, contentType: String, data: Data,  contentID: String? = nil) {
        self.name = name
        self.contentType = contentType
        self.data = data
        self.contentID = contentID
    }
}
