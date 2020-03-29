import XCTest
import NIO
import Vapor
@testable import Smtp

final class SmtpTests: XCTestCase {

    let smtpConfiguration = SmtpServerConfiguration(hostname: "smtp.mailtrap.io",
                                                    port: 465,
                                                    username: "",
                                                    password: "")

    let sslSmtpConfiguration = SmtpServerConfiguration(hostname: "smtp.gmail.com",
                                                       port: 465,
                                                       username: "",
                                                       password: "",
                                                       secure: .ssl)

    let tslSmtpConfiguration = SmtpServerConfiguration(hostname: "smtp.gmail.com",
                                                       port: 587,
                                                       username: "",
                                                       password: "",
                                                       secure: .startTls)

    func testSendTextMessage() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        let email = Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: [EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe")],
                          subject: "The subject (text)",
                          body: "This is email body.")

        let request = Request(application: Application(), on: eventLoopGroup.next())
        try request.send(email, configuration: smtpConfiguration) { message in
            print(message)
        }.flatMapThrowing { result in
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

        let request = Request(application: Application(), on: eventLoopGroup.next())
        try request.send(email, configuration: smtpConfiguration) { message in
            print(message)
        }.flatMapThrowing { result in
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

        let request = Request(application: Application(), on: eventLoopGroup.next())
        try request.send(email, configuration: smtpConfiguration) { message in
            print(message)
        }.flatMapThrowing { result in
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

        let request = Request(application: Application(), on: eventLoopGroup.next())
        try request.send(email, configuration: smtpConfiguration) { message in
            print(message)
        }.flatMapThrowing { result in
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

        let request = Request(application: Application(), on: eventLoopGroup.next())
        try request.send(email, configuration: smtpConfiguration) { message in
            print(message)
        }.flatMapThrowing { result in
            XCTAssertTrue(try result.get())
        }.wait()
    }

    func testSendTextMessageOverSSL() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        var email = Email(from: EmailAddress(address: "marcincz@gmail.com", name: "John Doe"),
                          to: [EmailAddress(address: "mczachurski@icloud.com", name: "Ben Doe")],
                          subject: "The subject (text)",
                          body: "This is email body.")

        email.addAttachment(Attachment(name: "plik1.txt", contentType: "text/plain", data: Attachments.text()))
        email.addAttachment(Attachment(name: "image.png", contentType: "image/png", data: Attachments.image()))

        let request = Request(application: Application(), on: eventLoopGroup.next())
        try request.send(email, configuration: sslSmtpConfiguration) { message in
            print(message)
        }.flatMapThrowing { result in
            XCTAssertTrue(try result.get())
        }.wait()
    }

    func testSendTextMessageOverTSL() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        defer {
            XCTAssertNoThrow(try eventLoopGroup.syncShutdownGracefully())
        }

        var email = Email(from: EmailAddress(address: "marcincz@gmail.com", name: "John Doe"),
                          to: [EmailAddress(address: "mczachurski@icloud.com", name: "Ben Doe")],
                          subject: "The subject (text)",
                          body: "This is email body.")

        email.addAttachment(Attachment(name: "plik1.txt", contentType: "text/plain", data: Attachments.text()))
        email.addAttachment(Attachment(name: "image.png", contentType: "image/png", data: Attachments.image()))

        let request = Request(application: Application(), on: eventLoopGroup.next())
        try request.send(email, configuration: tslSmtpConfiguration) { message in
            print(message)
        }.flatMapThrowing { result in
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

        let request = Request(application: Application(), on: eventLoopGroup.next())
        try request.send(email, configuration: smtpConfiguration) { message in
            print(message)
        }.flatMapThrowing { result in
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

        let request = Request(application: Application(), on: eventLoopGroup.next())
        try request.send(email, configuration: smtpConfiguration) { message in
            print(message)
        }.flatMapThrowing { result in
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

        let request = Request(application: Application(), on: eventLoopGroup.next())
        try request.send(email, configuration: smtpConfiguration) { message in
            print(message)
        }.flatMapThrowing { result in
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
