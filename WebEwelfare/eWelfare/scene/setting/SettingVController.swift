//
//  SettingVController.swift
//  WebEwelfare
//
//  Created by KimDongSeok on 04/04/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import UIKit

class SettingVController: BaseVController {

    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbVersion: UILabel!
    @IBOutlet weak var switchNoti: UISwitch!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var lbLatestVersion: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        AccountManager.instance.requestConfig() { code, message in
            if code == ResResultCode.Success.rawValue {
                self.updateConfig()
            }
            else if code == ResResultCode.TokenError.rawValue {
                self.alertPopup(message: "로그인 세션이 종료되어 로그인 화면으로 이동됩니다.") {
                    self.goLogin()
                }
            }
            else {
                if message != nil {
                    self.alertPopup(message: message!) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                else {
                    self.alertPopup(message: "에러가 발생하였습니다.") {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }

    @IBAction func onActionBack(_ sender: UIButton) {
        // dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    // 로그아웃
    @IBAction func onActionLogout(_ sender: UIButton) {
        commonPopup(message: "로그아웃 하시겠습니까?", leftButtonText: "아니오", rightButtonText: "예") { isYes in
            if isYes {
                self.goLogin()
            }
        }
    }
    
    @IBAction func onActionUserInfo(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "otherWeb") as! OtherWebVController
        // vc.isTerms = true
        
        vc.shopUrl = AccountManager.instance.config?.url
        vc.titleText = "회원정보관리"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // 알림 설정
    @IBAction func onActionSwitchNoti(_ sender: UISwitch) {
        AccountManager.instance.config?.push = sender.isOn ? "Y" : "N"
        AccountManager.instance.requestModifyPush(value: sender.isOn ? "Y" : "N") { code, message in
            if code == ResResultCode.Success.rawValue {
                AppManager.instance.isFcmTopicOff = !sender.isOn
                FcmHelper.instance.fcmTopic()
            }
            else if code == ResResultCode.TokenError.rawValue {
                self.alertPopup(message: "로그인 세션이 종료되어 로그인 화면으로 이동됩니다.") {
                    self.goLogin()
                }
            }
        }
    }
    
    @IBAction func onActionUpdate(_ sender: UIButton) {
        self.goMarket(appId: WDefine.eBokjiAppId)
    }

    private func updateConfig() {
        if let config = AccountManager.instance.config {
            lbName.text = "-"
            if let name = config.name {
                lbName.text = "\(name) 님"
            }
            
            if let appVersion = AppManager.instance.appVersion {
                lbVersion.text = "v\(appVersion)"
                
                if appVersion == config.version?.name {
                    lbLatestVersion.isHidden = false
                }
                else {
                    let splitAppVersion = appVersion.split(separator: ".")
                    let splitConfigVersion = config.version?.name?.split(separator: ".")
                    if (splitAppVersion.count == splitConfigVersion?.count) && (splitAppVersion.count == 3) {
                        for i in 0..<splitAppVersion.count {
                            if splitAppVersion[i] > splitConfigVersion![i] {
                                lbLatestVersion.isHidden = false
                                break
                            }
                            else if splitAppVersion[i] < splitConfigVersion![i] {
                                btnUpdate.isHidden = false
                                break
                            }
                        }
                    }
                    

                }
            }
            
            switchNoti.isOn = isY(value: config.push)
        }
    }
    
    private func isY(value: String?) -> Bool {
        if let text = value, text.uppercased() == "Y" {
            return true
        }
        return false
    }


}
