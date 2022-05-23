//
//  UPIPayment.swift
//  PayuSampleproject
//
//  Created by Shubham Garg on 23/05/22.
//

import Foundation
import PayUParamsKit
import PayUUPICoreKit
// MARK: - Payment Handling -Use this class as it is
class UPIPayment: NSObject {
    
    public var paymentApp: PayUPaymentApp?
    
    var responseHandler: PayUPaymentResponseHandler?

    //MARK:- For UPI Collect payment
    func makePayment(with param: PayUPaymentParam) {
        handleAppMovingToBackgroundOrForeground()
        PayUAPI.getDataForUPICollectPayment(withPaymentParams: param) {[weak self]  (result) in
            self?.handlePureS2SResult(result, forApi: .initiateUpiCollectS2s)
        }
    }
   
    
   
    
    func cancelTransaction() {
        self.responseHandler?.finishTransaction(isMerchantCancelling: true)
    }
    
    // MARK: - Private Functions -

    private func handlePureS2SResult(_ result: Result<PayUPureS2SModel, PayUError>,
                                     forApi api: PayUCoreAPI) {
        switch result {

        case .success(let model):
            PayUPersistentStore.saveSocketConnectionModel(model)
            DispatchQueue.main.async {[weak self] in
                self?.initializeResponseHandler()
            }

        case .failure(let error):
            print(error)
            PayUAnalyticsSender.sendAPIfailed(forAPI: api)

            if error.description == PayUSDKError.dataUnavailable {
                //internet failure
                print("Internet is not available!")
                return
            }

            //Although the transaction should not fail here, but we fail the txn in case incorrect phone number is entered in GPay omni
//            if api == .initiateGpayOmniS2s {
            sendPaymentCompletion(response: .failure(error), verificationMode: nil)
//            }

       }
    }

    private func handleAppMovingToBackgroundOrForeground() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appWillMoveToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appWillMoveToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    private func removeObserver() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
    }

    @objc private func appWillMoveToBackground() {
        saveStateAndCleanup()
    }

    private func saveStateAndCleanup() {
        guard let connectionModel = PayUPersistentStore.getSocketConnectionModel() else { return }

        if let remainingTime = responseHandler?.remainingSeconds {
            PayUPersistentStore.saveRemainingTxnSecsBeforeMovingToBackground(remainingTime, txnUniqueId: connectionModel.referenceId)
        }

        PayUPersistentStore.saveBackgroundEnteringTimeStamp(Date(), txnUniqueId: connectionModel.referenceId)
        responseHandler?.cleanUp();
    }

    @objc private func appWillMoveToForeground() {
        setupConnections()
    }

    private func setupConnections() {
        let transactionTimeRemaining = getRemainingTxnTime()

        if let connectionModel = PayUPersistentStore.getSocketConnectionModel() {
            initialiseResponseHandler(withModel: connectionModel, remainingTime: transactionTimeRemaining)
        } else {
            print("Response cannot be fetched. Empty connection model received")
        }
    }
    
    private func handleIntentPayment(forApp app: PayUSupportedIntentApp,
                             withResult result: Result<PayUPureS2SModel, PayUError>) {
        DispatchQueue.main.async { [weak self] in

            switch result {
            case .success(let intentModel):

                PayUPersistentStore.saveSocketConnectionModel(intentModel)

                PayUThirdPartyManager.makePayment(withApp: app,
                                                  withIntentModel: intentModel,
                                                  appSwitchingStatus: { _ in
                })

            case .failure(let error):
                print("Error occured: \(error.description)")

                let failedApi = PayUCoreAPI.initiateGenericIntentS2s
                PayUAnalyticsSender.sendAPIfailed(forAPI: failedApi)
                
                //Send failure to merchant
                self?.sendPaymentCompletion(response: .failure(error), verificationMode: nil)
            }
        }
    }

}

// MARK: - Socket Handling -

extension UPIPayment {
    
    private func initializeResponseHandler() {

        if let connectionModel = PayUPersistentStore.getSocketConnectionModel() {
            let transactionTimeRemaining = getRemainingTxnTime(model: connectionModel)
            
            initialiseResponseHandler(withModel: connectionModel, remainingTime: transactionTimeRemaining)
        } else {
            print("Response cannot be fetched. Empty connection model received")
        }
        
    }
    //MARK:- For intent payment
    func makePayment(with param: PayUPaymentParam, upiSupportedApp: PayUSupportedIntentApp) {
        handleAppMovingToBackgroundOrForeground()
        
        if upiSupportedApp.name == IntentApp.gpay {
            PayUAPI.getDataForGpayIntentPayment(withPaymentParams: param) { [weak self] result in
                self?.handleIntentPayment(forApp: upiSupportedApp, withResult: result)
            }
        } else {
            PayUAPI.getDataForIntentPayment(withPaymentParams: param) { [weak self] result in
                self?.handleIntentPayment(forApp: upiSupportedApp, withResult: result)
            }
        }
    }
 
    
    private func initialiseResponseHandler(withModel model: PayUPureS2SModel, remainingTime: Int) {

        responseHandler = PayUPaymentResponseHandler(withConnectionData: model,
                                                          remainingTime: remainingTime)
        connectionEstablished(withTxnTimeRemaining: remainingTime)

        addResponseHandleCallbacks()
    }
    

    private func connectionEstablished(withTxnTimeRemaining timeRemaining: Int?) {
        print("Connection restarted")
    }

    private func addResponseHandleCallbacks() {
        self.responseHandler?.responseCallback = { [weak self] response, mode in
            self?.sendPaymentCompletion(response: response, verificationMode: mode)
        }
    }

    private func sendPaymentCompletion(response: PayUResponseType,
                                       verificationMode mode: PayUPaymentVerificationMode?) {

        if let verificationMode = mode {
            sendAnalyticsOnTxnCompletion(withTxnResponse: response, verificationMode: verificationMode)
        }
        removeObserver()
        PayUUPICore.shared.paymentCompletion?(response)
    }

    private func sendAnalyticsOnTxnCompletion(withTxnResponse response: PayUResponseType,
                                              verificationMode mode: PayUPaymentVerificationMode) {

        let status = getStatusFromTxnResponse(response: response)
        PayUAnalyticsSender.sendTxnStatus(status)
        PayUAnalyticsSender.sendPaymentVerifidBy(mode)
        sendPaymentVerifiedInEvent()
        PayUAnalyticsEvent.transactionFinished()
    }

    private func sendPaymentVerifiedInEvent() {
        if let allotedTime = responseHandler?.allotedTimeForTxn,
            let remainingTime = responseHandler?.remainingSeconds {
            let timeConsumedInFetchinResponse = allotedTime - remainingTime
            PayUAnalyticsSender.sendPaymentVerifiedIn(timeConsumedInFetchinResponse)
        }

    }

    private func getStatusFromTxnResponse(response: PayUResponseType) -> String {

        var txnStatus: String!

        switch response {
        case .success(let dict):
            if let result = dict["result"] as? [String: String] {
                txnStatus = result["unmappedstatus"]
            } else {
                txnStatus = "failed"
            }
        case .failure:
            txnStatus = "failed"
        }

        return txnStatus
    }
    
    // MARK:- Utils -
    
    
    private func getRemainingTxnTime() -> Int {

        if let connectionModel = PayUPersistentStore.getSocketConnectionModel() {
            return getRemainingTxnTime(model: connectionModel)
        }
        return 180
    }

    private func getRemainingTxnTime(model: PayUPureS2SModel) -> Int {

        guard let txnAllotedMaxTime = Int(model.sdkUpiPushExpiry) else {
            return 180
        }

        let oldTxnTimeRemaining = getSavedRemainingTxnTime(model: model) ?? txnAllotedMaxTime
        let timeSpentInBackground = getTimeSpentInBackground(model: model)
        let actualTimeRemaining =  oldTxnTimeRemaining - timeSpentInBackground

        return max(actualTimeRemaining, 0)
    }

    private func getSavedRemainingTxnTime(model: PayUPureS2SModel) -> Int? {
        let remainingTime = PayUPersistentStore.getRemainingTxnSecsBeforeMovingToBackground(forTxnUniqueId: model.referenceId)
        PayUPersistentStore.removeRemainingTxnSecsBeforeMovingToBackground()
        return remainingTime
    }

    private func getTimeSpentInBackground(model: PayUPureS2SModel) -> Int {
        guard let backgroundEnteredTime = PayUPersistentStore.getBackgroundEnteringTimeStamp(forTxnUniqueId: model.referenceId) else {
            return 0
        }

        PayUPersistentStore.removeBackgroundEnteringTimeStamp()

        let elapsedTime = Date().timeIntervalSince(backgroundEnteredTime)

        return Int(elapsedTime)
    }
}

enum IntentApp {
    static let gpay = "gpay"
    static let phone = "phonepe"
    static let paytm = "paytm"
}
