//
//  Helper.swift
//  SampleApp
//
//  Created by Vipin Aggarwal on 29/08/19.
//  Copyright © 2019 PayU Payments Pvt. Ltd. All rights reserved.
//

import Foundation
import UIKit

class Helper {
    class func showAlert(_ message:String, onController controller: UIViewController) {
        DispatchQueue.main.async() {
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in

            }))
            controller.present(alert, animated: true, completion: nil)
        }
    }
}
