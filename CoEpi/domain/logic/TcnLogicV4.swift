import Foundation
import CryptoKit
import os.log

class TcnLogicV4 {
    /**
       Parameter Choices. We implement

       H_tck using SHA256 with domain separator b"H_TCK";
       H_tcn using SHA256 with domain separator b"H_TCN";
       rak and rvk as the signing and verification keys of Ed25519.
       These parameter choices result in signed reports of 134-389 bytes or unsigned reports of 70-325 bytes, depending on the length of the memo field.
       
       tck_0 ← H_tck(rak)
       tck_1 ← H_tck(rvk || tck_0)
       
       const H_TCK_DOMAIN_SEP: &[u8; 5] = b"H_TCK";
       const H_TCN_DOMAIN_SEP: &[u8; 5] = b"H_TCN";
       
       */
    
    let tckDomainSeparator : [UInt8] = [UInt8]("H_TCK".utf8)
    let tcnDomainSeparator : [UInt8] = [UInt8]("H_TCN".utf8)
    let privateKeyBytes : [UInt8]
    let publicKeyBytes : [UInt8]
    
    let tck_0 : SHA256.Digest
    let tck_1 : SHA256.Digest
    
    let keySize = 32
    
    init() {
        //https://developer.apple.com/documentation/cryptokit/performing_common_cryptographic_operations
        //Generates a new X25519 private key.
        let coepiPrivateKey = Curve25519.KeyAgreement.PrivateKey()
        let coepiPublicKey = coepiPrivateKey.publicKey
 
        
        privateKeyBytes = [UInt8](coepiPrivateKey.rawRepresentation)
        os_log("PrivateKey bytes <rak>: %{public}@", type: .debug, privateKeyBytes)
        publicKeyBytes = [UInt8](coepiPrivateKey.publicKey.rawRepresentation)
        os_log(.debug, "PublicKey bytes <rvk>: %{public}@", publicKeyBytes)
        
        //tck_0 ← H_tck(rak)
        var buffer = tckDomainSeparator
        buffer.append(contentsOf: privateKeyBytes)
        tck_0 = SHA256.hash(data: buffer)
        
        //tck_1 ← H_tck(rvk || tck_0)
        var buffer1 = tckDomainSeparator
        buffer1.append(contentsOf: publicKeyBytes)
        buffer1.append(contentsOf: tck_0)
        tck_1 = SHA256.hash(data: buffer1)

    }
    
    func tckRatchet(previousKeyBytes: [UInt8]) -> [UInt8]{
        var buffer = tckDomainSeparator
        buffer.append(contentsOf: publicKeyBytes)
        buffer.append(contentsOf: previousKeyBytes)

        let tck = SHA256.hash(data: buffer)
        os_log(.debug, "Generated key <tck>: <%{public}@>", ([UInt8](Data(tck))).description)
        return [UInt8](tck)
    }
    
    func tcnGeneration(index: UInt16, tck: [UInt8]) -> [UInt8]{
        /**
         TCN Generation. A temporary contact number is derived from a temporary contact key by computing

         tcn_i ← H_tcn(le_u16(i) || tck_i),
         where H_tcn is a domain-separated hash function with 128 bits of output.
         
               ┌───┐
           ┌──▶│rvk│───────┬─────────┬──────────┬─────────┬─────────┐
           │   └───┘       │         │          │         │         │
         ┌───┐       ┌─────┐ │  ┌─────┐ │  ┌─────┐ │          │  ┌─────┐ │
         │rak│──────▶│tck_0│─┴─▶│tck_1│─┴─▶│tck_2│─┴─▶  ...  ─┴─▶│tck_n│─┴─▶...
         └───┘       └─────┘    └─────┘    └─────┘               └─────┘
                                   │          │                     │
                                   ▼          ▼                     ▼
                                ┌─────┐    ┌─────┐               ┌─────┐
                                │tcn_1│    │tcn_2│      ...      │tcn_n│
                                └─────┘    └─────┘               └─────┘
         
         */
        
        var indexArray : [UInt8] = [UInt8](repeating: 0, count: 2)

        indexArray[0] = UInt8(index >> 8)
        indexArray[1] = UInt8(index & 0x00ff)

        var buffer = tcnDomainSeparator
        buffer.append(contentsOf: indexArray)
        buffer.append(contentsOf: tck)

        let tcn = SHA256.hash(data: buffer)
        let shortTcn = [UInt8](tcn.dropLast(16))
        os_log(.debug, "TCN[%d] : %{public}@", index, shortTcn.description)
        return[UInt8](tcn)
        
    }
    
    func memoGeneration() -> [UInt8]{
        var stamp = Int64(Date().timeIntervalSince1970)
        os_log(.debug, "Payload: <%{public}lld>", stamp)
        var buffer: [UInt8] = [0x0]
        var memoDataArray: [UInt8] = [UInt8](repeating: 0, count: 8)
        
        for var i in 0...7 {
            let x = UInt8(stamp & 0x00ff)
            memoDataArray[7 - i] = x
            stamp = stamp >> 8
        }

        buffer.append(UInt8(memoDataArray.count))
        buffer.append(contentsOf: memoDataArray)
        os_log(.debug, "Memo: <%{public}@>", buffer.description)
        return buffer
        
    }
    
    func reportGeneration(preceedingTck: [UInt8], startIndex: UInt16, endIndex: UInt16, memo: [UInt8]) -> [UInt8] {
        var buffer = publicKeyBytes
        buffer.append(contentsOf: preceedingTck)
        
        var startArray : [UInt8] = [UInt8](repeating: 0, count: 2)
        var endArray: [UInt8] = [UInt8](repeating: 0, count: 2)

        startArray[0] = UInt8(startIndex >> 8)
        startArray[1] = UInt8(startIndex & 0x00ff)
        endArray[0] = UInt8(endIndex >> 8)
        endArray[1] = UInt8(endIndex & 0x00ff)
        
        buffer.append(contentsOf: startArray)
        buffer.append(contentsOf: endArray)
        buffer.append(contentsOf: memo)
        
        return buffer
    }
    
    func parseReport(_ report: [UInt8]){
        let rvkSlice = report[0...keySize-1]
        let tckSlice = report[keySize...2*keySize-1 ]
        let startIndexSlice = report[2*keySize...2*keySize+1]
        let endIndexSlice = report[2*keySize+2...2*keySize+3]
        let memoStart = 2*keySize+4
        let memoSlice = report[memoStart...]
        
        os_log(.debug, "-------------------")
        os_log(.debug, "rvk: <%{public}@>", rvkSlice.description)
        os_log(.debug, "tck: <%{public}@>", tckSlice.description)
        os_log(.debug, "startIndex <%{public}@>", startIndexSlice.description)
        os_log(.debug, "endIndex <%{public}@>", endIndexSlice.description)
        os_log(.debug, "memo <%{public}@>", memoSlice.description)
        
        var tck = Array(tckSlice)
        var tcn:[UInt8]
        
        let startIndex = Array(startIndexSlice)
        let endIndex = Array(endIndexSlice)
        
        let start: UInt16 = UInt16(startIndex[0]) * 256 + UInt16(startIndex[1])
        let end: UInt16 = UInt16(endIndex[0]) * 256 + UInt16(endIndex[1])
 
        os_log(.debug, "Start <%{public}d>", start)
        os_log(.debug, "End <%{public}d>", end)
        
        for i: UInt16 in start...end {
            os_log(.debug, "%d", i)
            tck = tckRatchet(previousKeyBytes: tck)
            tcn = tcnGeneration(index: i, tck: tck)
        }
    }
    

}
