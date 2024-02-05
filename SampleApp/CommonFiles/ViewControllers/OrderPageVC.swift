//
//  OrderPageVC.swift
//  SampleApp
//
//  Created by Vipin Aggarwal on 29/08/19.
//  Copyright © 2019 PayU Payments Pvt. Ltd. All rights reserved.
//

import UIKit
import PayUUPICoreKit
import PayUNetworkingKit
import PayULoggerKit
import PayUParamsKit

class OrderPageVC: UIViewController {

    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    
    @IBOutlet weak var tpvTxnSwitch: UISwitch!
    @IBOutlet weak var tpvElementsView: UIView!
    
    @IBOutlet weak var accNoTextField: UITextField!
    @IBOutlet weak var ifscTextField: UITextField!
    
    
    var availablePaymentOptions: PayUUPIPaymentOptions?
    var paymentParams: PayUPaymentParam?
    let activityIndicator = ActivityIndicator()
    var snackBar = PayUSnackBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        PayUSnackBar().show()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    func setupUI() {
        self.amountTextField.text = "1"
        self.mobileTextField.text = "9123456789"
    }

    func setupPayUCallbackHandlers() {
        setupPaymentCompletionHandler()
        setupOnEnteringVPAHandler()
        setupBackpressHandler()
    }

    func setupPaymentParams() -> Bool {
        PayUUPICore.shared.logLevel = .verbose
        PayUUPICore.shared.environment = .production
        paymentParams = PayUPaymentParam(
            key: "<key>", //Your merchant key for the current environment
            transactionId: randomString(length: 6), //Your unique ID for this trasaction
            amount: self.amountTextField.text ?? "1", //Amount of transaction
            productInfo: "iPhone", // Description of the product
            firstName: "Vipin", // First name of the user
            email: "johnappleseed@apple.com", // Email of the useer
            phone: "9528340384", // "10 digit phone number here"
            surl: "https://cbjs.payu.in/sdk/success", // Success URL. Not used but required due to mandatory check in API.
            furl: "https://cbjs.payu.in/sdk/failure", // Failure URL. Not used but required due to mandatory check in API.
            environment: .production // Production or Test . Not used but required due to mandatory parameter.
        )
        //User defined parameters.
        //You can save additional details with each txn if you need them for your business logic.
        //You will get these details back in payment response and transaction verify API
        //Like, you can add SKUs for which payment is made.
        //You can keep all udf fields blank if you do not have any requirement to save your custom txn specific data at PayU's end
        paymentParams?.udfs = PayUUserDefines()
        paymentParams?.udfs?.udf1 = ""
        paymentParams?.udfs?.udf2 = ""
        paymentParams?.udfs?.udf3 = ""
        paymentParams?.udfs?.udf4 = ""
        paymentParams?.udfs?.udf5 = ""
        
        paymentParams?.userCredential = "yIlrx4:myUserEmail@payu.in" // "merchantKey:user'sUniqueIdentifier"
        let upi = UPI()
        if tpvTxnSwitch.isOn {
            upi.beneficiaryAccountNumber = accNoTextField.text
            upi.beneficiaryAccountIFSC = ifscTextField.text
        } else {
            upi.beneficiaryAccountNumber = nil
            upi.beneficiaryAccountIFSC = nil
        }
        paymentParams?.paymentOption = upi
        return paymentParams != nil
    }

    func fetchHashes(withParams params: PayUPaymentParam,
                                      completion: @escaping(Result<Bool, SampleAppError> )->()) {
        let payuHashes = PPKHashes()
        payuHashes.paymentOptionsHash = "<paymentOptionsHash>"// Helper.paymentOptionsHash(params: params) calculate sha512 hash on server side using your salt
        payuHashes.paymentHash = "<paymentHash>" // Helper.paymentHash(params: params) calculate sha512 hash on server side using your salt
        payuHashes.validateVPAHash = "<validateVPAHash>" // Helper.vpaHash(params: params) calculate sha512 hash on server side using your salt
        paymentParams?.hashes = payuHashes
        
        completion(.success(true))

//        APIManager().getHashes(params: paymentParams!) {[weak self] (hashes, error) in
//            guard let self = self else { return }
//
//            if let error = error {
//                completion(.failure(error))
//            }
//
//            if let hashes = hashes {
//                print(hashes)
//                self.paymentParams?.hashes = self.getPayUHashesModel(fromHashes: hashes)
//
//                completion(.success(true))
//
//            } else {
//                completion(.failure(.error(SampleAppError.hashError)))
//            }
//        }
    }

    func fetchPaymentOptions(withParams params: PayUPaymentParam,
                             completion: @escaping( (Result<Bool, SampleAppError>)->() )) {

        PayUAPI.getUPIPaymentOptions(withPaymentParams: self.paymentParams!, completion: { [weak self] result in
            switch result {
            case .success(let paymentOptions):
                self?.availablePaymentOptions = paymentOptions
                completion(.success(true))
            case .failure(let payuError):
                print(payuError)
                completion(.failure(.error(payuError.description)))
            }
        })

    }

    // MARK: - Actions -
    

    @IBAction func openCheckout(_ sender: Any) {
        // get available payment options to help populated checout with only available payment options
        activityIndicator.startActivityIndicatorOn(view)
        let successfullySet = setupPaymentParams()
        if !successfullySet {
            self.activityIndicator.stopActivityIndicator()
            return
        }

        fetchHashes(withParams: paymentParams!) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.fetchPaymentOptions(withParams: self.paymentParams!, completion: { [weak self] result in
                    guard let self = self else { return }
                    self.activityIndicator.stopActivityIndicator()

                    switch result {
                    case .success:
                        DispatchQueue.main.async {
                            let checkoutVC = self.storyboard!.instantiateViewController(withIdentifier: "ChoosePaymentOptionVC") as! ChoosePaymentOptionVC
                            checkoutVC.allUpiPaymentOptions = self.availablePaymentOptions
                            checkoutVC.paymentParams = self.paymentParams
                            self.setupPayUCallbackHandlers()
                            self.navigationController?.pushViewController(checkoutVC, animated: true)
                        }

                    case .failure(let error):
                        Helper.showAlert(error.description, onController: self)
                    }
                })
            case .failure(let error):
                self.activityIndicator.stopActivityIndicator()
                print("Unable to fetch hashes: \(error)")
                Helper.showAlert(error.description, onController: self)
            }
        }
    }
    
    @IBAction func tpvSwitchValueChanged(_ sender: Any) {
        tpvElementsView.isHidden = !tpvTxnSwitch.isOn
    }
    

    // MARK: - Helper
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }

    func handleAPI(result: Result<PayUPureS2SModel, PayUError>) {
        switch result {
        case .success(let model):
            print(model)
        case .failure(let err):
            print("Error: \(err.description)")
        }
    }

    func getPayUHashesModel(fromHashes hashes: Hashes) -> PPKHashes{
        var payuHashes = PPKHashes()
        payuHashes.paymentOptionsHash = hashes.paymentOptionsHash
        payuHashes.paymentHash = hashes.paymentHash
        payuHashes.validateVPAHash = hashes.validateVPAHash

        return payuHashes
    }
}

extension OrderPageVC {

    fileprivate func setupPaymentCompletionHandler() {

        PayUUPICore.shared.paymentCompletion = { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                self.navigationController?.popToRootViewController(animated: false)

                switch result {
                case .success(let response):
                    Helper.showAlert(String(describing: response), onController: self)

                case .failure(let error):
                    Helper.showAlert(String(describing: error.description), onController: self)
                }
            }
        }
    }

    fileprivate func setupOnEnteringVPAHandler() {
        PayUUPICore.shared.onEnteringVPA = {[weak self] vpa, completion in
            guard let self = self else { return }
            (self.paymentParams?.paymentOption as? UPI)?.vpa = vpa
            self.fetchHashes(withParams: self.paymentParams!) { result in
                switch result {
                case .success:
                    completion(.success(self.paymentParams!))
                case .failure(let error):
                    print("Could not fetch hashes \(error.description)")
                    completion(.failure(.noInternet()))
                }
            }
        }
    }

    private func setupBackpressHandler() {
        PayUUPICore.shared.backPressed = {[weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }
}
