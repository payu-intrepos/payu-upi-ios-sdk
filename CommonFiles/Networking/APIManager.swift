//
//  APIManager.swift
//  SampleApp
//
//  Created by Vipin Aggarwal on 23/07/19.
//  Copyright © 2019 PayU Payments Pvt. Ltd. All rights reserved.
//

import Foundation
import PayUUPICore
import PayUNetworking

enum SampleAppError: Error {
    static let internetUnavailable = "Please check you internet connection"
    static let jsonDecoding = "Response is not in JSON format"
    static let hashError = "Hashes could not be generated"

    case error(_ message: String)

    var description: String {
        switch self {
        case .error(let message):
            return message
        }
    }
}

struct APIManager {

    func getHashes(params: PayUPaymentParams, completion: @escaping(_ hashes: Hashes?, _ error: SampleAppError?) ->()) {
        let router = PayURouter<HashAPI>()
        router.request(.generateHash(params: params)) { (data, error) in
            guard let data = data, error == nil else {
                completion(nil, .error(SampleAppError.internetUnavailable))
                return
            }

            do {
                let apiResponse = try JSONDecoder().decode(Hashes.self, from: data)
                if apiResponse.status == 0 { //Success case
                    completion(apiResponse, nil)
                } else {
                    completion(nil, .error(apiResponse.message ?? ""))
                }

            } catch let err {
                print(err)
                completion(nil, .error(SampleAppError.jsonDecoding))
            }
        }
    }
}
