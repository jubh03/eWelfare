//
//  ImageLoadingPopup.swift
//  WebEwelfare
//
//  Created by 김동석 on 11/04/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import UIKit
import SwiftGifOrigin

class ImageLoadingPopup: UIView {

    @IBOutlet weak var ivImage: UIImageView!
    
    static var id = 0
    
    func create() -> ImageLoadingPopup {
        let popup: ImageLoadingPopup = UINib(nibName: "ImageLoadingPopup", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! ImageLoadingPopup
        popup.frame = UIScreen.main.bounds
        popup.translatesAutoresizingMaskIntoConstraints = true
        popup.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return popup
    }
    
    func show() {
        ImageLoadingPopup.id += 1
        if ImageLoadingPopup.id > 3 {
            ImageLoadingPopup.id = 1
        }

//        ivImage.image = UIImage(named: "image_loading_\(ImageLoadingPopup.id).png")
//        ivImage.image = UIImage.gif(name: "image_loading")
        ivImage.image = UIImage.gif(name: "medical_loading")
        
        let uiView: UIView = UIApplication.shared.keyWindow!
        uiView.addSubview(self)
    }
    
    func hide() {
        self.removeFromSuperview()
    }

}
