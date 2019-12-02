//
//  ActivityIndicator.swift
//  SwiftSampleApp
//
//  Created by Vipin Aggarwal on 22/04/19.
//  Copyright © 2019 PayU Payments Pvt. Ltd. All rights reserved.
//

import UIKit

class ActivityIndicator: NSObject {

    var spinner: UIActivityIndicatorView!
    var grayView: UIView!
    var superView: UIView!
    var isActive = false


    func setupActivityIndicatorOn(view: UIView) {
        grayView = UIView(frame: view.bounds)
        grayView.backgroundColor = UIColor.gray
        grayView.alpha = 0.5
        view.addSubview(grayView)

        if let parentSize = superView?.frame.size {
            let x = parentSize.width/2 - 25
            let y = parentSize.height/2 - 25

            spinner = UIActivityIndicatorView(frame: CGRect(x: x, y: y, width: 50, height: 50) )
            spinner.style = .gray
            view.addSubview(spinner)
            view.bringSubviewToFront(grayView)
            view.bringSubviewToFront(spinner)
        }
    }

    func startActivityIndicatorOn(_ view: UIView) {

        if isActive {
            return
        }

        DispatchQueue.main.async {[weak self] in
            self?.superView = view
            self?.setupActivityIndicatorOn(view: view)
            self?.superView.isUserInteractionEnabled = false
            self?.spinner.startAnimating()
            self?.isActive = true
        }
    }

    func stopActivityIndicator() {

        DispatchQueue.main.async { [weak self] in
            self?.spinner.stopAnimating()
            self?.superView.isUserInteractionEnabled = true
            self?.spinner.removeFromSuperview()
            self?.grayView.isHidden = true
            self?.grayView.removeFromSuperview()
            self?.isActive = false
        }
    }
}
