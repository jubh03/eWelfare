//
//  MainPresenter.swift
//  WebEwelfare
//
//  Created by 김동석 on 19/02/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import Foundation

class MainPresenter {
    
    private var view: MainVController?
    private var model: MainModel!
    
    init(view: MainVController, model: MainModel) {
        self.view = view
        self.model = model
        
        view.loadUrl(urlPath: model.urlMain)
    }
    
    func loadHome() {
        if self.view != nil {
            self.view!.loadUrl(urlPath: model.urlMain)
        }
    }
    
    func loadSearch() {
        if self.view != nil {
            self.view!.loadUrl(urlPath: model.urlSearch)
        }
    }
    
    func loadSetting() {
        if self.view != nil {
            self.view!.goSetting()
        }
    }

}
