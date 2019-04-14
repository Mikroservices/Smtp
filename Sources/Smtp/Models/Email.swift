import Foundation

public struct Email {
    public let from: String
    public let fromName: String?
    public let to: String
    public let toName: String?
    public let cc: [String]?
    public let bcc: [String]?
    public let subject: String
    public let body: String
    public let isBodyHtml: Bool

    public init(from: String,
                fromName: String? = nil,
                to: String,
                toName: String? = nil,
                cc: [String]? = nil,
                bcc: [String]? = nil,
                subject: String,
                body: String,
                isBodyHtml: Bool = false
    ) {
        self.from = from
        self.fromName = fromName
        self.to = to
        self.toName = toName
        self.cc = cc
        self.bcc = bcc
        self.subject = subject
        self.body = body
        self.isBodyHtml = isBodyHtml
    }
}
