//
//  https://mczachurski.dev
//  Copyright © 2021 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import XCTest
import NIO
import Vapor
@testable import Smtp

final class SmtpTests: XCTestCase {

    let smtpConfiguration = SmtpServerConfiguration(hostname: "smtp.mailtrap.io",
                                                    port: 465,
                                                    signInMethod: .credentials(username: "#MAILTRAPUSER#", password: "#MAILTRAPPASS#"),
                                                    secure: .none)

    let sslSmtpConfiguration = SmtpServerConfiguration(hostname: "smtp.gmail.com",
                                                       port: 465,
                                                       signInMethod: .credentials(username: "#GMAILUSER#", password: "#GMAILPASS#"),
                                                       secure: .ssl)

    let tslSmtpConfiguration = SmtpServerConfiguration(hostname: "smtp.gmail.com",
                                                       port: 587,
                                                       signInMethod: .credentials(username: "#GMAILUSER#", password: "#GMAILPASS#"),
                                                       secure: .startTls)

    let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)

    func testSendTextMessage() throws {
        let application = Application()
        defer {
            application.shutdown()
        }

        application.smtp.configuration = smtpConfiguration
        let email = try! Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: [EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe")],
                          subject: "The subject (text) - \(timestamp)",
                          body: "This is email body.")
        
        let request = Request(application: application, on: application.eventLoopGroup.next())
        try request.smtp.send(email) { message in
            print(message)
        }.flatMapThrowing { result in
            XCTAssertTrue(try result.get())
        }.wait()

        sleep(3)
    }

    func testSendTextMessageViaApplication() throws {
        let application = Application()
        defer {
            application.shutdown()
        }

        application.smtp.configuration = smtpConfiguration
        let email = try! Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: [EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe")],
                          subject: "The subject (text) - \(timestamp)",
                          body: "This is email body.")
        
        try application.smtp.send(email) { message in
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
        let email = try! Email(from: EmailAddress(address: "john.doe@testxx.com"),
                          to: [EmailAddress(address: "ben.doe@testxx.com")],
                          subject: "The subject (without names) - \(timestamp)",
                          body: "This is email body.")

        let request = Request(application: application, on: application.eventLoopGroup.next())
        try request.smtp.send(email) { message in
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
        let email = try! Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: [EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe")],
                          subject: "The subject (html) - \(timestamp)",
                          body: "<html><body><h1>This is email content!</h1></body></html>",
                          isBodyHtml: true)

        let request = Request(application: application, on: application.eventLoopGroup.next())
        try request.smtp.send(email) { message in
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
        var email = try! Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: [EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe")],
                          subject: "The subject (text) - \(timestamp)",
                          body: "This is email body.")

        email.addAttachment(Attachment(name: "plik1.txt", contentType: "text/plain", data: Attachments.text()))
        email.addAttachment(Attachment(name: "image.png", contentType: "image/png", data: Attachments.image()))

        let request = Request(application: application, on: application.eventLoopGroup.next())
        try request.smtp.send(email) { message in
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
        var email = try! Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: [EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe")],
                          subject: "The subject (html) - \(timestamp)",
                          body: "<html><body><h1>This is email content!</h1></body></html>",
                          isBodyHtml: true)

        email.addAttachment(Attachment(name: "plik1.txt", contentType: "text/plain", data: Attachments.text()))
        email.addAttachment(Attachment(name: "image.png", contentType: "image/png", data: Attachments.image()))

        let request = Request(application: application, on: application.eventLoopGroup.next())
        try request.smtp.send(email) { message in
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
        let email = try! Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: [
                            EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe"),
                            EmailAddress(address: "anton.doe@testxx.com", name: "Anton Doe")
                          ],
                          subject: "The subject (multiple to) - \(timestamp)",
                          body: "This is email body.")

        let request = Request(application: application, on: application.eventLoopGroup.next())
        try request.smtp.send(email) { message in
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
        let email = try! Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
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
        try request.smtp.send(email) { message in
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
        let email = try! Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: [EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe")],
                          subject: "The subject (reply-to) - \(timestamp)",
                          body: "This is email body.",
                          replyTo: EmailAddress(address: "noreply@testxx.com"))

        let request = Request(application: application, on: application.eventLoopGroup.next())
        try request.smtp.send(email) { message in
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
        var email = try! Email(from: EmailAddress(address: "smtp.mikroservice@gmail.com", name: "John Doe"),
                          to: [EmailAddress(address: "smtp.mikroservice@outlook.com", name: "Ben Doe")],
                          subject: "The subject (over SSL) - \(timestamp)",
                          body: "This is email body.")

        email.addAttachment(Attachment(name: "plik1.txt", contentType: "text/plain", data: Attachments.text()))
        email.addAttachment(Attachment(name: "image.png", contentType: "image/png", data: Attachments.image()))

        let request = Request(application: application, on: application.eventLoopGroup.next())
        try request.smtp.send(email) { message in
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
        var email = try! Email(from: EmailAddress(address: "smtp.mikroservice@gmail.com", name: "John Doe"),
                          to: [EmailAddress(address: "smtp.mikroservice@outlook.com", name: "Ben Doe")],
                          subject: "The subject (over TSL) - \(timestamp)",
                          body: "This is email body.")

        email.addAttachment(Attachment(name: "plik1.txt", contentType: "text/plain", data: Attachments.text()))
        email.addAttachment(Attachment(name: "image.png", contentType: "image/png", data: Attachments.image()))

        let request = Request(application: application, on: application.eventLoopGroup.next())
        try request.smtp.send(email) { message in
            print(message)
        }.flatMapThrowing { result in
            XCTAssertTrue(try result.get())
        }.wait()
    }
    
    func testSendBccTextMessage() throws {
        let application = Application()
        defer {
            application.shutdown()
        }

        application.smtp.configuration = smtpConfiguration
        let email = try! Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: [EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe")],
                          cc: [EmailAddress(address: "july.doe@testxx.com", name: "July Doe"), EmailAddress(address: "viki.doe@testxx.com", name: "Viki Doe")],
                          bcc:[EmailAddress(address: "hidden1@testxx.com", name: "Hidden One"), EmailAddress(address: "hidden2@testxx.com", name: "Hidden Two")],
                          subject: "The subject (bcc) - \(timestamp)",
                          body: "This is email body.")

        let request = Request(application: application, on: application.eventLoopGroup.next())
        try request.smtp.send(email) { message in
            print(message)
        }.flatMapThrowing { result in
            XCTAssertTrue(try result.get())
        }.wait()

        sleep(3)
    }
    
    func testSendInReplyToTextMessage() throws {
        let application = Application()
        defer {
            application.shutdown()
        }

        application.smtp.configuration = smtpConfiguration
        let email = try! Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: [EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe")],
                          subject: "The subject (reference) - \(timestamp)",
                          body: "This is email body.",
                          reference: "<53455345@testxx.com>"
        )

        let request = Request(application: application, on: application.eventLoopGroup.next())
        try request.smtp.send(email) { message in
            print(message)
        }.flatMapThrowing { result in
            XCTAssertTrue(try result.get())
        }.wait()

        sleep(3)
    }
    
    func testSendOnlyBccTextMessage() throws {
        let application = Application()
        defer {
            application.shutdown()
        }

        application.smtp.configuration = smtpConfiguration
        let email = try! Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                               bcc:[EmailAddress(address: "hidden1@testxx.com", name: "Hidden One"), EmailAddress(address: "hidden2@testxx.com", name: "Hidden Two")],
                               subject: "The subject (only bcc) - \(timestamp)",
                               body: "This is email body.")

        let request = Request(application: application, on: application.eventLoopGroup.next())
        try request.smtp.send(email) { message in
            print(message)
        }.flatMapThrowing { result in
            XCTAssertTrue(try result.get())
        }.wait()

        sleep(3)
    }
    
    func testEmailWithoutRecipientsCannotBeInitialized() throws {
        XCTAssertThrowsError(
            try Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                      subject: "The subject (reference) - \(timestamp)",
                      body: "This is email body.",
                      reference: "<53455345@testxx.com>"
            )
        ) { error in
            XCTAssertEqual(error as! EmailError, EmailError.recipientNotSpecified)
        }
    }
    
#if compiler(>=5.5) && canImport(_Concurrency)

    @available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
    func testSendTextMessageWithAwaitFunction() async {
        let application = Application()
        defer {
            application.shutdown()
        }

        application.smtp.configuration = smtpConfiguration
        let email = try! Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: [EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe")],
                          subject: "The subject (text) - \(timestamp)",
                          body: "This is email body.")
        
        let request = Request(application: application, on: application.eventLoopGroup.next())
        do {
            try await request.smtp.send(email)
        }
        catch {
            XCTFail("Error during send email")
        }

        sleep(3)
    }

#endif
}
