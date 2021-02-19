internal enum SMTPResponse {
    case ok(Int, String)
    case error(String)
}
