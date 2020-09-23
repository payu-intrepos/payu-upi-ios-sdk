//
//  PaymentOptionCell.swift
//  SampleApp
//
//  Created by Vipin Aggarwal on 04/09/19.
//  Copyright © 2019 PayU Payments Pvt. Ltd. All rights reserved.
//

import UIKit
import PayUUPICoreKit

enum PaymentType {
    case cards
    case emi
    case netBanking
    case wallet
    case upiCollect
    case gpay(appData: PayUSupportedIntentApp)
    case gpayFallback
    case phonepe(appData: PayUSupportedIntentApp)

    var description: String {
        switch self {
        case .cards: return "Cards (Credit/Debit)"
        case .emi: return "EMI"
        case .netBanking: return "Net Banking"
        case .wallet: return "Wallets"
        case .upiCollect: return "UPI"
        case .gpay, .gpayFallback: return "Google Pay"
        case .phonepe: return "PhonePe"
        }
    }
}

class PaymentOptionCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var paymentOptionName: UILabel!

    var paymentType: PaymentType?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setupCell(forPaymentType type: PaymentType) {
        paymentType = type
        paymentOptionName.text = type.description

        setupIcon(forPaymentType: type)
    }

    private func setupIcon(forPaymentType type: PaymentType) {
        var image:UIImage!

        switch type {
        case .cards: image = UIImage(named: "cardIcon")
        case .emi: image = UIImage(named: "emiIcon")
        case .netBanking: image = UIImage(named: "netBankingIcon")
        case .wallet: image = UIImage(named: "walletIcon")
        case .upiCollect: image = UIImage(named: "upiIcon")
        case .gpay, .gpayFallback: image = UIImage(named: "gpayIcon")
        case .phonepe: image = UIImage(named: "phonepeIcon")
        }

        iconImageView.image = image
    }

}
