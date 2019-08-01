//
//  SideMenuCollectionRView.swift
//  WebEwelfare
//
//  Created by 김동석 on 15/04/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import UIKit

class SideMenuCollectionRView: UICollectionReusableView {
        
    @IBOutlet weak var btnMenuTitle: UIButton!
    
    var vc: SideMenuVController?
    var data: Menu?
    
    func updateData(vc: SideMenuVController, data: Menu) {
        self.vc = vc
        self.data = data
        
        btnMenuTitle .setTitle(data.title, for: .normal)
    }
    
    @IBAction func onActionMenu(_ sender: UIButton) {
        let otherWebVC = vc?.storyboard?.instantiateViewController(withIdentifier: "otherWeb") as! OtherWebVController
        otherWebVC.shopUrl = data?.url
        otherWebVC.titleText = data?.title
        otherWebVC.postParams = makePostData(text: data?.json)
        vc?.nextViewController(vc: otherWebVC)
    }
    
    private func makePostData(text: String?) -> String {
        var postData = ""
        
        if let jsonDic = convertToDictionary(text: text) {
            for data in jsonDic {
                if postData.count > 0 {
                    postData += "&"
                }
                
                if let value = data.value as? String {
                    postData += String(format: "%@=%@", data.key, value)
                }
                else if let value = data.value as? Int {
                    postData += String(format: "%@=%d", data.key, value)
                }
            }
        }

        return postData
    }
    
    private func convertToDictionary(text: String?) -> [String: AnyObject]? {
        if text == nil {
            return nil
        }
        
        if let data = text!.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
            } catch {
                // Handle Error
            }
        }
        return nil
    }
    
}
