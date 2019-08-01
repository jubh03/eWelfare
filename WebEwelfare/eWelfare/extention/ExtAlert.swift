//
//  ExtAlert.swift
//  WebEwelfare
//
//  Created by 김동석 on 04/04/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import Foundation

import UIKit

extension UIAlertController {
    
    static func showMessage(_ message: String) {
        showAlert(title: "e복지", message: message, actions: [UIAlertAction(title: "확인", style: .cancel, handler: nil)])
    }
    
    static func showAlert(title: String?, message: String?, actions: [UIAlertAction]) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            for action in actions {
                alert.addAction(action)
            }
            if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController, let presenting = navigationController.topViewController {
                presenting.present(alert, animated: true, completion: nil)
            }
        }
    }
}
