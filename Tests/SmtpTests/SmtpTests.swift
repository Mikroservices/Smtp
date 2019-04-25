import XCTest
import NIO
@testable import Smtp

final class SmtpTests: XCTestCase {

    let smtpClientService = SmtpClientService(configuration: SmtpServerConfiguration(hostname: "smtp.mailtrap.io",
                                                                                     port: 465,
                                                                                     username: "",
                                                                                     password: ""))

    let sslSmtpClientService = SmtpClientService(configuration: SmtpServerConfiguration(hostname: "smtp.gmail.com",
                                                                                        port: 465,
                                                                                        username: "",
                                                                                        password: "",
                                                                                        secure: .ssl))

    let tslSmtpClientService = SmtpClientService(configuration: SmtpServerConfiguration(hostname: "smtp.gmail.com",
                                                                                        port: 587,
                                                                                        username: "",
                                                                                        password: "",
                                                                                        secure: .startTls))

    func testSendTextMessage() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        let email = Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: [EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe")],
                          subject: "The subject (text)",
                          body: "This is email body.")

        try smtpClientService.send(email, on: eventLoopGroup) { message in
            print(message)
        }.map { result in
            XCTAssertTrue(try result.get())
        }.wait()
    }

    func testSendTextMessageWithoutNames() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        let email = Email(from: EmailAddress(address: "john.doe@testxx.com"),
                          to: [EmailAddress(address: "ben.doe@testxx.com")],
                          subject: "The subject (without names)",
                          body: "This is email body.")

        try smtpClientService.send(email, on: eventLoopGroup) { message in
            print(message)
        }.map { result in
            XCTAssertTrue(try result.get())
        }.wait()
    }

    func testSendHtmlMessage() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        let email = Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: [EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe")],
                          subject: "The subject (html)",
                          body: "<html><body><h1>This is email content!</h1></body></html>",
                          isBodyHtml: true)

        try smtpClientService.send(email, on: eventLoopGroup) { message in
            print(message)
        }.map { result in
            XCTAssertTrue(try result.get())
        }.wait()
    }

    func testSendTextMessageWithAttachments() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        var email = Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: [EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe")],
                          subject: "The subject (text)",
                          body: "This is email body.")

        email.addAttachment(Attachment(name: "plik1.txt", contentType: "text/plain", data: Attachments.text()))
        email.addAttachment(Attachment(name: "image.png", contentType: "image/png", data: Attachments.image()))

        try smtpClientService.send(email, on: eventLoopGroup) { message in
            print(message)
        }.map { result in
            XCTAssertTrue(try result.get())
        }.wait()
    }

    func testSendHtmlMessageWithAttachments() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        var email = Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: [EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe")],
                          subject: "The subject (html)",
                          body: "<html><body><h1>This is email content!</h1></body></html>",
                          isBodyHtml: true)

        email.addAttachment(Attachment(name: "plik1.txt", contentType: "text/plain", data: Attachments.text()))
        email.addAttachment(Attachment(name: "image.png", contentType: "image/png", data: Attachments.image()))

        try smtpClientService.send(email, on: eventLoopGroup) { message in
            print(message)
        }.map { result in
            XCTAssertTrue(try result.get())
        }.wait()
    }

    func testSendTextMessageOverSSL() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        var email = Email(from: EmailAddress(address: "SENDER-EMAIL-TEST@gmail.com", name: "John Doe"),
                          to: [EmailAddress(address: "RECIPIENT-EMAIl-TEST@icloud.com", name: "Ben Doe")],
                          subject: "The subject (text)",
                          body: "This is email body.")

        email.addAttachment(Attachment(name: "plik1.txt", contentType: "text/plain", data: Attachments.text()))
        email.addAttachment(Attachment(name: "image.png", contentType: "image/png", data: Attachments.image()))

        try sslSmtpClientService.send(email, on: eventLoopGroup) { message in
            print(message)
        }.map { result in
            XCTAssertTrue(try result.get())
        }.wait()
    }

    func testSendTextMessageOverTSL() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        let email = Email(from: EmailAddress(address: "SENDER-EMAIL-TEST@gmail.com", name: "John Doe"),
                          to: [EmailAddress(address: "RECIPIENT-EMAIL-TEST@icloud.com", name: "Ben Doe")],
                          subject: "The subject (text)",
                          body: "This is email body.")

        email.addAttachment(Attachment(name: "plik1.txt", contentType: "text/plain", data: Attachments.text()))
        email.addAttachment(Attachment(name: "image.png", contentType: "image/png", data: Attachments.image()))

        try tslSmtpClientService.send(email, on: eventLoopGroup) { message in
            print(message)
        }.map { result in
            XCTAssertTrue(try result.get())
        }.wait()
    }

    func testSendTextMessageToMultipleRecipients() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        let email = Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: [
                            EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe"),
                            EmailAddress(address: "anton.doe@testxx.com", name: "Anton Doe")
                          ],
                          subject: "The subject (multiple to)",
                          body: "This is email body.")

        try smtpClientService.send(email, on: eventLoopGroup) { message in
            print(message)
        }.map { result in
            XCTAssertTrue(try result.get())
        }.wait()
    }

    func testSendTextMessageWithCC() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        let email = Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: [
                            EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe"),
                            EmailAddress(address: "anton.doe@testxx.com", name: "Anton Doe")
                          ],
                          cc: [
                            EmailAddress(address: "tom.doe@testxx.com", name: "Tom Doe"),
                            EmailAddress(address: "rob.doe@testxx.com", name: "Rob Doe")
                          ],
                          subject: "The subject (multiple cc)",
                          body: "This is email body.")

        try smtpClientService.send(email, on: eventLoopGroup) { message in
            print(message)
        }.map { result in
            XCTAssertTrue(try result.get())
        }.wait()
    }

    func testSendTextMessageWithReplyTo() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        let email = Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: [EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe")],
                          subject: "The subject (reply-to)",
                          body: "This is email body.",
                          replyTo: EmailAddress(address: "noreply@testxx.com"))

        try smtpClientService.send(email, on: eventLoopGroup) { message in
            print(message)
        }.map { result in
            XCTAssertTrue(try result.get())
        }.wait()
    }

    static var allTests = [
        ("testSendTextMessage", testSendTextMessage),
        ("testSendHtmlMessage", testSendHtmlMessage),
        ("testSendTextMessageWithoutNames", testSendTextMessageWithoutNames),
        ("testSendTextMessageWithAttachments", testSendTextMessageWithAttachments),
        ("testSendHtmlMessageWithAttachments", testSendHtmlMessageWithAttachments),
        ("testSendTextMessageOverSSL", testSendTextMessageOverSSL),
        ("testSendTextMessageOverTSL", testSendTextMessageOverTSL),
        ("testSendTextMessageToMultipleRecipients", testSendTextMessageToMultipleRecipients),
        ("testSendTextMessageWithCC", testSendTextMessageWithCC),
        ("testSendTextMessageWithReplyTo", testSendTextMessageWithReplyTo)
    ]
}
