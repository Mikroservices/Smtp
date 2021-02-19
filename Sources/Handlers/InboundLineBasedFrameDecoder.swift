import NIO

/// A decoder that splits incoming `ByteBuffer`s around line end
/// character(s) (`'\n'` or `'\r\n'`).
///
/// Let's, for example, consider the following received buffer:
///
///     +----+-------+------------+
///     | AB | C\nDE | F\r\nGHI\n |
///     +----+-------+------------+
///
/// A instance of `InboundLineBasedFrameDecoder` will split this buffer
/// as follows:
///
///     +-----+-----+-----+
///     | ABC | DEF | GHI |
///     +-----+-----+-----+
///
internal class InboundLineBasedFrameDecoder: ByteToMessageDecoder {

    public typealias InboundIn = ByteBuffer
    public typealias InboundOut = ByteBuffer
    public var cumulationBuffer: ByteBuffer?
    // keep track of the last scan offset from the buffer's reader index (if we didn't find the delimiter)
    private var lastScanOffset = 0
    private var handledLeftovers = false

    public init() { }

    public func decode(context: ChannelHandlerContext, buffer: inout ByteBuffer) -> DecodingState {
        if let frame = self.findNextFrame(buffer: &buffer) {
            context.fireChannelRead(wrapInboundOut(frame))
            return .continue
        } else {
            return .needMoreData
        }
    }

    private func findNextFrame(buffer: inout ByteBuffer) -> ByteBuffer? {
        let view = buffer.readableBytesView.dropFirst(self.lastScanOffset)
        
        // look for the delimiter
        if let delimiterIndex = view.firstIndex(of: 0x0A) { // '\n'
            let length = delimiterIndex - buffer.readerIndex
            let dropCarriageReturn = delimiterIndex > view.startIndex && view[delimiterIndex - 1] == 0x0D // '\r'
            let buff = buffer.readSlice(length: dropCarriageReturn ? length - 1 : length)
            
            // drop the delimiter (and trailing carriage return if appicable)
            buffer.moveReaderIndex(forwardBy: dropCarriageReturn ? 2 : 1)

            // reset the last scan start index since we found a line
            self.lastScanOffset = 0

            return buff
        }
        
        // next scan we start where we stopped
        self.lastScanOffset = buffer.readableBytes
        return nil
    }

    public func handlerRemoved(context: ChannelHandlerContext) {
        self.handleLeftOverBytes(context: context)
    }

    public func channelInactive(context: ChannelHandlerContext) {
        self.handleLeftOverBytes(context: context)
    }

    private func handleLeftOverBytes(context: ChannelHandlerContext) {
        if let buffer = self.cumulationBuffer, buffer.readableBytes > 0 && !self.handledLeftovers {
            self.handledLeftovers = true
            context.fireErrorCaught(NIOExtrasErrors.LeftOverBytesError(leftOverBytes: buffer))
        }
    }
}

#if !swift(>=4.2)
private extension ByteBufferView {
    func firstIndex(of element: UInt8) -> Int? {
        return self.index(of: element)
    }
}
#endif
