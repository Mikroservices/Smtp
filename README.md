# Smtp

![Build Status](https://github.com/Mikroservices/Smtp/workflows/Build/badge.svg)
[![Swift 5.2](https://img.shields.io/badge/Swift-5.2-orange.svg?style=flat)](ttps://developer.apple.com/swift/)
[![Vapor 4](https://img.shields.io/badge/vapor-4.0-blue.svg?style=flat)](https://vapor.codes)
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
- [x] STARTTLS support
- [x] Multiple recipients & CC
- [x] Reply to
- [ ] BCC fields
- [ ] Multiple emails sent at the same time

## Getting started

You need to add library to `Package.swift` file:

 - add package to dependencies:
```swift
.package(url: "https://github.com/Mikroservices/Smtp.git", from: "2.0.0")
```

- and add product to your target:
```swift
.target(name: "App", dependencies: [
    .product(name: "Vapor", package: "vapor"),
    .product(name: "Smtp", package: "Smtp")
])
```

Set the SMTP server configuration (e.g. in `main.swift` file).

```swift
import Smtp

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)

let app = Application(env)
defer { app.shutdown() }

app.smtp.configuration.host = "smtp.server"
app.smtp.configuration.username = "johndoe"
app.smtp.configuration.password = "passw0rd"
app.smtp.configuration.secure = .ssl

try configure(app)
try app.run()
```

Using SMTP client.

```swift
let email = Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                  to: [EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe")],
                  subject: "The subject (text)",
                  body: "This is email body.")

request.send(email).map { result in
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
request.send(email) { message in
    print(message)
}.map { result in
    ...
}
```

## Developing

After cloning the repository you can open it in Xcode.

```bash
$ git clone https://github.com/Mikroservices/Smtp.git
$ cd Smtp
$ open Packages.swift
```
You can build and run tests directly in Xcode.

## Testing

Unit (integration) tests requires correct email credentials. Credentials are not check-in to the repository.
If you want to run unit tests you have to use your [mailtrap](https://mailtrap.io) account and/or other email provider credentials.

All you need to do is replacing the configuration section in `Tests/SmtpTests/SmtpTests.swift` file.
