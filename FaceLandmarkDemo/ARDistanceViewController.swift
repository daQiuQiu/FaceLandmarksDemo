//
//  ARDistanceViewController.swift
//  FaceLandmarkDemo
//
//  Created by nigel on 2020/5/13.
//  Copyright © 2020 tutorabc. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class ARDistanceViewController: UIViewController {
    
    
    var faceNode = SCNNode()
    var leftEye = SCNNode()
    var rightEye = SCNNode()
    lazy var sceneView: ARSCNView = {
        let view = ARSCNView()
        view.frame = self.view.frame
        return view
    }()
    
    lazy var distanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.frame = CGRect(x: 100, y: 650, width: 400, height: 60)
        label.textColor = .white
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .darkGray
        guard ARFaceTrackingConfiguration.isSupported else {
            print("设备不支持")
            return
        }
        
        let config = ARFaceTrackingConfiguration()
        config.isLightEstimationEnabled = true
        
        self.view.addSubview(self.sceneView)
        self.view.addSubview(self.distanceLabel)
        self.sceneView.delegate = self
        self.sceneView.showsStatistics = true
        self.sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        
        
        setupEyeNode()
    }
    
    func setupEyeNode() {
        let eyeGeometry = SCNSphere(radius: 0.005)
        eyeGeometry.materials.first?.diffuse.contents = UIColor.green
        eyeGeometry.materials.first?.transparency = 1.0
        
        let node = SCNNode()
        node.geometry = eyeGeometry
        node.eulerAngles.x = -.pi / 2
        node.position.z = 0.1
        
        leftEye = node.clone()
        rightEye = node.clone()
    }
    
    func trackDistance() {
        DispatchQueue.main.async {

            //4. Get The Distance Of The Eyes From The Camera
            let leftEyeDistanceFromCamera = self.leftEye.worldPosition - SCNVector3Zero
            let rightEyeDistanceFromCamera = self.rightEye.worldPosition - SCNVector3Zero

            //5. Calculate The Average Distance Of The Eyes To The Camera
            let averageDistance = (leftEyeDistanceFromCamera.length() + rightEyeDistanceFromCamera.length()) / 2
            
            self.distanceLabel.text = ("distance = \(String(format: "%.2f", averageDistance * 100)) CM")
            
            
            let averageDistanceCM = (Int(round(averageDistance * 100)))
            print("distance = \(averageDistance)")
        }
    }
    

}

extension ARDistanceViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        //setup node eye and face
        self.faceNode = node
        
        guard let device = self.sceneView.device else { return }
        let faceGeo = ARSCNFaceGeometry(device: device)
        self.faceNode.geometry = faceGeo
        self.faceNode.geometry?.firstMaterial?.fillMode = .lines
        self.faceNode.addChildNode(self.leftEye)
        self.faceNode.addChildNode(self.rightEye)
        self.faceNode.transform = node.transform
        
        //获取距离
        self.trackDistance()
        print("did add")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        self.faceNode.transform = node.transform
        self.faceNode.geometry?.materials.first?.diffuse.contents = UIColor.yellow
        //update node
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        if let faceGeo = node.geometry as? ARSCNFaceGeometry {
            faceGeo.update(from: faceAnchor.geometry)
        }
        leftEye.simdTransform = faceAnchor.leftEyeTransform
        rightEye.simdTransform = faceAnchor.rightEyeTransform
        //获取距离
        trackDistance()
    }
}

extension SCNVector3{

    ///Get The Length Of Our Vector
    func length() -> Float { return sqrtf(x * x + y * y + z * z) }

    ///Allow Us To Subtract Two SCNVector3's
    static func - (l: SCNVector3, r: SCNVector3) -> SCNVector3 { return SCNVector3Make(l.x - r.x, l.y - r.y, l.z - r.z) }
}
