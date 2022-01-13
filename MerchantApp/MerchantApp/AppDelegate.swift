//
//  AppDelegate.swift
//  MerchantApp
//
//  Created by Vipin Aggarwal on 20/11/19.
//  Copyright © 2019 Vipin Aggarwal. All rights reserved.
//

import UIKit
//import Firebase
import Alamofire
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        FirebaseApp.configure()
        AF.session.dataTask(with: URL(string: "www.google.com")!) { data, respo, error in
            print(error)
        }
        return true
    }
}

