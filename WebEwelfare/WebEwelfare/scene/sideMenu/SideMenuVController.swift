//
//  SideMenuVController.swift
//  WebEwelfare
//
//  Created by 김동석 on 10/04/2019.
//  Copyright © 2019 nam yeon hun. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import SDWebImage
import SideMenu
import SwiftyJSON

class SideMenuVController: BaseVController {
    
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbPoint: UILabel!
    
    private let picker = UIImagePickerController()
    
    private var user: User?
    private var menu: [Menu]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        picker.delegate = self

        initView()
        
        requestUser()
        requestMenu()
    }
    
    @IBAction func onActionProfile(_ sender: UIButton) {
        let alert =  UIAlertController(title: "", message: "프로필 설정 선택", preferredStyle: .actionSheet)

        let library =  UIAlertAction(title: "사진앨범", style: .default) { (action) in
            self.openLibrary()
        }
        let camera =  UIAlertAction(title: "카메라", style: .default) { (action) in
            self.openCamera()
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)

        alert.addAction(library)
        alert.addAction(camera)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onActionSetting(_ sender: UIButton) {
        self.goSetting()
    }
    
    @IBAction func onActionClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onActionCallCenter(_ sender: UIButton) {
        self.openUrl("tel:025627747")
    }
    
    @IBAction func onActionBar(_ sender: UIButton) {
        var urlStr = WDefine.URL + "/mypage/order/list"
        var titleStr = "주문내역"
        if sender.tag == 2 {
            urlStr = WDefine.URL + "/mypage/cart"
            titleStr = "장바구니"
        }
        else if sender.tag == 3 {
            urlStr = WDefine.URL + "/mypage/coupon"
            titleStr = "쿠폰함"
        }
        else if sender.tag == 4 {
            urlStr = WDefine.URL + "/mypage/recent"
            titleStr = "최근 본 상품"
        }
        else if sender.tag == 5 {
            urlStr = WDefine.URL + "/mypage/push"
            titleStr = "푸시 리스트"
        }
        else if sender.tag == 6 {
            urlStr = WDefine.URL + "/mypage/point"
            titleStr = "포인트"
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "otherWeb") as! OtherWebVController
        vc.shopUrl = urlStr
        vc.titleText = titleStr
        present(vc, animated: true)
    }
    
    private func initView() {
        btnProfile.layer.cornerRadius = btnProfile.frame.width / 2
        btnProfile.layer.masksToBounds = true
    }
    
    private func openLibrary() {
        picker.sourceType = .photoLibrary
        present(picker, animated: false, completion: nil)
    }
    
    private func openCamera() {
        picker.sourceType = .camera
        present(picker, animated: false, completion: nil)
    }
    
    private func updateUser() {
        guard let userInfo = self.user else {
            return
        }
        
        if let imgUrl = userInfo.img_url {
            btnProfile.sd_setImage(with: URL(string: imgUrl), for: .normal, completed: nil)
        }
        lbName.text = userInfo.name
        lbPoint.text = String(userInfo.point)
    }
    
    private func requestUser() {
        // url
        let url: String = WDefine.API + "sidebar/user"
        
        Alamofire.request(url,
                          method: .post,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: AlamofireHelper.instance.headers).responseObject { (response: DataResponse<ResUser>) in
                            if let value = response.result.value, value.code == ResResultCode.Success.rawValue {
                                self.user = value.data
                                self.updateUser()
                            }
        }
    }

    private func requestMenu() {
        // url
        let url: String = WDefine.API + "sidebar/menu"
        
        Alamofire.request(url,
                          method: .post,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: AlamofireHelper.instance.headers).responseObject { (response: DataResponse<ResMenu>) in
                            if let value = response.result.value, value.code == ResResultCode.Success.rawValue {
                                self.menu = value.data
                            }
        }
    }
    
    private func requestUploadImage(image: UIImage) {
        // url
        let url: String = WDefine.API + "user/profile"
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(image.jpegData(compressionQuality: 0.7)!, withName: "image", fileName: "file.jpg", mimeType: "image/jpg")
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: AlamofireHelper.instance.headers) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    let json = JSON(response.result.value!)
                    print("upload json : \(json)")
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
            }
        }
    }


}


extension SideMenuVController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            // btnProfile.setImage(image, for: .normal)
            requestUploadImage(image: image)
        }
        dismiss(animated: true, completion: nil)
    }

}
