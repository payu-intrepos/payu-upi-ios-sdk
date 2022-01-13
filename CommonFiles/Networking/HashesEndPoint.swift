//
//  HashesEndPoint.swift
//  SampleApp
//
//  Created by Vipin Aggarwal on 23/07/19.
//  Copyright © 2019 PayU Payments Pvt. Ltd. All rights reserved.
//

import Foundation
import PayUUPICoreKit
import PayUNetworkingKit
import PayUParamsKit

enum HashAPI {
    case generateHash(params: PayUPaymentParam)
}

extension HashAPI: PayUEndPointType {
    var baseURL: URL {
        guard let url = URL(string: "https://payu.herokuapp.com/") else { fatalError("baseURL could not be configured.")}
        return url
    }

    var path: String {
        switch self {
        case .generateHash:
            return "get_hash"
        }
    }

    var httpMethod: PayUHTTPMethod {
        return .post
    }

    var task: PayUHTTPTask {
        switch self {
        case .generateHash(let params):
            let udf1 = params.udfs?.udf1 ?? ""
            let udf2 = params.udfs?.udf2 ?? ""
            let udf3 = params.udfs?.udf3 ?? ""
            let udf4 = params.udfs?.udf4 ?? ""
            let udf5 = params.udfs?.udf5 ?? ""
            let paymentOption = params.paymentOption as? UPI
            return .requestParameters(bodyParameters: nil,
                                      urlParameters: ["key": params.key,
                                                      "txnid": params.transactionId,
                                                      "amount": params.amount,
                                                      "productinfo": params.productInfo,
                                                      "firstname": params.firstName,
                                                      "email": params.email,
                                                      "udf1": udf1,
                                                      "udf2": udf2,
                                                      "udf3": udf3,
                                                      "udf4": udf4,
                                                      "udf5": udf5,
                                                      "user_credentials": params.userCredential ?? "",
                                                      "vpa": paymentOption?.vpa ?? ""])
        }
    }

    var destination: PayUEncodingDestination? {
        return .queryString
    }
}
