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
    public let contentId: String?

    public init(name: String, contentType: String, data: Data, contentId: String? = nil) {
        self.name = name
        self.contentType = contentType
        self.data = data
        self.contentId = contentId
    }
}
