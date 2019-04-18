//
//  SplashVController.swift
//  WebEwelfare
//
//  Created by 김동석 on 04/04/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import UIKit

class SplashVController: BaseVController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(requestInto), userInfo: nil, repeats: false)
    }
    
    @objc func requestInto() {
        AppManager.instance.requestIntro() { code in
            switch code {
            case ResResultCode.Success.rawValue:
                if let token = AccountManager.instance.token, !token.isEmpty {
                    self.goMain()
                }
                else {
                    self.goLogin()
                }
            case ResResultCode.TokenError.rawValue:
                self.popupTokenError()
            case ResResultCode.VersionLow.rawValue:
                self.popupUpdate()
            case ResResultCode.VersionLowMustUpdate.rawValue:
                self.goMarket(appId: WDefine.eDanbiAppId)
            default:
                self.goLogin()
            }
        }
    }
    
    private func popupTokenError() {
        self.alertPopup(message: "로그인 세션이 종료되어 로그인 화면으로 이동됩니다.") {
            self.goLogin()
        }
    }
    
    private func popupUpdate() {
        commonPopup(message: "새로운 버전이 있습니다. 업데이트를 하시겠습니까?", leftButtonText: "나중에", rightButtonText: "업데이트") { isYes in
            if isYes {
                self.goMarket(appId: WDefine.eDanbiAppId)
            }
            else if AccountManager.instance.isLogon {
                    self.goMain()
            }
            else {
                self.goLogin()
            }
        }
    }
    
}
