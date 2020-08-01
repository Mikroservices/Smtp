internal enum SmtpRequest {
    case sayHello(serverName: String, helloMethod: HelloMethod)
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

internal enum HelloMethod {
    case helo
    case ehlo
}
