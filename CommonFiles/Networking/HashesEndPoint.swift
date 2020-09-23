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

enum HashAPI {
    case generateHash(params: PayUPaymentParams)
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
            return .requestParameters(bodyParameters: nil,
                                      urlParameters: ["key": params.merchantKey,
                                                      "txnid": params.transactionId,
                                                      "amount": params.amount,
                                                      "productinfo": params.productInfo,
                                                      "firstname": params.firstName,
                                                      "email": params.email,
                                                      "udf1": params.udf1,
                                                      "udf2": params.udf2,
                                                      "udf3": params.udf3,
                                                      "udf4": params.udf4,
                                                      "udf5": params.udf5,
                                                      "user_credentials": params.userCredentials ?? "",
                                                      "vpa": params.vpa ?? ""])
        }
    }

    var destination: PayUEncodingDestination? {
        return .queryString
    }
}
