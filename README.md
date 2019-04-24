# Smtp

[![Build Status](https://travis-ci.org/Mikroservices/Smtp.svg?branch=master)](https://travis-ci.org/Mikroservices/Smtp)
[![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat)](ttps://developer.apple.com/swift/)
[![Vapor 3](https://img.shields.io/badge/vapor-3.0-blue.svg?style=flat)](https://vapor.codes)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)
[![Platforms OS X | Linux](https://img.shields.io/badge/Platforms-OS%20X%20%7C%20Linux%20-lightgray.svg?style=flat)](https://developer.apple.com/swift/)

:email: SMTP protocol support for the Vapor web framework. 

This framework has dependencies only to `Vapor` and `SwiftNIO` packages.
`SwiftNIO` support was inspired by Apple examples: [Swift NIO examples](https://github.com/apple/swift-nio-examples).

Features:

- [x] Vapor provider/service
- [x] SwiftNIO Support
- [x] Text/HTML
- [x] Attachments
- [x] SSL/TLS (when connection starts)
- [x] Multiple recipients & CC
- [x] Reply to
- [ ] Multiple emails sent at the same time
- [ ] BCC fields
- [ ] STARTTSL support

## Getting started

Add the dependency to `Package.swift`:

```swift
.package(url: "https://github.com/Mikroservices/Smtp.git", from: "1.0.0")
```

Register the SMTP server configuration and the provider.

```swift
let configuration = SmtpServerConfiguration(hostname: "smtp.server",
                                            port: 465,
                                            username: "johndoe",
                                            password: "passw0rd",
                                            secure: .ssl)

services.register(configuration)
try services.register(SmtpClientProvider())
```

Using SMTP client.

```swift
let smtpClientService = try app.make(SmtpClientService.self)

let email = Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                  to: [EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe")],
                  subject: "The subject (text)",
                  body: "This is email body.")

smtpClientService.send(email, on: request).map { result in
    switch result {
    case .success:
        print("Email has been sent")
    case .failure(let error):
        print("Email has not been sent: \(error)")
    }  
}
```

## Troubleshoots

You can use `logHandler` to handle and print all messages send/retrieved from email server.

```swift
smtpClientService.send(email, on: request) { message in
    print(message)
}.map { result in
    ...
}
```
