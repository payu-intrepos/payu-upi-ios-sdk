//
//  ChoosePaymentOptionVC.swift
//  SampleApp
//
//  Created by Vipin Aggarwal on 04/09/19.
//  Copyright © 2019 PayU Payments Pvt. Ltd. All rights reserved.
//

import UIKit

import PayUUPICoreKit
import PayUUPIKit

class ChoosePaymentOptionVC: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var tableView: UITableView!

    let activityIndicator = ActivityIndicator()

    var paymentParams: PayUPaymentParams?
    var allUpiPaymentOptions: PayUUPIPaymentOptions?
    var intentModel: PayUPureS2SModel?

    var dummyPaymentOptions:[PaymentType] = [.cards, .emi, .netBanking, .wallet]
    var allPaymentOptions: [PaymentType] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        tableView.tableFooterView = UIView()
        computeAllAvailablePaymentOptions()
    }

    func computeAllAvailablePaymentOptions() {
        allPaymentOptions = getAllPaymentOptions()
    }

    func isUPICollectAvailable() -> Bool {
        if allUpiPaymentOptions?.upi == nil {
            return false
        } else {
            return true
        }
    }

    func getPayUUPIOPtions() -> [PayUPaymentType] {
        var options: [PayUPaymentType] = []

        if PayUUPICore.canUseUpiCollect(withPaymentOptions: allUpiPaymentOptions!) {
            options.append(.upiCollect)
        }

        if PayUUPICore.canUseGpayOmni(withPaymentOptions: allUpiPaymentOptions!) ||
            PayUUPICore.canUseGpayCollect(withPaymentOptions: allUpiPaymentOptions!) {
            options.append(.gpayFallback)
        }

        if let intentApps = allUpiPaymentOptions?.intent?.supportedApps {
            for app in intentApps {
                if app.name == "phonepe" && PayUUPICore.canUseIntent(forApp: app, withUpiOptions: allUpiPaymentOptions!) {
                    options.append(.intent(withApp: app))
                }

                if app.name == "gpay" && PayUUPICore.canUseGpayApp(withPaymentOptions: allUpiPaymentOptions!) {
                    if let index = options.firstIndex(of: .gpayFallback) { //Do not use fallback if gpay app options is available
                        options.remove(at: index)
                    }
                    options.append(.intent(withApp: app))
                }
            }
        }

        return options
    }


    func getAllPaymentOptions() -> [PaymentType] {

        var allPaymentOptionsList: [PaymentType] = dummyPaymentOptions
        let upiOptions = getPayUUPIOPtions()

        for option in upiOptions {

            switch option {

            case .upiCollect:
                allPaymentOptionsList.append(.upiCollect)

            case .intent(let app):
                if app.name == "gpay" {
                    allPaymentOptionsList.append(.gpay(appData: app))
                }
                if app.name == "phonepe" {
                    allPaymentOptionsList.append(.phonepe(appData: app))
                }

            case .gpayFallback:
                allPaymentOptionsList.append(.gpayFallback)

            default: break
            }


        }

        return allPaymentOptionsList
    }
}

extension ChoosePaymentOptionVC {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPaymentOptions.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 57
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PaymentOptionCell

        cell.setupCell(forPaymentType: allPaymentOptions[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPaymentOption = allPaymentOptions[indexPath.row]

        switch selectedPaymentOption {
        case .gpay, .gpayFallback, .phonepe, .upiCollect:
            initiateUpiPayment(withType: selectedPaymentOption)

        default:
            showAlertForTraditionalPaymentOption(allPaymentOptions[indexPath.row])
        }
    }

    func initiateUpiPayment(withType paymentType : PaymentType) {

        DispatchQueue.main.async { [weak self] in

            guard let self = self else {return}
            switch paymentType {
            case .phonepe(let app), .gpay(let app):
                self.initiateIntentPayment(withApp: app,
                                            paymentParams: self.paymentParams!,
                                            availableUpiOptions: self.allUpiPaymentOptions!)
            case .upiCollect:

                self.initiateCollectPayment(withScreenType: .upi,
                                             paymentParams: self.paymentParams!,
                                             availableUOptions: self.allUpiPaymentOptions!)
            case .gpayFallback:
                self.initiateCollectPayment(withScreenType: .gpayFallback,
                                            paymentParams: self.paymentParams!,
                                            availableUOptions: self.allUpiPaymentOptions!)
            default:
                print("Unknown UPI payment option - not implemented yet")
            }
        }


    }

    func initiateIntentPayment(withApp app: PayUSupportedIntentApp,
                               paymentParams params: PayUPaymentParams,
                               availableUpiOptions upiOptions: PayUUPIPaymentOptions) {

        let paymentVC = PayUIntentPaymentVC()
        paymentVC.availableUpiOptions = upiOptions
        paymentVC.paymentApp = app
        paymentVC.paymentParams = params

        navigationController?.pushViewController(paymentVC, animated: false)
    }

    func initiateCollectPayment(withScreenType type: PayUCollectScreenType,
                                paymentParams params: PayUPaymentParams,
                                availableUOptions upiOptions: PayUUPIPaymentOptions) {
        let collectVC = PayUUPI.getCollectPaymentVC()
        collectVC.paymentParams = params
        collectVC.screenType = type

        collectVC.availablePaymentOptions = upiOptions
        self.navigationController?.pushViewController(collectVC, animated: true)
    }


    func showAlertForTraditionalPaymentOption(_ option: PaymentType) {

        DispatchQueue.main.async() {
            let alert = UIAlertController(title: "Paying the old way?", message: "Use our traditional SDK for CC/DC/EMI/NB/Wallet payments", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Show me how", style: .default, handler: { (_) in
                guard let url = URL(string: "https://github.com/payu-intrepos/Documentations/wiki/iOS-SDK-integration") else { return }
                UIApplication.shared.open(url)
            }))

            alert.addAction(UIAlertAction(title: "Stay here", style: .default, handler: { (_) in
            }))

            self.present(alert, animated: true, completion: nil)
        }
    }
}
