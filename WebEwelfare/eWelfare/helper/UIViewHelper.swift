//
//  UIViewHelper.swift
//  WebEwelfare
//
//  Created by 김동석 on 04/04/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import UIKit

class UIViewHelper {
    
    private static let helper = UIViewHelper()
    static var instance: UIViewHelper {
        get {
            return helper
        }
    }
    
    func topMostController() -> UIViewController? {
        var topController = UIApplication.shared.keyWindow?.rootViewController
        
        while (topController?.presentedViewController) != nil {
            topController = topController?.presentedViewController
        }
        
        return topController
    }
    
}
