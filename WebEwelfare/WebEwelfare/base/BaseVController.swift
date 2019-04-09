//
//  BaseVController.swift
//  WebEwelfare
//
//  Created by 김동석 on 19/02/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import UIKit

class BaseVController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    // change scene
    func goLogin() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "login") as! LoginVController
        present(vc, animated: false)
    }
    
    func goMain() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "mainWeb") as! MainVController
        present(vc, animated: false)
    }
    
    func goSetting() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "setting") as! SettingVController
        present(vc, animated: true)
    }
    
    func goMarket(appId: String) {
        let urlString = "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=\(appId)&mt=8"
        
        if let downloadUrl = URL.init(string: urlString) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(downloadUrl, options: [:], completionHandler: nil)
            }
            else {
                UIApplication.shared.openURL(downloadUrl)
            }
        }
    }
    
    func alertPopup(message: String, _ callback: @escaping ()->Void) {
        alertPopup(message: message, buttonText: "확인", callback)
    }
    
    func alertPopup(message: String, buttonText: String, _ callback: @escaping ()->Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: buttonText, style: UIAlertAction.Style.default, handler: { action in
            callback()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func commonPopup(message: String, _ callback: @escaping (Bool)->Void) {
        commonPopup(message: message, leftButtonText: "취소", rightButtonText: "확인", callback)
    }
    
    func commonPopup(message: String, leftButtonText: String, rightButtonText : String, _ callback: @escaping (Bool)->Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: leftButtonText, style: UIAlertAction.Style.default, handler: { action in
            callback(false)
        }))
        alert.addAction(UIAlertAction(title: rightButtonText, style: UIAlertAction.Style.default, handler: { action in
            callback(true)
        }))
        present(alert, animated: true, completion: nil)
    }
    
}
