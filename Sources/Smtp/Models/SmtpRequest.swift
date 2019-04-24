internal enum SmtpRequest {
    case sayHello(serverName: String)
    case startTls
    case beginAuthentication
    case authUser(String)
    case authPassword(String)
    case mailFrom(String)
    case recipient(String)
    case data
    case transferData(Email)
    case quit
}
