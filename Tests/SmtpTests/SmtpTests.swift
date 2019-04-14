import XCTest
import NIO
@testable import Smtp

final class SmtpTests: XCTestCase {

    let smtpClientService = SmtpClientService(configuration: SmtpServerConfiguration(hostname: "smtp.mailtrap.io",
                                                                                     port: 465,
                                                                                     username: "8396cb1ecc7959",
                                                                                     password: "29051e376bf674"))

    func testSendTextMessage() throws {

        let email = Email(from: "john.doe@testxx.com",
                          fromName: "John Doe",
                          to: "ben.doe@testxx.com",
                          toName: "Ben Doe",
                          subject: "The subject (text)",
                          body: "This is email body.")

        let worker = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        try smtpClientService.send(email, on: worker).map { result in
            XCTAssertTrue(try result.get())
        }.wait()
    }

    func testSendTextMessageWithoutNames() throws {

        let email = Email(from: "john.doe@testxx.com",
                          to: "ben.doe@testxx.com",
                          subject: "The subject (without names)",
                          body: "This is email body.")

        let worker = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        try smtpClientService.send(email, on: worker).map { result in
            XCTAssertTrue(try result.get())
            }.wait()
    }

    func testSendHtmlMessage() throws {

        let email = Email(from: "john.doe@testxx.com",
                          fromName: "John Doe",
                          to: "ben.doe@testxx.com",
                          toName: "Ben Doe",
                          subject: "The subject (html)",
                          body: "<html><body><h1>Nowa wiadomość email!</h1></body></html>",
                          isBodyHtml: true)


        let worker = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        try smtpClientService.send(email, on: worker).map { result in
            XCTAssertTrue(try result.get())
            }.wait()
    }

    static var allTests = [
        ("testSendTextMessage", testSendTextMessage),
        ("testSendHtmlMessage", testSendHtmlMessage),
        ("testSendTextMessageWithoutNames", testSendTextMessageWithoutNames)
    ]
}
