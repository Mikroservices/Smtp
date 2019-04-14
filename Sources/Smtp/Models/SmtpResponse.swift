internal enum SmtpResponse {
    case ok(Int, String)
    case error(String)
}
