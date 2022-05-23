//
//  Helper.swift
//  PayuSampleproject
//
//  Created by Shubham Garg on 23/05/22.
//

import Foundation
import UIKit
import PayUParamsKit
import CommonCrypto
class Helper  {
    
    class func showAlert(title: String, message: String, vc: UIViewController) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        vc.present(alert, animated: true, completion: nil)
    }
    
    // MARK:- Hash Helper, DONT CALCULATE HASH AT CLIENT SIDE, ONLY SERVER SIDE SHOULD CALCULATE HASH FOR BETTER SECURITY -
    
    class func getHashes(params: PayUPaymentParam, salt: String) -> PPKHashes {
        let payuHashes = PPKHashes()
        payuHashes.paymentOptionsHash = paymentOptionsHash(params: params, salt: salt)
        payuHashes.paymentHash = paymentHash(params: params, salt: salt)
        payuHashes.validateVPAHash = vpaHash(params: params, salt: salt)
        params.hashes = payuHashes
        return payuHashes
    }

    class func sha512Hex( string: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
        if let data = string.data(using: String.Encoding.utf8) {
            let value =  data as NSData
            CC_SHA512(value.bytes, CC_LONG(data.count), &digest)

        }
        var digestHex = ""
        for index in 0..<Int(CC_SHA512_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }

        return digestHex
    }
    
    class func paymentOptionsHash(params: PayUPaymentParam, salt: String) -> String {
        let paymentOptionsString = "\(params.key)|payment_related_details_for_mobile_sdk|\(params.userCredential ?? "")|\(salt)"
        return sha512Hex(string: paymentOptionsString)
    }
    
    class func paymentHash(params: PayUPaymentParam, salt: String) -> String {
        // Payment hash   sha512(key|txnid|amount|productinfo|firstname|email|udf1|udf2|udf3|udf4|udf5||||||SALT)
        
        var beneficiaryDetails = ""
        
        
        if let accountNo = params.paymentOption?.beneficiaryAccountNumber, !accountNo.isEmpty {
            var ifscString = ""
            if let ifsc = params.paymentOption?.beneficiaryAccountIFSC, !ifsc.isEmpty {
                ifscString = ",\"ifscCode\":\"\(ifsc)\""
            }
            beneficiaryDetails = "{\"beneficiaryAccountNumber\":\"\(accountNo)\"\(ifscString)}|"
        }

        let paymentHashString = "\(params.key)|\(params.transactionId)|\(params.amount)|\(params.productInfo)|\(params.firstName)|\(params.email)|\(params.udfs?.udf1 ?? "")|\(params.udfs?.udf2 ?? "")|\(params.udfs?.udf3 ?? "")|\(params.udfs?.udf4 ?? "")|\(params.udfs?.udf5 ?? "")||||||\(beneficiaryDetails)\(salt)"
        return sha512Hex(string: paymentHashString)
    }
    
    class func vpaHash(params: PayUPaymentParam, salt: String) -> String {
        let paymentOption = params.paymentOption as? UPI
        let validateVPAString = "\(params.key)|validateVPA|\(paymentOption?.vpa ?? "")|\(salt)"
        return sha512Hex(string: validateVPAString)
    }
}
