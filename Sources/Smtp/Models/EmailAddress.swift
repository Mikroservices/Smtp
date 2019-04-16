public struct EmailAddress {
    let address: String
    let name: String?

    init(address: String, name: String? = nil) {
        self.address = address
        self.name = name
    }
}
