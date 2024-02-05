//
//  Helper.swift
//  SampleApp
//
//  Created by Vipin Aggarwal on 29/08/19.
//  Copyright © 2019 PayU Payments Pvt. Ltd. All rights reserved.
//

import UIKit
import PayUUPICoreKit
import CommonCrypto
import PayUParamsKit

class Helper {
    class func showAlert(_ message:String, onController controller: UIViewController) {
        DispatchQueue.main.async() {
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in

            }))
            controller.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK:- Hash Helper, DONT CALCULATE HASH AT CLIENT SIDE, ONLY SERVER SIDE SHOULD CALCULATE HASH FOR BETTER SECURITY -
    class func paymentOptionsHash(params: PayUPaymentParam, salt: String) -> String {
        let paymentOptionsString = "\(params.key)|payment_related_details_for_mobile_sdk|\(params.userCredential ?? "")|"
        return paymentOptionsString
    }
    
    class func paymentHash(params: PayUPaymentParam) -> String {
        // Payment hash   sha512(key|txnid|amount|productinfo|firstname|email|udf1|udf2|udf3|udf4|udf5||||||SALT)
        
        var beneficiaryDetails = ""
        
        
        if let accountNo = params.paymentOption?.beneficiaryAccountNumber, !accountNo.isEmpty {
            var ifscString = ""
            if let ifsc = params.paymentOption?.beneficiaryAccountIFSC, !ifsc.isEmpty {
                ifscString = ",\"ifscCode\":\"\(ifsc)\""
            }
            beneficiaryDetails = "{\"beneficiaryAccountNumber\":\"\(accountNo)\"\(ifscString)}|"
        }

        let paymentHashString = "\(params.key)|\(params.transactionId)|\(params.amount)|\(params.productInfo)|\(params.firstName)|\(params.email)|\(params.udfs?.udf1 ?? "")|\(params.udfs?.udf2 ?? "")|\(params.udfs?.udf3 ?? "")|\(params.udfs?.udf4 ?? "")|\(params.udfs?.udf5 ?? "")||||||\(beneficiaryDetails)|"
        return paymentHashString
    }
    
    class func vpaHash(params: PayUPaymentParam) -> String {
        let paymentOption = params.paymentOption as? UPI
        let validateVPAString = "\(params.key)|validateVPA|\(paymentOption?.vpa ?? "")|"
        return validateVPAString
    }
}
