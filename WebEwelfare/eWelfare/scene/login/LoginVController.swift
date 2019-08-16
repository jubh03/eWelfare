//
//  LoginVController.swift
//  WebEwelfare
//
//  Created by 김동석 on 04/04/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import UIKit

class LoginVController: BaseVController {
    
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!

    @IBOutlet weak var btnSavedEmail: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfEmail.delegate = self
        tfPassword.delegate = self
        
        initView()
    }
    
    private func initView() {
        tfEmail.text = AppManager.instance.savedEmail
        
        btnSavedEmail.isSelected = (AppManager.instance.savedEmail?.isEmpty == false)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func onActionLogin(_ sender: UIButton) {
        if !isValidData() {
            return
        }
        
        AccountManager.instance.requestLogin(email: tfEmail.text!, password: tfPassword.text!) { code, message in
            switch code {
            case ResResultCode.Success.rawValue:
                AppManager.instance.savedEmail = self.btnSavedEmail.isSelected ? self.tfEmail.text : nil
                
                self.saveConfig()
                self.goMain()
            default:
                if message != nil {
                    self.alertPopup(message: message!) {}
                }
                else {
                    self.alertPopup(message: "서버 통신이 원활하지 않습니다. 잠시 후 다시 이용해 주세요") {}
                }
            }
        }
    }
    
    @IBAction func onActionCertify(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "otherWeb") as! OtherWebVController
        vc.isHideHome = true
        vc.shopUrl = WDefine.URL + "member/cert"
        vc.titleText = "e복지 회원인증"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onActionFindIdPwd(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "otherWeb") as! OtherWebVController
        vc.isHideHome = true
        vc.shopUrl = WDefine.URL + "member/search/idpw"
        vc.titleText = "e복지 아이디 / 비밀번호 찾기"
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    @IBAction func onActionSaveEmail(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    public func isValidData() -> Bool {
        if let errorMsg = ValidHelper.instance.isValidEmail(email: tfEmail.text) {
            self.alertPopup(message: errorMsg) {}
            return false
        }
        if let errorMsg = ValidHelper.instance.isValidPassword(password: tfPassword.text) {
            self.alertPopup(message: errorMsg) {}
            return false
        }
        
        return true
    }
    
    private func saveConfig() {
        // 자동 로그인 저장
        
        // 아이디 저장
    }

}

extension LoginVController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // checkDoneEnable(isShowError: false)
        
        if textField == tfEmail {
            return (textField.text?.count ?? 0 > 32) && (range.length == 0) ? false : true
        }
        else if textField == tfPassword {
            return (textField.text?.count ?? 0 > 32) && (range.length == 0) ? false : true
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfEmail {
            tfPassword.becomeFirstResponder()
        }
        else if textField == tfPassword {
            textField.resignFirstResponder()
        }
        
        return false
    }
    
}
