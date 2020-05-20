//
//  ViewController.swift
//  FaceLandmarkDemo
//
//  Created by nigel on 2020/5/13.
//  Copyright © 2020 tutorabc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var vnBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 24
        btn.setTitle("使用Vision", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18)
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 1.0
        btn.addTarget(self, action: #selector(goToVNVC), for: .touchUpInside)
        btn.titleLabel?.textColor = .white
        
        return btn
    }()
    
    lazy var arBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 24
        btn.setTitle("使用ARKit", for: .normal)
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 1.0
        btn.titleLabel?.font = .systemFont(ofSize: 18)
        btn.titleLabel?.textColor = .white
        btn.addTarget(self, action: #selector(goToARVC), for: .touchUpInside)
        return btn
    }()
    
    lazy var photoBtn: UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 24
        btn.setTitle("拍照", for: .normal)
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 1.0
        btn.titleLabel?.font = .systemFont(ofSize: 18)
        btn.titleLabel?.textColor = .white
        btn.addTarget(self, action: #selector(goToPhoto), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.view.backgroundColor = .darkGray
        // Do any additional setup after loading the view.
        setupUI()
        
    }
    
    func setupUI () {
        self.arBtn.frame = CGRect(x: 0, y: 0, width: 200, height: 60)
        self.vnBtn.frame = CGRect(x: 0, y: 0, width: 200, height: 60)
        self.photoBtn.frame = CGRect(x: 0, y: 0, width: 200, height: 60)
        self.arBtn.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 100)
        self.vnBtn.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 100)
        self.photoBtn.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 200)
        
        self.view.addSubview(self.vnBtn)
        self.view.addSubview(self.arBtn)
        self.view.addSubview(self.photoBtn)
    }
    

    @objc func goToARVC() {
        let vc = ARDistanceViewController()
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func goToVNVC() {
        let vc = VNDistanceViewController()
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func goToPhoto() {
        let vc = PhotoViewController()
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: 方向控制
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }

}
