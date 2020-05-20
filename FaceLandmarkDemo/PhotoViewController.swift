//
//  PhtotViewController.swift
//  FaceLandmarkDemo
//
//  Created by nigel on 2020/5/19.
//  Copyright © 2020 tutorabc. All rights reserved.
//

import UIKit
import CoreFoundation
import Toast_Swift

class PhotoViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var imagePicker = UIImagePickerController()
    
    lazy var photoBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 24
        btn.setTitle("拍照", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18)
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 1.0
        btn.addTarget(self, action: #selector(shot), for: .touchUpInside)
        btn.titleLabel?.textColor = .white
        
        return btn
    }()
    
    lazy var checkImageBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 24
        btn.setTitle("相册", for: .normal)
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 1.0
        btn.titleLabel?.font = .systemFont(ofSize: 18)
        btn.titleLabel?.textColor = .white
        btn.addTarget(self, action: #selector(checkImage), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .gray
        
        self.photoBtn.frame = CGRect(x: 0, y: 0, width: 200, height: 60)
        self.checkImageBtn.frame = CGRect(x: 0, y: 0, width: 200, height: 60)
        
        self.photoBtn.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 100)
        self.checkImageBtn.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 100)
        
        self.view.addSubview(self.photoBtn)
        self.view.addSubview(self.checkImageBtn)
    }
    

    @objc func shot() {
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .camera
        
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    @objc func checkImage() {
        self.imagePicker.sourceType = .photoLibrary
        self.present(self.imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
//        let exif = info[UIImagePickerController.InfoKey.mediaMetadata]
        let metadata = info[UIImagePickerController.InfoKey.mediaMetadata] as? NSDictionary
        let exifdata = metadata!["{Exif}"] as! NSDictionary
//        let dic = try! JSONSerialization.data(withJSONObject: exif, options: .prettyPrinted)
        print("info = \(exifdata)")
        
        self.view.makeToast("等效焦距 = \(exifdata["FocalLenIn35mmFilm"]!) mm")
        self.imagePicker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: 方向控制
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
}
