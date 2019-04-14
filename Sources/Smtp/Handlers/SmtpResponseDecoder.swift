import NIO

internal final class SmtpResponseDecoder: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer
    typealias InboundOut = SmtpResponse

    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        var response = self.unwrapInboundIn(data)

        if let firstFourBytes = response.readString(length: 4), let code = Int(firstFourBytes.dropLast()) {
            let remainder = response.readString(length: response.readableBytes) ?? ""

            let firstCharacter = firstFourBytes.first!
            let fourthCharacter = firstFourBytes.last!

            switch (firstCharacter, fourthCharacter) {
            case ("2", " "),
                 ("3", " "):
                let parsedMessage = SmtpResponse.ok(code, remainder)
                ctx.fireChannelRead(self.wrapInboundOut(parsedMessage))
            case (_, "-"):
                () // intermediate message, ignore
            default:
                ctx.fireChannelRead(self.wrapInboundOut(.error(firstFourBytes+remainder)))
            }
        } else {
            ctx.fireErrorCaught(SmtpResponseDecoderError.malformedMessage)
        }
    }
}
