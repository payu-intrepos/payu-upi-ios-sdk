//
//  OrderPageVC.swift
//  SampleApp
//
//  Created by Vipin Aggarwal on 29/08/19.
//  Copyright © 2019 PayU Payments Pvt. Ltd. All rights reserved.
//

import UIKit
import PayUUPICore
import PayUNetworking
import PayULogger

class OrderPageVC: UIViewController {

    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!

    var availablePaymentOptions: PayUUPIPaymentOptions?
    var paymentParams: PayUPaymentParams?
    let activityIndicator = ActivityIndicator()
    var snackBar = PayUSnackBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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

    func setupPayUCallbackHandlers() {
        setupPaymentCompletionHandler()
        setupOnEnteringVPAHandler()
        setupBackpressHandler()
    }

    func setupPaymentParams() -> Bool {
        PayUUPICore.shared.logLevel = .error
        PayUUPICore.shared.environment = .mobiletest
        do {
          paymentParams = try PayUPaymentParams(
            merchantKey: PayUUPICore.shared.environment == .production ? "smsplus" : "obScKz", //Your merchant key for the current environment
            transactionId: randomString(length: 6), //Your unique ID for this trasaction
            amount: self.amountTextField.text ?? "1", //Amount of transaction
            productInfo: "iPhone", // Description of the product
            firstName: "Vipin", // First name of the user
            email: "johnappleseed@apple.com", // Email of the useer
            //User defined parameters.
            //You can save additional details with each txn if you need them for your business logic.
            //You will get these details back in payment response and transaction verify API
            //Like, you can add SKUs for which payment is made.
            udf1: "",
            //You can keep all udf fields blank if you do not have any requirement to save your custom txn specific data at PayU's end
            udf2: "",
            udf3: "",
            udf4: "",
            udf5: "")
          paymentParams?.userCredentials = "smsplus:myUserEmail@payu.in" // "merchantKey:user'sUniqueIdentifier"
          paymentParams?.surl = "https://payu.herokuapp.com/ios_success" // Success URL. Not used but required due to mandatory check in API.
          paymentParams?.furl = "https://payu.herokuapp.com/ios_failure" // Failure URL. Not used but required due to mandatory check in API.
          paymentParams?.phoneNumber = mobileTextField.text ?? "9123456789" // "10 digit phone number here"
          return true
        } catch let error as PayUError {
            Helper.showAlert("Could not create post params due to: \(error.description)", onController: self)
            return false
        } catch {
            Helper.showAlert("Could not create post params due to: \(error.localizedDescription)", onController: self)
            return false
        }
    }

    func fetchHashes(withParams params: PayUPaymentParams,
                                      completion: @escaping(Result<Bool, SampleAppError> )->()) {

        APIManager().getHashes(params: paymentParams!) {[weak self] (hashes, error) in
            guard let self = self else { return }

            if let error = error {
                completion(.failure(error))
            }

            if let hashes = hashes {
                print(hashes)
                self.paymentParams?.hashes = self.getPayUHashesModel(fromHashes: hashes)

                completion(.success(true))

            } else {
                completion(.failure(.error(SampleAppError.hashError)))
            }
        }
    }

    func fetchPaymentOptions(withParams params: PayUPaymentParams,
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

    func getPayUHashesModel(fromHashes hashes: Hashes) -> PayUHashes{
        var payuHashes = PayUHashes()
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

            self.paymentParams?.vpa = vpa
            self.fetchHashes(withParams: self.paymentParams!) { result in
                switch result {
                case .success:
                    completion(.success(self.paymentParams!))
                case .failure(let error):
                    print("Could not fetch hashes \(error.description)")
                    completion(.failure(.noInternet))
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
