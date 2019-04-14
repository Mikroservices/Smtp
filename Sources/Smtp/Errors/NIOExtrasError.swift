import NIO

internal protocol NIOExtrasError: Equatable, Error { }

/// Errors that are raised in NIOExtras.
internal enum NIOExtrasErrors {

    /// Error indicating that after an operation some unused bytes are left.
    public struct LeftOverBytesError: NIOExtrasError {
        public let leftOverBytes: ByteBuffer
    }
}
