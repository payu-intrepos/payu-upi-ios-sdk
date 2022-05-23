//
//  Hashes.swift
//  SampleApp
//
//  Created by Vipin Aggarwal on 07/11/19.
//  Copyright © 2019 PayU Payments Pvt. Ltd. All rights reserved.
//

import Foundation

public struct Hashes: Codable {
    public let paymentOptionsHash, paymentHash, validateVPAHash: String?
    public let status: Int?
    public let message: String?

    public enum CodingKeys: String, CodingKey {
        case paymentOptionsHash = "payment_related_details_for_mobile_sdk_hash"
        case paymentHash = "payment_hash"
        case validateVPAHash = "validate_vpa_hash"
        case status, message
    }
}
