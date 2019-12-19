![N|Solid](https://www.payubiz.in/images/logo.png)

# PayU Mobile SDK - UPI (iOS)

PayU's UPI SDK is framework for integrating UPI payments in your app in an easy, efficient and stable way. Following types of payments are currently supported :

  - Intent payments -> Once customer selects the UPI App Option on the merchant app, then it is routed to the app to complete the payment by entering the 4/6 digit Bank M-Pin. The flow is live for Google pay and PhonePe. 'Intent' flow is different between Android and iOS. iOS offers Open Intent unlike Android. In Open Intent, after completion customer does not automatically come back to the merchant. He/she has to manually come back )

  - UPI Collect Payments -> Once customer selects the UPI option on the merchant app, then it gets redirected to a screen where it enters the customer VPA . The VPA is verified , post which customer receives a collect request on their app. Post entering the Bank M-Pin on the customer's device , the transaction is completed.

  - Google Pay Omni-channel Flow/ Phone Number Flow -> This flow is used as a fallback flow in cases where customer does not have a Google Pay app in the device from which he/she is transacting. This flow acts as an enhancement of the UPI Collect Flow where customer enters their phone number registered with GooglePay app instead of GooglePay UPI Handle, basis which a collect request is triggered on their device . Customer enters the 4/6 digit Bank M-Pin and completes the transaction. To further improve the experience, merchant can also auto populate the customer's phone number , to reduce the input points  and reduce TAT.


##### UPI SDK Frameworks
PayU provides two UPI modular SDKs that perform different functions related to UPI Payments
1. __PayU UPI Core SDK__: This contains all APIs, Error Codes, Response Handlers etc. With this SDK alone, you can make intent payments. If you want to make UPI Collect payments also, either you can use PayU UPI SDK (given below) to collect VPA, or pass Core SDK the required parameters. Core SDK contains only one UI Screen, the final loader page. On this screen we fetch the payment response from PayU.
2. __PayU UPI SDK SDK__: This SDK contains native screens and related resources to support UPI collect payment seamlessly. You and your design team does not have to spend time in creating checkout screens

##### Required Dependencies (Automatically added via Cocoapods)
1. __PayU Networking__: This is used by CoreSDK to handle network requests. 
2. __Socket Framework__: UPI Core SDK internally uses sockets to fetch payment response as quickly as possible. This library is required to support socket connections.


### Integration
##### Cocapods integration: 

Add following line in to your Podfile
```
pod 'PayUUPI'
```

##### Manual integration
1. Download the framework files from here. [Files yet to be uploaded]
2. Link to your project......etc etc


##### Make UPI Payments
1. Set environment to test or production 
    ```
    PayUUPICore.shared.environment = .production
    ```
2. Set mandatory payment parameters required for the payment
    ```
    do {
          paymentParams = try PayUPaymentParams(
            merchantKey: "smsplus", //Your merchant key for the environment set in step 1
            transactionId: "1iYJfaskjf890", //Your unique ID for this trasaction
            amount: "64999", //Amount of transaction
            productInfo: "iPhone", // Description of the product
            firstName: "Vipin", // First name of the user
            email: "johnappleseed@payu.in", // Email of the useer
            //User defined parameters.
            //You can save additional details with each txn if you need them for your business logic.
            //You will get these details back in payment response and transaction verify API
            //Like, you can add SKUs for which payment is made.
            udf1: "SKU1|SKU2|SKU3",
            //You can keep all udf fields blank if you do not have any requirement to save txn specific data
            udf2: "",
            udf3: "",
            udf4: "",
            udf5: "")
            
          // Example userCredentials - "merchantKey:user'sUniqueIdentifier"
          paymentParams?.userCredentials = "smsplus:myUserEmail@payu.in"
          // Success URL. Not used but required due to mandatory check.
          paymentParams?.surl = "https://payu.herokuapp.com/ios_success"
           // Failure URL. Not used but required due to mandatory check.
          paymentParams?.furl = "https://payu.herokuapp.com/ios_failure"
          paymentParams?.phoneNumber = "9123456789" // "10 digit phone number here"
        } catch let error {
            Helper.showAlert("Could not create post params due to: \(error.localizedDescription)", onController: self)
        }

    ```
    
3. Subscribe to payment completion notification

    ```
    PayUUPICore.shared.paymentCompletion = { [weak self] result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                self.navigationController?.popToRootViewController(animated: false)

                switch result {
                case .success(let response):
                    Helper.showAlert(String(describing: response), onController: self)

                case .failure(let error):
                    Helper.showAlert(String(describing: error.rawValue), onController: self)
                }
            }
    }
    ```

4. Fetch hashes and save them in `paymentParams` object
    - You need to set `hashes` property in `paymentParams`. Hashes authenticates that API request originates from the original source and not from any Man in the middle. Property `hashes` is of type `PayUHashes`
    - `PayUHashes` has 3 properties. Each of these 3 is used for a distinct API call. These 3 properties are defined below:
        1. `paymentRelatedDetailsForMobileSDKHash`: This is required to get available upi payment options from which payment can be made.
        2. `paymentHash`: This is required to create transaction at PayU's end.
        3. `validateVPAHash`: This is required by validateVPA API in upi collect flow to check if provided VPA is registered with a bank account and is active or not. Not required in intent transactions. 
    - You need to provide first 2 hashes before asking SDK to initiate the payment. Hashes must be generated only on your server as it needs a secret key (also known as salt). Your app must never contain salt.
    - Please see [this documentation](https://raw.githubusercontent.com/payu-intrepos/Documentations/b69a85d7144056af4480563c1c013b5f3b94d755/Integration-Document-Version-2.11.pdf) to generate hashes on your server. 
        - See page 10 & 11 for formula of generating `paymentHash`. 
        - See page 36 for formula of generating `paymentRelatedDetailsForMobileSDKHash` & `validateVPAHash`

    - _Command_ and _var1_ values for generating `paymentRelatedDetailsForMobileSDKHash` & `validateVPAHash` are given below
    
        | Hash for param | Command | var1 |
        | ------ | ------ | ------- |
        | `paymentRelatedDetailsForMobileSDKHash` | payment_related_details_for_mobile_sdk | value of `userCredentials` (You have set it in `paymentParams`)
        | `validateVPAHash` | validateVPA | vpa string of your user|

5. After setting value of hashes in `paymentParams`, call following method of class `PayUAPI` to get all available payment options to the you, "Merchant" :
    ```
    class func getUPIPaymentOptions(withPaymentParams params: PayUPaymentParams,
                                  completion: @escaping(Result<PayUUPIPaymentOptions, PayUSDKError>) ->() )
    ```
    You will get a response of type `Result` with the value of type `PayUUPIPaymentOptions` in response's success param. 
    Sample code shown below
    ```
    PayUAPI.getUPIPaymentOptions(withPaymentParams: self.paymentParams!, completion: { [weak self] result in
        switch result {
        case .success(let paymentOptions):
            self?.availablePaymentOptions = paymentOptions
            completion(.success(true))
        case .failure(let error):
            print(error)
            completion(.failure(error))
        }
    })
    ```
6. With the `PayUUPIPaymentOptions` object received above, you can populate relevant UPI options on your checkout screen.
As stated at the beginning of this document, you have three options to make payment
    1. Intent
    2. UPI Collect
    3. Fallback for Google Pay

    Inside `intent` key of `PayUUPIPaymentOptions` object, you get array of objects of type `PayUSupportedIntentApp`. These are essentially the apps which are supported by the SDK for intent payments. 
You can now query the SDK for payment options available for the "Current User" based on factors like if Bank/Payment-Service-Provider(PSP) apps are installed on the current user's device or not.

    ```
    public class func canUseIntent(forApp app: PayUSupportedIntentApp,
                   withUpiOptions options: PayUUPIPaymentOptions) -> Bool
    public class func canUseUpiCollect(withPaymentOptions options: PayUUPIPaymentOptions) -> Bool
    public class func canUseGpayOmni(withPaymentOptions options: PayUUPIPaymentOptions) -> Bool
    public class func canUseGpayCollect(withPaymentOptions options: PayUUPIPaymentOptions) -> Bool
    ```

    Based on your priority and availability of payment options for the current user, you can order the payment options on your checkout page.
    __Note:__ `canUseGpayOmni` and `canUseGpayCollect` methods give you fallback options of Google Pay intent app which have approx 10% more success rate than general UPI collect payments . This means, if your user does not have GPay app installed, you can still show GPay option on your checkout and we will display these two fallback options upon Gpay selection by the user. GPay omni payment option takes user's phone number for UPI collect payment.

7. If user selects intent app option, you need to create an instance of `PayUIntentPaymentVC` and following data to it.

    ```
    let paymentVC = PayUIntentPaymentVC()
    paymentVC.availableUpiOptions = upiOptions
    paymentVC.paymentApp = app //object of type 'PayUSupportedIntentApp'
    paymentVC.paymentParams = params

    navigationController?.pushViewController(paymentVC, animated: false)
    ```

8. If user selects UPI collect option or GooglePay Omni-channel option, you need to create an instance of `PayCollectPaymentVC` by following code convenience method
    ```
    let paymentVC = PayUIntentPaymentVC()
    ```
    Then, you should pass following information for payment processing

    ```
    collectVC.paymentParams = params
    collectVC.screenType = type // .upi or .gpayFallback
    collectVC.availablePaymentOptions = upiOptions

    self.navigationController?.pushViewController(collectVC, animated: true)
    ```

    After the payment is done, you should get the response in your payment completion callback defined above `PayUUPICore.shared.paymentCompletion`





