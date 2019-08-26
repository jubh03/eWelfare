//
//  MainVController.swift
//  WebEwelfare
//
//  Created by 김동석 on 19/02/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import UIKit
import WebKit
import SideMenu
import SwiftyIamport

class MainVController: BaseVController {

    @IBOutlet weak var ivTitle: UIImageView!
    @IBOutlet weak var lbTitleText: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var vLeftButtons: UIView!
    @IBOutlet weak var rightButtons: UIView!
    
    private var presenter: MainPresenter!
    
    private var wkWebView: WKWebView!
    private var newWkWebView: WKWebView?
    
    private let imageLoadingPopup = ImageLoadingPopup().create()
    
    var tid: String?
    
    override func loadView() {
        super.loadView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadHome), name: Notification.Name("loadHome"), object: nil)
        
        wkWebView = WKWebView(frame: containerView.frame, configuration: getWebViewConfiguration())
        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
        wkWebView.scrollView.delegate = self
        
        containerView.addSubview(wkWebView)
        
        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: wkWebView, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: wkWebView, attribute: .trailing, relatedBy: .equal, toItem: containerView, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: wkWebView, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: wkWebView, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1, constant: 0))
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedPush), name: Notification.Name("receivedPush"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // fcm
        FcmHelper.instance.fcmTopic()
        
        initView()
        
        presenter = MainPresenter(view: self, model: MainModel())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkPush()
    }
    
    private func initView() {
        // 결제 환경 설정
        IAMPortPay.sharedInstance.configure(scheme: "iamporttest")  // info.plist에 설정한 scheme
        
        IAMPortPay.sharedInstance
            .setWKWebView(self.wkWebView)   // 현재 Controller에 있는 WebView 지정
            .setRedirectUrl(nil)            // m_redirect_url 주소
        
        // ISP 취소시 이벤트 (NicePay만 가능)
        IAMPortPay.sharedInstance.setCancelListenerForNicePay { [weak self]  in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: nil, message: "ISP 결제 취소", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        }
        
        // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.view)
        
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuWidth = UIScreen.main.bounds.width * 0.8
    }
    
    @IBAction func onActionBack(_ sender: Any) {
        if wkWebView.canGoBack {
            wkWebView.goBack()
        }
    }
    
    @IBAction func onActionHome(_ sender: Any) {
        presenter.loadHome()
    }
    
    @IBAction func onActionMenu(_ sender: Any) {
        presenter.loadSetting()
    }
    
    @IBAction func onActionSearch(_ sender: Any) {
        presenter.loadSearch()
    }
    
    @objc func loadHome(noti: NSNotification) {
        presenter.loadHome()
    }
    
    @objc
    func receivedPush(noti: NSNotification) {
        checkPush()
    }
    
    private func checkPush() {
        if let type = AppManager.instance.pushUrlType, let url = AppManager.init().pushUrl {
            if type == "in" {
                loadUrl(urlPath: url)
            }
            else if type == "out" {
                let vc = storyboard?.instantiateViewController(withIdentifier: "otherWeb") as! OtherWebVController
                vc.shopUrl = url
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            AppManager.instance.pushUrlType = nil
            AppManager.instance.pushUrl = nil
        }
    }
    
    private func getWebViewConfiguration() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        
        contentController.add(self, name:"goAppPage")
        contentController.add(self, name:"aspGet")
        contentController.add(self, name:"aspPost")
        contentController.add(self, name:"checkMainPage")
        contentController.add(self, name:"showLoading")
        contentController.add(self, name:"tokenError")
        contentController.add(self, name:"openSearchAddress")
        contentController.add(self, name:"outWeb")
        config.userContentController = contentController
        
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        preferences.javaScriptEnabled = true
        config.preferences = preferences
        
        return config
    }
    
    func loadUrl(urlPath: String) {
        guard let url = URL(string: urlPath) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("iOS", forHTTPHeaderField: "platform")
        request.addValue(AppManager.instance.bundleIdentifier!, forHTTPHeaderField: "package")
        request.addValue(AppManager.instance.appVersion!, forHTTPHeaderField: "version")
        if let token = AccountManager.instance.token {
            request.addValue(token, forHTTPHeaderField: "token-ewelfare")
        }
        
//        var cookies = HTTPCookie.requestHeaderFields(with: HTTPCookieStorage.shared.cookies(for: request.url!)!)
//        if let value = cookies["Cookie"] {
//            request.addValue(value, forHTTPHeaderField: "Cookie")
//        }
        
        wkWebView.load(request)
    }
    
    private func parseStringComponents(_ param: String) -> [String: String] {
        var dict: [String: String] = [:]
        
        if !param.isEmpty {
            for item: String in param.components(separatedBy: "&") {
                let parsedParam = item.components(separatedBy: "=")
                dict[parsedParam[0]] = parsedParam[1]
            }
        }
        
        return dict
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
    
    // 다음 지도 호출
    func openSearchAddress() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "addressWeb") as! AddressWebVController
        vc.shopUrl = WDefine.DAUM_ADDRESS_HOST
        vc.titleText = "주소검색"
        vc.addressListener = { zoneCode, address, addressMore in
            let cmd = String(format: "settingAddress('%@','%@')", zoneCode ?? "", address ?? "")
            self.wkWebView.evaluateJavaScript(cmd, completionHandler: nil)
        }
        present(vc, animated: true)
    }

    func goAppPage(_ body: String?) {
        if body == nil {
            return
        }
        
        if let page = parseStringComponents(body!)["page"] {
            if page == "login" {
                goLogin()
            }
            else if page == "setting" {
                goSetting()
            }
            else if page == "store" {
                goMarket(appId: WDefine.eBokjiAppId)
            }
        }
    }
    
    func aspGet(_ body: String?) {
        if body == nil {
            return
        }

        let params = parseStringComponents(body!)
        if let title = params["title"] {
            if let range = body!.range(of: "&url=") {
                let vc = storyboard?.instantiateViewController(withIdentifier: "otherWeb") as! OtherWebVController
                vc.shopUrl = body!.substring(with: range.upperBound..<body!.endIndex)
                vc.titleText = title
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    func aspPost(_ body: String?) {
        if body == nil {
            return
        }
        
        let params = parseStringComponents(body!)
        if let title = params["title"], let url = params["url"], let json = params["data"] {
            let vc = storyboard?.instantiateViewController(withIdentifier: "otherWeb") as! OtherWebVController
            vc.shopUrl = url
            vc.titleText = title
            vc.postParams = makePostData(text: json)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func checkMainPage(_ body: String?) {
        if let body = body as? String, !body.isEmpty {
            vLeftButtons.isHidden = true
            lbTitleText.text = nil
            ivTitle.isHidden = false
            ivTitle.sd_setImage(with: URL(string: body)) { image, error, cacheType, imageURL in
            }
        }
        else {
            vLeftButtons.isHidden = false
            lbTitleText.text = wkWebView.title
            ivTitle.isHidden = true
        }
        // print("wkWebView.title : \(wkWebView.title)")
    }
    
    func outWeb(_ body: String?) {
        if let body = body as? String {
            if body.hasPrefix("http://") || body.hasPrefix("https://") {
                self.openUrl(body)
            }
        }
    }
    
}


extension MainVController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: "e복지", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            completionHandler()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "e복지", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in
            completionHandler(false)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: "e복지", message: prompt, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            }
            else {
                completionHandler(defaultText)
            }
        }))
        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in
            completionHandler(nil)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
}


extension MainVController: WKNavigationDelegate {
    
//    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
//        newWkWebView = WKWebView(frame: webView.frame, configuration: configuration)
//        newWkWebView!.scrollView.bounces = self.wkWebView.scrollView.bounces
//        newWkWebView!.uiDelegate = self.wkWebView.uiDelegate
//        newWkWebView!.navigationDelegate = self.wkWebView.navigationDelegate
//        containerView.addSubview(newWkWebView!)
//        return newWkWebView
//    }
//
//    func webViewDidClose(_ webView: WKWebView) {
//        if webView == newWkWebView! {
//            newWkWebView!.removeFromSuperview()
//            newWkWebView = nil
//        }
//    }
//
//    // 중복적으로 리로드 방지
//    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
//        webView.reload()
//    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let request = navigationAction.request
        
        IAMPortPay.sharedInstance.requestRedirectUrl(for: request, parser: { (data, response, error) -> Any? in
            // Background Thread 처리
            var resultData: [String: Any]?
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                switch statusCode {
                case 200:
                    resultData = [
                        "isSuccess": "OK"
                    ]
                    break
                default:
                    break
                }
            }
            return resultData
        }) { (pasingData) in
            // Main Thread 처리
        }
        
        let result = IAMPortPay.sharedInstance.requestAction(for: request)
        decisionHandler(result ? .allow : .cancel)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 결제 환경으로 설정에 의한 웹페이지(Local) 호출 결과
        IAMPortPay.sharedInstance.requestIAMPortPayWKWebViewDidFinishLoad(webView) { (error) in
            if error != nil {
                switch error! {
                case .custom(let reason):
                    print("error: \(reason)")
                    break
                }
            }
            else {
                print("OK")
            }
        }
    }
    
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("didFail")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("didFailProvisionalNavigation \(error.localizedDescription)")
    }
    
}


extension MainVController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("[[ JavaScript ]] name : \(message.name), body : \(message.body)")
        
        if message.name == "goAppPage" {
            goAppPage(message.body as? String)
        }
        else if message.name == "aspGet" {
            aspGet(message.body as? String)
        }
        else if message.name == "aspPost" {
            aspPost(message.body as? String)
        }
        else if message.name == "checkMainPage" {
            checkMainPage(message.body as? String)
        }
        else if message.name == "showLoading" {
            if let body = message.body as? String, body == "open" {
                imageLoadingPopup.show()
            }
            else {
                imageLoadingPopup.hide()
            }
        }
        else if message.name == "tokenError" {
            self.alertPopup(message: "로그인 세션이 종료되어 로그인 화면으로 이동됩니다.") {
                self.goLogin()
            }
        }
        else if message.name == "openSearchAddress" {
            openSearchAddress()
        }
        else if message.name == "outWeb" {
            outWeb(message.body as? String)
        }
    }
    
}


extension MainVController: UIScrollViewDelegate {
    
    // disable zooming in webview
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
    
}
