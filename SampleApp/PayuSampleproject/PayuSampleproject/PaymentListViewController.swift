//
//  PaymentListViewController.swift
//  PayuSampleproject
//
//  Created by Shubham Garg on 20/05/22.
//

import UIKit
import PayUUPICoreKit
import PayUParamsKit

class PaymentListViewController: UIViewController {
    var paymentOptions: PayUUPIPaymentOptions?
    @IBOutlet weak var tableView: UITableView!
    var paymentParam:PayUPaymentParam?
    var salt: String?
    var upiPayment = UPIPayment()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.setupCallbacks()
        // Do any additional setup after loading the view.
    }
    
    func setupCallbacks() {
        PayUUPICore.shared.paymentCompletion = { [weak self] result in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {return}
                    self.navigationController?.popToRootViewController(animated: false)

                    switch result {
                    case .success(let response):
                        print(response)
                        Helper.showAlert(title: "Success", message: "\(response)", vc: self)
                    case .failure(let error):
                        print(error.localizedDescription)
                        print((error as PayUError).message ?? error.localizedDescription)
                        Helper.showAlert(title: "Error", message: ((error as PayUError).message ?? error.localizedDescription), vc: self)
                    }
                }
        }
        
        PayUUPICore.shared.backPressed = {[weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
        
        PayUUPICore.shared.onEnteringVPA = {[weak self] vpa, completion in
            guard let self = self else { return }

            (self.paymentParam?.paymentOption as? UPI)?.vpa = vpa
            Helper.getHashes(params: self.paymentParam!, salt: self.salt ?? "")
        }
    }

}
extension PaymentListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if paymentOptions?.upi != nil {
            count += 1
        }
//        if paymentOptions?.tez != nil {
//            count += 1
//        }
//        if paymentOptions?.tezOmni != nil {
//            count += 1
//        }
        if paymentOptions?.intent != nil {
            count += 1
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var count = 0
        if paymentOptions?.upi != nil {
            if indexPath.row == count {
                cell.textLabel?.text = "UPI Collect"
            }
            count += 1
        }
//        if paymentOptions?.tez != nil {
//            if indexPath.row == count {
//                cell.textLabel?.text = "Tez"
//            }
//            count += 1
//        }
//        if paymentOptions?.tezOmni != nil {
//            if indexPath.row == count {
//                cell.textLabel?.text = "Tez Omni"
//            }
//            count += 1
//        }
        if paymentOptions?.intent != nil, indexPath.row == count {
            cell.textLabel?.text = "UPI Intent"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var count = 0
        if paymentOptions?.upi != nil{
            if indexPath.row == count {
                //1. Create the alert controller.
                let alert = UIAlertController(title: "UPI Collect", message: "Validate VPA", preferredStyle: .alert)

                //2. Add the text field. You can configure it however you need.
                alert.addTextField { (textField) in
                    textField.placeholder = "Enter VPA"
                }

                // 3. Grab the value from the text field, and print it when the user clicks OK.
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                    let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
                    (self.paymentParam?.paymentOption as? UPI)?.vpa = textField?.text
                    self.paymentParam?.hashes?.validateVPAHash =  Helper.vpaHash(params: self.paymentParam!, salt: self.salt ?? "")
                    PayUAPI.validateVPA(withPaymentParams: self.paymentParam!) { (result) in
                        switch result {
                        case .success(let model):
                            if model.status != "Failure" {
                                DispatchQueue.main.async {
                                    Helper.showAlert(title: "Payment Inittiated", message: "payment initiated to \(model.payerAccountName)", vc: self)
                                }
                                
                                self.upiPayment.makePayment(with: self.paymentParam!)
                            } else {
                                print(model.msg)
                            }
                            
                            break
                        case .failure(let error):
                            print(error)
                        }
                    }
                }))

                // 4. Present the alert.
                self.present(alert, animated: true, completion: nil)
            }
            count += 1
        }
//        if paymentOptions?.tez != nil {
//            if indexPath.row == count {
//
//            }
//            count += 1
//        }
//        if paymentOptions?.tezOmni != nil {
//            if indexPath.row == count {
//
//            }
//            count += 1
//        }
        if paymentOptions?.intent != nil, indexPath.row == count {
            // For Custom UI
//            if let paymentOptions = paymentOptions {
//                let installedApp = PayUUPICore.getInstalledAppsList(forUpiOptions: paymentOptions)
//                if installedApp.count > 0 {
//                    upiPayment.makePayment(with: paymentParam!, upiSupportedApp: installedApp.first!)
//                } else {
//                    print("No apps available for intent flow")
//                }
//            } else {
//                print("Invalid params")
//            }

            // For Default UI
            let paymentVC = PayUIntentPaymentVC()
            paymentVC.availableUpiOptions = paymentOptions

            let installedApp = PayUUPICore.getInstalledAppsList(forUpiOptions: paymentOptions!)

            paymentVC.paymentApp = installedApp.first //object of type 'PayUSupportedIntentApp'
            paymentVC.paymentParams = self.paymentParam

            navigationController?.pushViewController(paymentVC, animated: false)
        }
        
        
        
    }
    
    
}


