//
//  Compressor.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-08-28.
//

import Foundation
import Compression

public extension Data {

    /// Decompresses the data.
    /// - parameter withAlgorithm: Compression algorithm to use. See the `CompressionAlgorithm` type
    /// - returns: decompressed data
    func decompress(withAlgorithm algo: CompressionAlgorithm) -> Data? {
        return self.withUnsafeBytes { (sourcePtr: UnsafePointer<UInt8>) -> Data? in
            let config = (operation: COMPRESSION_STREAM_DECODE, algorithm: algo.lowLevelType)
            return perform(config, source: sourcePtr, sourceSize: count)
        }
    }
    
    /// Please consider the [libcompression documentation](https://developer.apple.com/reference/compression/1665429-data_compression)
    /// for further details. Short info:
    /// zlib  : Aka deflate. Fast with a good compression rate. Proved itself over time and is supported everywhere.
    /// lzfse : Apples custom Lempel-Ziv style compression algorithm. Claims to compress as good as zlib but 2 to 3 times faster.
    /// lzma  : Horribly slow. Compression as well as decompression. Compresses better than zlib though.
    /// lz4   : Fast, but compression rate is very bad. Apples lz4 implementation often to not compress at all.
    enum CompressionAlgorithm {
        case zlib
        case lzfse
        case lzma
        case lz4
    }
    
    /// Compresses the data using the zlib deflate algorithm.
    /// - returns: raw deflated data according to [RFC-1951](https://tools.ietf.org/html/rfc1951).
    /// - note: Fixed at compression level 5 (best trade off between speed and time)
    func deflate() -> Data? {
        return self.withUnsafeBytes { (sourcePtr: UnsafePointer<UInt8>) -> Data? in
            let config = (operation: COMPRESSION_STREAM_ENCODE, algorithm: COMPRESSION_ZLIB)
            return perform(config, source: sourcePtr, sourceSize: count)
        }
    }
}

fileprivate extension Data
{
    func withUnsafeBytes<ResultType, ContentType>(_ body: (UnsafePointer<ContentType>) throws -> ResultType) rethrows -> ResultType
    {
        return try self.withUnsafeBytes({ (rawBufferPointer: UnsafeRawBufferPointer) -> ResultType in
            return try body(rawBufferPointer.bindMemory(to: ContentType.self).baseAddress!)
        })
    }
}

fileprivate extension Data.CompressionAlgorithm
{
    var lowLevelType: compression_algorithm {
        switch self {
            case .zlib    : return COMPRESSION_ZLIB
            case .lzfse   : return COMPRESSION_LZFSE
            case .lz4     : return COMPRESSION_LZ4
            case .lzma    : return COMPRESSION_LZMA
        }
    }
}


fileprivate typealias Config = (operation: compression_stream_operation, algorithm: compression_algorithm)


fileprivate func perform(_ config: Config, source: UnsafePointer<UInt8>, sourceSize: Int, preload: Data = Data()) -> Data?
{
    guard config.operation == COMPRESSION_STREAM_ENCODE || sourceSize > 0 else { return nil }
    
    let streamBase = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1)
    defer { streamBase.deallocate() }
    var stream = streamBase.pointee
    
    let status = compression_stream_init(&stream, config.operation, config.algorithm)
    guard status != COMPRESSION_STATUS_ERROR else { return nil }
    defer { compression_stream_destroy(&stream) }

    var result = preload
    var flags: Int32 = Int32(COMPRESSION_STREAM_FINALIZE.rawValue)
    let blockLimit = 64 * 1024
    var bufferSize = Swift.max(sourceSize, 64)

    if sourceSize > blockLimit {
        bufferSize = blockLimit
        if config.algorithm == COMPRESSION_LZFSE && config.operation != COMPRESSION_STREAM_ENCODE   {
            // This fixes a bug in Apples lzfse decompressor. it will sometimes fail randomly when the input gets
            // splitted into multiple chunks and the flag is not 0. Even though it should always work with FINALIZE...
            flags = 0
        }
    }

    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
    defer { buffer.deallocate() }
    
    stream.dst_ptr  = buffer
    stream.dst_size = bufferSize
    stream.src_ptr  = source
    stream.src_size = sourceSize
    
    while true {
        switch compression_stream_process(&stream, flags) {
            case COMPRESSION_STATUS_OK:
                guard stream.dst_size == 0 else { return nil }
                result.append(buffer, count: stream.dst_ptr - buffer)
                stream.dst_ptr = buffer
                stream.dst_size = bufferSize

                if flags == 0 && stream.src_size == 0 { // part of the lzfse bugfix above
                    flags = Int32(COMPRESSION_STREAM_FINALIZE.rawValue)
                }
                
            case COMPRESSION_STATUS_END:
                result.append(buffer, count: stream.dst_ptr - buffer)
                return result
                
            default:
                return nil
        }
    }
}
