internal enum SmtpRequest {
    case sayHello(serverName: String, helloMethod: HelloMethod)
    case startTls
    case sayHelloAfterTls(serverName: String, helloMethod: HelloMethod)
    case beginAuthentication
    case authUser(String)
    case authPassword(String)
    case mailFrom(String)
    case recipient(String)
    case data
    case transferData(Email)
    case quit
}
