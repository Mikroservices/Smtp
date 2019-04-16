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

    func testSendTextMessage() throws {

        let email = Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe"),
                          subject: "The subject (text)",
                          body: "This is email body.")

        let worker = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        try smtpClientService.send(email, on: worker).map { result in
            XCTAssertTrue(try result.get())
        }.wait()
    }

    func testSendTextMessageWithoutNames() throws {

        let email = Email(from: EmailAddress(address: "john.doe@testxx.com"),
                          to: EmailAddress(address: "ben.doe@testxx.com"),
                          subject: "The subject (without names)",
                          body: "This is email body.")

        let worker = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        try smtpClientService.send(email, on: worker).map { result in
            XCTAssertTrue(try result.get())
        }.wait()
    }

    func testSendHtmlMessage() throws {

        let email = Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe"),
                          subject: "The subject (html)",
                          body: "<html><body><h1>This is email content!</h1></body></html>",
                          isBodyHtml: true)


        let worker = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        try smtpClientService.send(email, on: worker).map { result in
            XCTAssertTrue(try result.get())
        }.wait()
    }

    func testSendTextMessageWithAttachments() throws {

        var email = Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe"),
                          subject: "The subject (text)",
                          body: "This is email body.")

        email.addAttachment(Attachment(name: "plik1.txt", contentType: "text/plain", data: Attachments.text()))
        email.addAttachment(Attachment(name: "image.png", contentType: "image/png", data: Attachments.image()))

        let worker = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        try smtpClientService.send(email, on: worker) { message in
            print(message)
        }.map { result in
            XCTAssertTrue(try result.get())
        }.wait()
    }

    func testSendHtmlMessageWithAttachments() throws {

        var email = Email(from: EmailAddress(address: "john.doe@testxx.com", name: "John Doe"),
                          to: EmailAddress(address: "ben.doe@testxx.com", name: "Ben Doe"),
                          subject: "The subject (html)",
                          body: "<html><body><h1>This is email content!</h1></body></html>",
                          isBodyHtml: true)

        email.addAttachment(Attachment(name: "plik1.txt", contentType: "text/plain", data: Attachments.text()))
        email.addAttachment(Attachment(name: "image.png", contentType: "image/png", data: Attachments.image()))

        let worker = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        try smtpClientService.send(email, on: worker) { message in
            print(message)
        }.map { result in
            XCTAssertTrue(try result.get())
        }.wait()
    }

    func testSendTextMessageOverSSL() throws {

        var email = Email(from: EmailAddress(address: "SENDER-EMAIL-TEST@gmail.com", name: "John Doe"),
                          to: EmailAddress(address: "RECIPIENT-EMAIl-TEST@icloud.com", name: "Ben Doe"),
                          subject: "The subject (text)",
                          body: "This is email body.")

        email.addAttachment(Attachment(name: "plik1.txt", contentType: "text/plain", data: Attachments.text()))
        email.addAttachment(Attachment(name: "image.png", contentType: "image/png", data: Attachments.image()))

        let worker = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        try sslSmtpClientService.send(email, on: worker) { message in
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
        ("testSendTextMessageOverSSL", testSendTextMessageOverSSL)
    ]
}
