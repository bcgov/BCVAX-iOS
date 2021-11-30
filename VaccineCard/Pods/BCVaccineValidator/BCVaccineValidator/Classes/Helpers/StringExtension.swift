//
//  String.swift
//  VaccineCard
//
//  Created by Amir Shayegh on 2021-08-28.
//

import Foundation
import CommonCrypto

extension String {
    
    func md5Base64() -> String? {
        guard let messageData = self.data(using:.utf8) else {
            return nil
        }
        let length = Int(CC_MD5_DIGEST_LENGTH)
        
        var digestData = Data(count: length)
        
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData.base64EncodedString()
    }
    
    func chunks(size: Int) -> [String] {
        map { $0 }.chunks(size: size).compactMap { String($0) }
    }
    
    public func base64Decoded() -> String? {
        var st = self
            .replacingOccurrences(of: "_", with: "/")
            .replacingOccurrences(of: "-", with: "+")
        let remainder = self.count % 4
        if remainder > 0 {
            st = st.padding(toLength: st.count + 4 - remainder,
                            withPad: "=",
                            startingAt: 0)
        }
        guard let d = Data(base64Encoded: st, options: .ignoreUnknownCharacters) else{
            return nil
        }
        return String(data: d, encoding: .utf8)
    }
    
    public func base64DecodedData() -> Data? {
        var st = self
            .replacingOccurrences(of: "_", with: "/")
            .replacingOccurrences(of: "-", with: "+")
        let remainder = self.count % 4
        if remainder > 0 {
            st = st.padding(toLength: st.count + 4 - remainder,
                            withPad: "=",
                            startingAt: 0)
        }
        return Data(base64Encoded: st, options: .ignoreUnknownCharacters)
    }
}

extension String {
    func filePathSafeName() -> String {
        return self.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "http://", with: "").replacingOccurrences(of: "/", with: "~")
    }
    func filePathSafeNameToURL() -> String {
        return "https://\(self.replacingOccurrences(of: "~", with: "/"))"
    }
}

extension String {
    func removeWellKnownJWKS_URLExtension() -> String {
        return self.replacingOccurrences(of: "/\(Constants.JWKSPublic.wellKnownJWKS_URLExtension)", with: "")
    }
    func addWellKnownJWKS_URLExtension() -> String {
        return "\(self.removeWellKnownJWKS_URLExtension())/\(Constants.JWKSPublic.wellKnownJWKS_URLExtension)"
    }
}
