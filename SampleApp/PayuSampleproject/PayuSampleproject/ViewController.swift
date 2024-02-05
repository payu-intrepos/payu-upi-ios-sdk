//
//  MerchantViewController.swift
//  CheckoutProSwiftSampleApp
//
//  Created by Umang Arya on 14/07/20.
//  Copyright © 2020 PayU Payments Pvt Ltd. All rights reserved.
//

import UIKit
import PayUParamsKit
import UIKit
import PayUUPICoreKit

class MerchantViewController: UIViewController {
    // MARK: - Outlets -
    @IBOutlet weak var keyTextField: UITextField!
    @IBOutlet weak var saltTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var productInfoTextField: UITextField!
    @IBOutlet weak var surlTextField: UITextField!
    @IBOutlet weak var furlTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var environmentTextField: UITextField!
    @IBOutlet weak var userCredentialTextField: UITextField!
    @IBOutlet weak var txnIDTextField: UITextField!
    
    //SI
    @IBOutlet weak var siSwitch: UISwitch!
    @IBOutlet weak var billingIntervalTf: UITextField!
    @IBOutlet weak var siEndDateTf: UITextField!
    @IBOutlet weak var siStartDateTf: UITextField!
    @IBOutlet weak var recurringPeriodTf: UITextField!
    @IBOutlet weak var recurringAmountTf: UITextField!
    @IBOutlet weak var remarksTextField: UITextField!
    @IBOutlet weak var freeTrialSwitch: UISwitch!
    
    // Customization
    @IBOutlet weak var primaryColorTextField: UITextField!
    @IBOutlet weak var secondaryColorTextField: UITextField!
    @IBOutlet weak var merchantNameTextField: UITextField!
    @IBOutlet weak var logoNameTextField: UITextField!
    @IBOutlet weak var showCancelDialogOnCheckoutScreenSwitch: UISwitch!
    @IBOutlet weak var showCancelDialogOnPaymentScreenSwitch: UISwitch!
    @IBOutlet weak var orderDetailTextView: UITextView!
    @IBOutlet weak var l1OptionTextView: UITextView!
    @IBOutlet weak var offerDetailTextView: UITextView!
    
    
    // CB Configuration
    @IBOutlet weak var autoOTPSelectSwitch: UISwitch!
    @IBOutlet weak var surePayCountTextField: UITextField!
    @IBOutlet weak var merchantResponseTimeoutTextField: UITextField!
    
    // MARK: - Variables -
    let keySalt = [["3TnMpV", "<Enter_your_salt_here>", Environment.production]]

    let indexKeySalt = 0
    var amount: String = "1"
    var productInfo: String = "Nokia"
    var surl: String = "https://cbjs.payu.in/sdk/success"
    var furl: String = "https://cbjs.payu.in/sdk/failure"
    var firstName: String = "Umang"
    var email: String = "umang@arya.com"
    var phoneNumber: String = "9876543210"
    var userCredential: String = "umang:arya123"
    var primaryColor: String = "#053ac1"
    var secondaryColor: String = "#ffffff"
    var merchantName: String = "Gabbar"
    var logoName: String = "Logo"
    var showCancelDialogOnCheckoutScreen: Bool = true
    var showCancelDialogOnPaymentScreen: Bool = true
    var orderDetail: String = "[{\"GST\":\"5%\"},{\"Delivery Date\":\"25 Dec\"},{\"Status\":\"In Progress\"}]"
    var l1Option: String = "[{\"NetBanking\":\"\"},{\"emi\":\"\"},{\"UPI\":\"TEZ\"},{\"Wallet\":\"PHONEPE\"}]"
    var offerDetail: String = "[[\"5% off on cards and netbanking\",\"Get 5% instant discount on all cards and nb. Max 100\",\"cardnb@5\",\"Cards,NetBanking\",],[\"Cashback on cards and netbanking\",\"Cashback on cards and netbanking\",\"CASHBACK@8405\",\"Cards,NetBanking\"],[\"offer on cards and netbanking\",\"offer on cards and netbanking\",\"cardNBOfferKey@8645\",\"Cards,NetBanking\"],[\"Cashback on cards and netbanking\",\"Cashback on cards and netbanking\",\"cardOfferKey@8643\",\"Cards,NetBanking\"],]"
    var autoOTPSelect: Bool = true
    var surePayCount: String = "2"
    var merchantResponseTimeout: String = "4"
    var recurringAmount = "11"
    var recurringPeriod: PayUBillingCycle = .monthly
    var siStartDate:Date = Date()
    var siEndDate:Date = Date()
    var billingInterval = "1"
    var isFreeTrial = false
    var remarksText: String? = nil
    var datePicker : UIDatePicker!
    let toolBar = UIToolbar()
    @IBOutlet weak var nextButton: UIButton!
    var paymentParam:PayUPaymentParam?
    
    // MARK: - View Controller Lifecycle Methods -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        setUpValuesInTextFields()
        updateButtonColor()
        dismissKeyboardOnTapOutsideTextField()
        setUpDatePicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        txnIDTextField.text = "sdglkmsklfg"
        self.registerKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unRegisterKeyboardNotification()
    }
    
    func setUpDatePicker(){
        // DatePicker
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: view.frame.size.width, height: 200))
        self.datePicker?.backgroundColor = UIColor.white
        self.datePicker?.datePickerMode = UIDatePicker.Mode.date
        datePicker?.center = view.center
        if #available(iOS 13.4, *) {
            datePicker?.preferredDatePickerStyle = .wheels
        }
        // ToolBar
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.cancelClick))
        toolBar.setItems([cancelButton, spaceButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        siStartDateTf?.inputAccessoryView = toolBar
        siEndDateTf?.inputAccessoryView = toolBar
        //add datepicker to textField
        siStartDateTf?.inputView = datePicker
        siEndDateTf?.inputView = datePicker
        self.toolBar.isHidden = false
        //Default current date
        siStartDateTf?.text =  Date().dateString
        siEndDateTf?.text =  Date().dateString
        self.datePicker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
    }
    
   
    @objc func cancelClick () {
        self.siStartDateTf.resignFirstResponder()
        self.siEndDateTf.resignFirstResponder()
    }
        
    @objc func handleDatePicker(sender: UIDatePicker) {
        if siStartDateTf.isFirstResponder{
            self.siStartDateTf.text = sender.date.dateString
            self.siStartDate = sender.date
        }
        else if siEndDateTf.isFirstResponder{
            self.siEndDateTf.text = sender.date.dateString
            self.siEndDate = sender.date
        }
    }
    

    @IBAction func billingCycleBtnAxn(_ sender: Any) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for billingCycle in PayUBillingCycle.allCases{
            sheet.addAction(UIAlertAction(title: PPKUtils.billingCycleToString(billingCycle), style: .default, handler: { (action) in
                self.recurringPeriod = billingCycle
                self.recurringPeriodTf.text = action.title
            }))
            }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popoverController = sheet.popoverPresentationController {
            popoverController.sourceView = self.view
            if UIDevice.current.userInterfaceIdiom == .pad {
                popoverController.sourceRect = CGRect.init(x:self.view.bounds.midX-150, y:self.view.bounds.midY-100,width:0,height:0)
            }
        }
        self.present(sheet, animated: true, completion: nil)
    }
    
}

// MARK: - Private Methods -
extension MerchantViewController {
    private func updateButtonColor() {
        nextButton.backgroundColor = .black
        nextButton.setTitleColor(.white, for: .normal)
    }
    private func setupTextFields() {
        primaryColorTextField.addTarget(self, action: #selector(primaryColorTextFieldTapped), for: .allEvents)
        secondaryColorTextField.addTarget(self, action: #selector(secondaryColorTextFieldTapped), for: .allEvents)
    }
    
    private func setUpValuesInTextFields() {
        keyTextField.text = keySalt[indexKeySalt][0] as? String
        saltTextField.text = keySalt[indexKeySalt][1] as? String
        amountTextField.text = amount
        productInfoTextField.text = productInfo
        surlTextField.text = surl
        furlTextField.text = furl
        firstNameTextField.text = firstName
        emailTextField.text = email
        phoneTextField.text = phoneNumber
        environmentTextField.text = "Production"
        userCredentialTextField.text = userCredential
        primaryColorTextField.text = primaryColor
        secondaryColorTextField.text = secondaryColor
        merchantNameTextField.text = merchantName
        logoNameTextField.text = logoName
        showCancelDialogOnCheckoutScreenSwitch.isOn = showCancelDialogOnCheckoutScreen
        showCancelDialogOnPaymentScreenSwitch.isOn = showCancelDialogOnPaymentScreen
        orderDetailTextView.text = orderDetail
        l1OptionTextView.text = l1Option
        offerDetailTextView.text = offerDetail
        autoOTPSelectSwitch.isOn = autoOTPSelect
        surePayCountTextField.text = surePayCount
        merchantResponseTimeoutTextField.text = merchantResponseTimeout
        recurringAmountTf.text = recurringAmount
        recurringPeriodTf.text = PPKUtils.billingCycleToString(recurringPeriod)
        billingIntervalTf.text = billingInterval
        remarksTextField.text = remarksText
        freeTrialSwitch.isOn = isFreeTrial
        primaryColorTextFieldTapped()
        secondaryColorTextFieldTapped()
    }
    
    private func getPaymentParam() {
        PayUUPICore.shared.environment = .production
        PayUUPICore.shared.logLevel = .error
        paymentParam = PayUPaymentParam(key: keyTextField.text ?? "",
                                             transactionId: txnIDTextField.text ?? "",
                                             amount: amountTextField.text ?? "",
                                             productInfo: productInfoTextField.text ?? "",
                                             firstName: firstNameTextField.text ?? "",
                                             email: emailTextField.text ?? "",
                                             phone: phoneTextField.text ?? "",
                                             surl: surlTextField.text ?? "",
                                             furl: furlTextField.text ?? "",
                                            environment: .production)
        if let recurringAmount = self.recurringAmountTf.text,
            let frequency = billingIntervalTf.text,
            let frequencyInt = Int(frequency),
            siSwitch.isOn{
            let siInfo = PayUSIParams(billingAmount: recurringAmount,
                                      paymentStartDate: self.siStartDate,
                                      paymentEndDate: self.siEndDate,
                                      billingCycle: recurringPeriod,
                                      billingInterval: NSNumber(value: frequencyInt))
            siInfo.remarks = remarksTextField.text?.isEmpty ?? true ? nil : remarksTextField.text
            siInfo.isFreeTrial = freeTrialSwitch.isOn
            paymentParam?.siParam = siInfo
        }
        paymentParam?.userCredential = userCredentialTextField.text
        paymentParam?.udfs = PayUUserDefines()
        paymentParam?.udfs?.udf1 = ""
        paymentParam?.udfs?.udf2 = ""
        paymentParam?.udfs?.udf3 = ""
        paymentParam?.udfs?.udf4 = ""
        paymentParam?.udfs?.udf5 = ""
        paymentParam?.userCredential = "yIlrx4:myUserEmail@payu.in" // "merchantKey:user'sUniqueIdentifier"
        let upi = UPI()
        upi.beneficiaryAccountNumber = "" //for tpv transaction
        upi.beneficiaryAccountIFSC = ""//for tpv transaction
        paymentParam?.paymentOption = upi
        Helper.getHashes(params: paymentParam!, salt: saltTextField.text ?? "")

    }
    
  
    
    func setupCallbacks() {
        PayUUPICore.shared.paymentCompletion = { [weak self] result in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {return}
                    self.navigationController?.popToRootViewController(animated: false)

                    switch result {
                    case .success(let response):
                        Helper.showAlert(title: "Success", message: "\(response)", vc: self)
                    case .failure(let error):
                        Helper.showAlert(title: "Error", message: error.localizedDescription ?? "", vc: self)
                    }
                }
        }
        
        PayUUPICore.shared.backPressed = {[weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
        
        PayUUPICore.shared.onEnteringVPA = {[weak self] vpa, completion in
            guard let self = self else { return }

            (self.paymentParam?.paymentOption as? UPI)?.vpa = vpa
            Helper.getHashes(params: self.paymentParam!, salt: self.saltTextField.text ?? "")
        }
    }
    
}


extension MerchantViewController: UIGestureRecognizerDelegate {
    // MARK: - Dismiss Keyboard On Tap Outside TextField
    func dismissKeyboardOnTapOutsideTextField(addDelegate: Bool = false) {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(dismissKeyboard))
        if addDelegate {
            tapGesture.delegate = self
        }
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: - Keyboard Handling -
    
    func registerKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func unRegisterKeyboardNotification() {
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillChangeFrameNotification)
    }
    
    @objc func keyboardWillChange(notification: NSNotification) {
        let info = notification.userInfo!
        let endFrame = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let timeFrame = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let screenHeight = UIScreen.main.bounds.height
        
        let keyboardVisibleHeight = max(screenHeight - endFrame.minY, 0)
        
        for constraint in self.view.constraints {
            if constraint.firstAttribute == .bottom {
                // If first item is self's view then constant should be positive else it should be negative
                let multiplier = constraint.firstItem as? UIView == self.view ? 1 : -1
                constraint.constant =  CGFloat(multiplier) * keyboardVisibleHeight
            }
        }
        
        UIView.animate(withDuration: timeFrame) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Textfield Tapped Methods -
extension MerchantViewController {
    @objc func primaryColorTextFieldTapped() {
        updateButtonColor()
    }
    
    @objc func secondaryColorTextFieldTapped() {
        updateButtonColor()
    }
}

// MARK: - Button Tapped Next -
extension MerchantViewController {
    @IBAction func nextBtnTapped(_ sender: Any) {
        dismissKeyboard()
        getPaymentParam()
       
        PayUAPI.getUPIPaymentOptions(withPaymentParams: self.paymentParam!, completion: { [weak self] result in
             switch result {
             case .success(let paymentOptions):
                 print(paymentOptions)
                 
                 DispatchQueue.main.async {
                     var vc = self?.storyboard?.instantiateViewController(withIdentifier: "PaymentListViewController") as? PaymentListViewController
                     vc?.paymentOptions = paymentOptions
                     vc?.paymentParam = self?.paymentParam
                     vc?.salt = self?.saltTextField.text
                     self?.navigationController?.pushViewController(vc!, animated: true)
                 }
//                 self?.availablePaymentOptions = paymentOptions
//                 completion(.success(true))
             case .failure(let error):
                 print(error)
//                 completion(.failure(error))
             }
         })
    }
}



extension Date{
    var dateString:String{
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: self)
    }
}
