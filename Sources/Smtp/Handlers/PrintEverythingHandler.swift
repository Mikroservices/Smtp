import NIO

internal final class PrintEverythingHandler: ChannelDuplexHandler {
    typealias InboundIn = ByteBuffer
    typealias InboundOut = ByteBuffer
    typealias OutboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer

    private let handler: (String) -> Void

    init(handler: @escaping (String) -> Void) {
        self.handler = handler
    }

    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let buffer = self.unwrapInboundIn(data)
        self.handler("☁️ \(String(decoding: buffer.readableBytesView, as: UTF8.self))")
        ctx.fireChannelRead(data)
    }

    func write(ctx: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let buffer = self.unwrapOutboundIn(data)
        self.handler("📱 \(String(decoding: buffer.readableBytesView, as: UTF8.self))")
        ctx.write(data, promise: promise)
    }
}
