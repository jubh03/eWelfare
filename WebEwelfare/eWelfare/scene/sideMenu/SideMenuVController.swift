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
    
    @IBOutlet weak var vCollection: UICollectionView!
    
    private let picker = UIImagePickerController()
    
    private var user: User?
    private var menu: [Menu]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        picker.delegate = self
        
        vCollection.delegate = self
        vCollection.dataSource = self

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
        var urlStr = ""
        var titleStr = ""

        if sender.tag == 1 {
            urlStr = WDefine.URL + "mypage/order/list"
            titleStr = "주문내역"
        }
        else if sender.tag == 2 {
            urlStr = WDefine.URL + "cart"
            titleStr = "장바구니"
        }
        else if sender.tag == 3 {
            urlStr = WDefine.URL + "mypage/coupon"
            titleStr = "쿠폰함"
        }
        else if sender.tag == 4 {
            urlStr = WDefine.URL + "mypage/recent"
            titleStr = "최근 본 상품"
        }
        else if sender.tag == 5 {
            urlStr = WDefine.URL + "mypage/push"
            titleStr = "푸시 리스트"
        }
        else if sender.tag == 6 {
            urlStr = WDefine.URL + "mypage/point"
            titleStr = "포인트"
        }
        else {
            return
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
                            if let value = response.result.value {
                                if value.code == ResResultCode.Success.rawValue {
                                    self.user = value.data
                                    self.updateUser()
                                }
                                else if value.code == ResResultCode.TokenError.rawValue {
                                    self.alertPopup(message: "로그인 세션이 종료되어 로그인 화면으로 이동됩니다.") {
                                        self.goLogin()
                                    }
                                }
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
                            if let value = response.result.value {
                                if value.code == ResResultCode.Success.rawValue {
                                    self.menu = value.data
                                    self.vCollection.reloadData()
                                }
                                else if value.code == ResResultCode.TokenError.rawValue {
                                    self.alertPopup(message: "로그인 세션이 종료되어 로그인 화면으로 이동됩니다.") {
                                        self.goLogin()
                                    }
                                }
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
                    if let resResult = ResResult(JSONString: json.rawString()!) {
                        if resResult.code == ResResultCode.Success.rawValue {
                            // success
                            self.alertPopup(message: "프로필 사진이 업로드 되었습니다.") {
                            }
                            return
                        }
                        else if resResult.code == ResResultCode.TokenError.rawValue {
                            self.alertPopup(message: "로그인 세션이 종료되어 로그인 화면으로 이동됩니다.") {
                                self.goLogin()
                            }
                        }
                    }
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


extension SideMenuVController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return menu?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menu![section].sub?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "menuCell", for: indexPath) as! SideMenuCollectionVCell
        cell.updateData(vc: self, data: menu![indexPath.section].sub![indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Number of cells
        let collectionViewWidth = (UIScreen.main.bounds.width * 0.8) / 2.0
        let collectionViewHeight = CGFloat(48.0)
        
        return CGSize(width: collectionViewWidth, height: collectionViewHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let rView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "menuHeader", for: indexPath) as! SideMenuCollectionRView
            rView.updateData(vc: self, data: menu![indexPath.section])
            return rView
        }
        
        return UICollectionReusableView()
    }
    
}

