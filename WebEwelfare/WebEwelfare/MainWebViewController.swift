//
//  MainWebViewController.swift
//  WebEwelfare
//
//  Created by nam yeon hun on 28/12/2018.
//  Copyright © 2018 nam yeon hun. All rights reserved.
//

import Foundation
import WebKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

class MainWebViewController: UIViewController, View {
    
    var disposeBag = DisposeBag()
    
    var wkWebView = WKWebView()
    
    let contentController = WKUserContentController()
    let config = WKWebViewConfiguration()
    
    var createWebView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reactor = MainWebViewReactor()
        
        let userScript = WKUserScript(
            source: "sendLoginAction()",
            injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
            forMainFrameOnly: true
        )
        self.contentController.addUserScript(userScript)
        self.contentController.add(self, name: "sendLoginAction")
        
        self.config.userContentController = self.contentController
        
        self.wkWebView = WKWebView(frame: .zero, configuration: self.config)
        
        self.wkWebView.uiDelegate = self
        self.wkWebView.navigationDelegate = self
        
        self.view.addSubview(wkWebView)
        
        if let url = URL(string: "https://m.ewelfare.net") {
            self.wkWebView.load(URLRequest(url: url))
        }
        
        self.wkWebView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.bottom.left.right.equalToSuperview()
        }
    }
    func bind(reactor: MainWebViewReactor) {
     
        self.rx.methodInvoked(#selector(WKScriptMessageHandler.userContentController(_:didReceive:)))
        .asObservable()
            .map { ($0[1] as? WKScriptMessage)?.body as? String}
            .filterNil()
            .map { userToken in
                UserDefaults().set(userToken, forKey: Key.token)
            }
            .map { Reactor.Action.setToken }
            .bind(to: reactor.action)
        .disposed(by: self.disposeBag)
        
    }
}

extension MainWebViewController: WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        print("runJavaScriptAlertPanelWithMessage: ", message)
        
        let alert = UIAlertController(title: "e복지", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            completionHandler()
        }))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        print("runJavaScriptConfirmPanelWithMessage: ", message)
        let alert = UIAlertController(title: "e복지", message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            completionHandler(true)
        }))

        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        //뷰를 생성하는 경우
        let frame = UIScreen.main.bounds
        
        //파라미터로 받은 configuration
        createWebView = WKWebView(frame: frame, configuration: configuration)
        
        //오토레이아웃 처리
        createWebView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        createWebView?.navigationDelegate = self
        createWebView?.uiDelegate = self
        
        view.addSubview(createWebView!)
        
        return createWebView!
        
        /* 현재 창에서 열고 싶은 경우
         self.webView.load(navigationAction.request)
         return nil
         */
    }
    
    //새창 닫기
    //iOS9.0 이상
    func webViewDidClose(_ webView: WKWebView) {
        if webView == createWebView! {
            createWebView!.removeFromSuperview()
            createWebView = nil
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("\(#function)")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("\(#function): \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        /*
         //스마트 신한앱 다운로드 url
         let sh_url = "http://itunes.apple.com/us/app/id360681882?mt=8" //신한Mobile앱 결제 다운로드 url
         
         let sh_url2 = "https://itunes.apple.com/kr/app/sinhan-mobilegyeolje/id572462317?mt=8"
         
         //현대 다운로드 url
         
         let hd_url = "http://itunes.apple.com/kr/app/id362811160?mt=8"
         
         //스마트 신한 url 스키마
         
         let sh_appname = "smshinhanansimclick" //스마트 신한앱 url 스키마
         
         let sh_appname2 = "shinhan-sr-ansimclick"
         
         //현대카드 url
         
         let hd_appname = "smhyundaiansimclick" //현대카드 url
         
         let hd_vbv = "ansimclick.hyundaicard.com"
         */

        if let header = navigationAction.request.allHTTPHeaderFields {
            print("header: - ",header)
        }
                if let urlStr = navigationAction.request.url?.absoluteString {
                    print("요청된 URL ==> \(urlStr)")
        
                    let nsStringUrlStr = urlStr as NSString
        
                    if Int(nsStringUrlStr.range(of: "ansimclick.hyundaicard.com").location ) != NSNotFound {
        
                        decisionHandler(.allow)
        
                    }else {
                        
                        if Int(nsStringUrlStr.range(of: "http://itunes.apple.com").location) != NSNotFound {
                            print("1. 앱설치 url 입니다. ==>%@",urlStr)
                            UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
                            //decisionHandler(.cancel)
                        }
                    }
        
                    if Int(nsStringUrlStr.range(of: "ansimclick").location ) != NSNotFound {
                        print("2. 앱설치 url 입니다. ==>%@",urlStr)
                        UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
                        //decisionHandler(.cancel)
                    }
        
                    if Int(nsStringUrlStr.range(of: "appfree").location ) != NSNotFound {
                        print("3. 앱설치 url 입니다. ==>%@",urlStr)
                        UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
                        //decisionHandler(.cancel)
                    }
                }
        
        decisionHandler(.allow)
    }
}

