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
    
    var previewLayer: CALayer?
    var faceRectLayer = UIView()
    let captureSession = AVCaptureSession()
    var height: CGFloat = 0
    var width: CGFloat = 0
    
    var cameraView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .red
        self.cameraView.frame = CGRect(x: 0, y: 0, width: 300, height: 400)
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
        
        self.faceRectLayer.layer.borderColor = UIColor.blue.cgColor
        self.faceRectLayer.layer.borderWidth = 3.0
        self.faceRectLayer.backgroundColor = UIColor.clear
        self.cameraView.layer.addSublayer(self.previewLayer!)
        
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(output)
        self.cameraView.bringSubviewToFront(self.faceRectLayer)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer)else {
            return
        }
        
//        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
//            let ciimage = CIImage(cvImageBuffer: pixelBuffer)
//            let image = UIImage(ciImage: ciimage)
//            self.height = image.size.height
//            self.width = image.size.width
//
//            DispatchQueue.main.async {
//                //                self.cameraView.image = image
//            }
//        }
        
        
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, options: [:])
        
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
            return
        }
        
        let firstFace = faces[0]
        
        let heightRate = CGFloat(self.height) / self.previewLayer!.frame.size.width
        
        let faceRectWidth = self.previewLayer!.frame.size.width * firstFace.boundingBox.size.width
        let faceRectHeight = self.previewLayer!.frame.size.height * firstFace.boundingBox.size.height
        //前置摄像头
        let faceX = self.previewLayer!.frame.size.width * (1.0 - firstFace.boundingBox.origin.x - firstFace.boundingBox.size.width)
        //Y 左下
        let faceY = self.previewLayer!.frame.size.height - (firstFace.boundingBox.origin.y * self.previewLayer!.frame.size.height) - faceRectHeight

        DispatchQueue.main.async {
            self.faceRectLayer.frame = CGRect(x: faceX, y: faceY, width: faceRectWidth, height: faceRectHeight)
            //            self.faceRectLayer.frame = firstFace.boundingBox
        }
        
        //        self.view.layer.addSublayer(faceRectLayer)
    }
    
}

