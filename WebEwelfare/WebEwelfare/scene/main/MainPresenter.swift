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
        
        view.loadUrl(urlPath: model.getMainUrl())
    }
    
}
