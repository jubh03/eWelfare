//
//  ValidHelper.swift
//  WebEwelfare
//
//  Created by 김동석 on 04/04/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import Foundation

class ValidHelper: NSObject {
    
    private static let helper = ValidHelper()
    static var instance: ValidHelper {
        get {
            return helper
        }
    }
    
    func isValidEmail(email: String?) -> String? {
        if let ipEmail = email, !ipEmail.isEmpty {
            //            if !patternCheckEmail(email: ipEmail) {
            //                return "이메일을 형식이 잘못되었습니다"
            //            }
            
            return nil
        }
        return "이메일을 입력해주세요"
    }
    
    private func patternCheckEmail(email: String) -> Bool {
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regEx)
        return predicate.evaluate(with: email)
    }
    
    func isValidPassword(password: String?) -> String? {
        if let ipPassword = password, !ipPassword.isEmpty {
            //            if !patternCheckPassword(password: ipPassword) {
            //                return "비밀번호 형식이 잘못되었습니다"
            //            }
            
            return nil
        }
        return "비밀번호를 입력해주세요"
    }
    
    private func patternCheckPassword(password: String) -> Bool {
        let regEx = "^(?=.*[a-zA-Z])(?=.*[0-9]).{6,15}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regEx)
        return predicate.evaluate(with: password)
    }

}
