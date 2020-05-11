//
//  ViewController.swift
//  FaceLandmarkDemo
//
//  Created by nigel on 2020/4/27.
//  Copyright © 2020 tutorabc. All rights reserved.
//

import UIKit
import Vision
import AVKit

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    var faceRectLayer = UIView()
    let captureSession = AVCaptureSession()
    var height: CGFloat = 0
    var width: CGFloat = 0
    var faceLandMarks:[VNFaceLandmarkRegion2D] = []
    
    var cameraView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .red
//        self.cameraView.frame = CGRect(x: 0, y: 0, width: 300, height: 399.3)
        self.cameraView.frame = self.view.frame
        self.cameraView.center = self.view.center
        //        self.cameraView.contentMode = .scaleAspectFit
        self.cameraView.backgroundColor = .black
        self.view.addSubview(self.cameraView)
        self.cameraView.addSubview(faceRectLayer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        setupCapture()
    }
    
    func setupCapture() {
        
        captureSession.sessionPreset = .photo
        
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        
        let input = try? AVCaptureDeviceInput(device: device!)
        
        captureSession.addInput(input!)
        
        captureSession.startRunning()
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.frame = CGRect(x: 0, y: 0, width: self.cameraView.frame.width, height: self.cameraView.frame.height)
        self.previewLayer?.contentsGravity = .resizeAspectFill
        self.faceRectLayer.layer.borderColor = UIColor.blue.cgColor
        self.faceRectLayer.layer.borderWidth = 3.0
        self.faceRectLayer.backgroundColor = UIColor.clear
        self.cameraView.layer.addSublayer(self.previewLayer!)
        
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        output.alwaysDiscardsLateVideoFrames = true
//        output.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        captureSession.addOutput(output)
        self.cameraView.bringSubviewToFront(self.faceRectLayer)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer)else {
            return
        }
        
        //downMirrored 一定要用downMirrored 不然方向不对
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .downMirrored, options: [:])
        
        let faceRequest = VNDetectFaceLandmarksRequest.init { [weak self] (vnRequest, error) in
            print("提取成功 = \(vnRequest.results)")
            if let result = vnRequest.results as? [VNFaceObservation] {
                self?.processLandmarks(faces: result)
            }else {
                print("NO Observation")
            }
        }
        
        try? handler.perform([faceRequest])
    }
    
    func processLandmarks(faces: [VNFaceObservation]) {
        if faces.count == 0 {
            debugPrint("NO FACE")
            return
        }
        
        //细节点
        let firstFace = faces[0]
        //轮廓
        if let contour = firstFace.landmarks?.faceContour {
            self.faceLandMarks.append(contour)
        }
        //左眼
        if let leftEye = firstFace.landmarks?.leftEye {
            self.faceLandMarks.append(leftEye)
        }
        //右眼
        if let rightEye = firstFace.landmarks?.rightEye {
            self.faceLandMarks.append(rightEye)
        }
        //左眉毛
        if let leftEyeBrow = firstFace.landmarks?.leftEyebrow {
            self.faceLandMarks.append(leftEyeBrow)
        }
        //右眉毛
        if let rightEyeBrow = firstFace.landmarks?.rightEyebrow {
            self.faceLandMarks.append(rightEyeBrow)
        }
        //外嘴唇
        if let outerLips = firstFace.landmarks?.outerLips {
            self.faceLandMarks.append(outerLips)
        }
        //内嘴唇
        if let innerLips = firstFace.landmarks?.innerLips {
            self.faceLandMarks.append(innerLips)
        }
        //鼻子
        if let nose = firstFace.landmarks?.nose {
            self.faceLandMarks.append(nose)
        }
        //鼻尖
        if let noseCrest = firstFace.landmarks?.noseCrest {
            self.faceLandMarks.append(noseCrest)
        }
        //中线
        if let medianLine = firstFace.landmarks?.medianLine {
            self.faceLandMarks.append(medianLine)
        }
        //左眼球
        if let leftPupil = firstFace.landmarks?.leftPupil {
            self.faceLandMarks.append(leftPupil)
        }
        //右眼球
        if let rightPupil = firstFace.landmarks?.rightPupil {
            self.faceLandMarks.append(rightPupil)
        }
        
        

        let faceBoxOnscreen = self.previewLayer!.layerRectConverted(fromMetadataOutputRect: firstFace.boundingBox)
//        faceBoxOnscreen.origin.x = 1.0 - faceBoxOnscreen.origin.x
//        let heightRate = CGFloat(self.height) / self.previewLayer!.frame.size.width
        let x = faceBoxOnscreen.origin.x
        let y = faceBoxOnscreen.origin.y
        let w = faceBoxOnscreen.size.width
        let h = faceBoxOnscreen.size.height
        DispatchQueue.main.async {
            for view in self.cameraView.subviews {
                view.removeFromSuperview()
            }
            self.faceRectLayer.frame = faceBoxOnscreen
            self.cameraView.addSubview(self.faceRectLayer)
            
            //提取所有关键点
            if let allPoints = firstFace.landmarks?.allPoints {
                for i in 0..<allPoints.pointCount {
                    let point = allPoints.normalizedPoints[i]
                    
                    let pointView = UIView()
                    pointView.frame = CGRect(x: 0, y: 0, width: 2.0, height: 2.0)
                    pointView.center = CGPoint(x: point.y * h + x, y: point.x * w + y)
                    pointView.layer.cornerRadius = 1.0
                    pointView.backgroundColor = .green
                    pointView.clipsToBounds = true
                    
                    self.cameraView.addSubview(pointView)
                    
                }
            }
        }
        
        
    }
    
    func processLandmarkDetail() {
        
    }
    
}

