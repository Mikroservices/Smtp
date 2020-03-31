import XCTest
import NIO
import Vapor
@testable import Smtp

final class SmtpTests: XCTestCase {

    let smtpConfiguration = SmtpServerConfiguration(hostname: "smtp.mailtrap.io",
                                                    port: 465,
                                                    username: "8396cb1ecc7959",
                                                    password: "#MAILTRAPPASS#",
                                                    secure: .none)

    let sslSmtpConfiguration = SmtpServerConfiguration(hostname: "smtp.gmail.com",
                                                       port: 465,
                                                       username: "smtp.mikroservice@gmail.com",
                                                       password: "#GMAILPASS#",
                                                       secure: .ssl)

    let tslSmtpConfiguration = SmtpServerConfiguration(hostname: "smtp.gmail.com",
                                                       port: 587,
                                                       username: "smtp.mikroservice@gmail.com",
                                                       password: "#GMAILPASS#",
                                                       secure: .startTls)

    let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)

    func testSendTextMessage() throws {
        let application = Application()
        defer {
            application.shutdown()
        }

        application.smtp.configuration = smtpConfiguration
        let email = Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: [EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe")],
                          subject: "The subject (text) - \(timestamp)",
                          body: "This is email body.")
        
        let request = Request(application: application, on: application.eventLoopGroup.next())
        try request.send(email) { message in
            print(message)
        }.flatMapThrowing { result in
            XCTAssertTrue(try result.get())
        }.wait()
        
        sleep(3)
    }

    func testSendTextMessageWithoutNames() throws {
        let application = Application()
        defer {
            application.shutdown()
        }

        application.smtp.configuration = smtpConfiguration
        let email = Email(from: EmailAddress(address: "john.doe@testxx.com"),
                          to: [EmailAddress(address: "ben.doe@testxx.com")],
                          subject: "The subject (without names) - \(timestamp)",
                          body: "This is email body.")

        let request = Request(application: application, on: application.eventLoopGroup.next())
        try request.send(email) { message in
            print(message)
        }.flatMapThrowing { result in
            XCTAssertTrue(try result.get())
        }.wait()
        
        sleep(3)
    }

    func testSendHtmlMessage() throws {
        let application = Application()
        defer {
            application.shutdown()
        }

        application.smtp.configuration = smtpConfiguration
        let email = Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: [EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe")],
                          subject: "The subject (html) - \(timestamp)",
                          body: "<html><body><h1>This is email content!</h1></body></html>",
                          isBodyHtml: true)

        let request = Request(application: application, on: application.eventLoopGroup.next())
        try request.send(email) { message in
            print(message)
        }.flatMapThrowing { result in
            XCTAssertTrue(try result.get())
        }.wait()
        
        sleep(3)
    }

    func testSendTextMessageWithAttachments() throws {
        let application = Application()
        defer {
            application.shutdown()
        }

        application.smtp.configuration = smtpConfiguration
        var email = Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: [EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe")],
                          subject: "The subject (text) - \(timestamp)",
                          body: "This is email body.")

        email.addAttachment(Attachment(name: "plik1.txt", contentType: "text/plain", data: Attachments.text()))
        email.addAttachment(Attachment(name: "image.png", contentType: "image/png", data: Attachments.image()))

        let request = Request(application: application, on: application.eventLoopGroup.next())
        try request.send(email) { message in
            print(message)
        }.flatMapThrowing { result in
            XCTAssertTrue(try result.get())
        }.wait()
        
        sleep(3)
    }

    func testSendHtmlMessageWithAttachments() throws {
        let application = Application()
        defer {
            application.shutdown()
        }

        application.smtp.configuration = smtpConfiguration
        var email = Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: [EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe")],
                          subject: "The subject (html) - \(timestamp)",
                          body: "<html><body><h1>This is email content!</h1></body></html>",
                          isBodyHtml: true)

        email.addAttachment(Attachment(name: "plik1.txt", contentType: "text/plain", data: Attachments.text()))
        email.addAttachment(Attachment(name: "image.png", contentType: "image/png", data: Attachments.image()))

        let request = Request(application: application, on: application.eventLoopGroup.next())
        try request.send(email) { message in
            print(message)
        }.flatMapThrowing { result in
            XCTAssertTrue(try result.get())
        }.wait()
        
        sleep(3)
    }

    func testSendTextMessageToMultipleRecipients() throws {
        let application = Application()
        defer {
            application.shutdown()
        }

        application.smtp.configuration = smtpConfiguration
        let email = Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: [
                            EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe"),
                            EmailAddress(address: "anton.doe@testxx.com", name: "Anton Doe")
                          ],
                          subject: "The subject (multiple to) - \(timestamp)",
                          body: "This is email body.")

        let request = Request(application: application, on: application.eventLoopGroup.next())
        try request.send(email) { message in
            print(message)
        }.flatMapThrowing { result in
            XCTAssertTrue(try result.get())
        }.wait()
        
        sleep(3)
    }

    func testSendTextMessageWithCC() throws {
        let application = Application()
        defer {
            application.shutdown()
        }

        application.smtp.configuration = smtpConfiguration
        let email = Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: [
                            EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe"),
                            EmailAddress(address: "anton.doe@testxx.com", name: "Anton Doe")
                          ],
                          cc: [
                            EmailAddress(address: "tom.doe@testxx.com", name: "Tom Doe"),
                            EmailAddress(address: "rob.doe@testxx.com", name: "Rob Doe")
                          ],
                          subject: "The subject (multiple cc) - \(timestamp)",
                          body: "This is email body.")

        let request = Request(application: application, on: application.eventLoopGroup.next())
        try request.send(email) { message in
            print(message)
        }.flatMapThrowing { result in
            XCTAssertTrue(try result.get())
        }.wait()
        
        sleep(3)
    }

    func testSendTextMessageWithReplyTo() throws {
        let application = Application()
        defer {
            application.shutdown()
        }

        application.smtp.configuration = smtpConfiguration
        let email = Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: [EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe")],
                          subject: "The subject (reply-to) - \(timestamp)",
                          body: "This is email body.",
                          replyTo: EmailAddress(address: "noreply@testxx.com"))

        let request = Request(application: application, on: application.eventLoopGroup.next())
        try request.send(email) { message in
            print(message)
        }.flatMapThrowing { result in
            XCTAssertTrue(try result.get())
        }.wait()
        
        sleep(3)
    }

    func testSendTextMessageOverSSL() throws {
        let application = Application()
        defer {
            application.shutdown()
        }
        
        application.smtp.configuration = sslSmtpConfiguration
        var email = Email(from: EmailAddress(address: "smtp.mikroservice@gmail.com", name: "John Doe"),
                          to: [EmailAddress(address: "smtp.mikroservice@outlook.com", name: "Ben Doe")],
                          subject: "The subject (over SSL) - \(timestamp)",
                          body: "This is email body.")

        email.addAttachment(Attachment(name: "plik1.txt", contentType: "text/plain", data: Attachments.text()))
        email.addAttachment(Attachment(name: "image.png", contentType: "image/png", data: Attachments.image()))

        let request = Request(application: application, on: application.eventLoopGroup.next())
        try request.send(email) { message in
            print(message)
        }.flatMapThrowing { result in
            XCTAssertTrue(try result.get())
        }.wait()
    }

    func testSendTextMessageOverTSL() throws {
        let application = Application()
        defer {
            application.shutdown()
        }

        application.smtp.configuration = tslSmtpConfiguration
        var email = Email(from: EmailAddress(address: "smtp.mikroservice@gmail.com", name: "John Doe"),
                          to: [EmailAddress(address: "smtp.mikroservice@outlook.com", name: "Ben Doe")],
                          subject: "The subject (over TSL) - \(timestamp)",
                          body: "This is email body.")

        email.addAttachment(Attachment(name: "plik1.txt", contentType: "text/plain", data: Attachments.text()))
        email.addAttachment(Attachment(name: "image.png", contentType: "image/png", data: Attachments.image()))

        let request = Request(application: application, on: application.eventLoopGroup.next())
        try request.send(email) { message in
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
        ("testSendTextMessageToMultipleRecipients", testSendTextMessageToMultipleRecipients),
        ("testSendTextMessageWithCC", testSendTextMessageWithCC),
        ("testSendTextMessageWithReplyTo", testSendTextMessageWithReplyTo),
        ("testSendTextMessageOverSSL", testSendTextMessageOverSSL),
        ("testSendTextMessageOverTSL", testSendTextMessageOverTSL)
    ]
}
