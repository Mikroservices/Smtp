public struct EmailAddress {
    public let address: String
    public let name: String?

    public init(address: String, name: String? = nil) {
        self.address = address
        self.name = name
    }
}
