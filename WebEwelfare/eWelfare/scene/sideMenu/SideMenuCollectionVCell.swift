//
//  SideMenuCollectionVCell.swift
//  WebEwelfare
//
//  Created by 김동석 on 15/04/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import UIKit

class SideMenuCollectionVCell: UICollectionViewCell {
    
    @IBOutlet weak var btnMenuTitle: UIButton!
    
    var vc: SideMenuVController?
    var data: Menu!
    
    func updateData(vc: SideMenuVController, data: Menu) {
        self.vc = vc
        self.data = data
        
        btnMenuTitle .setTitle(data.title, for: .normal)
    }

    @IBAction func onActionMenu(_ sender: UIButton) {
        if let asp = self.data.asp, asp == "ewelfare" {
            let otherWebVC = vc?.storyboard?.instantiateViewController(withIdentifier: "otherWeb") as! OtherWebVController
            otherWebVC.shopUrl = data?.url
            otherWebVC.titleText = data?.title
            vc?.present(otherWebVC, animated: true)
        }
    }
    
}
