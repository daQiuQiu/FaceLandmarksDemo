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
        
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        
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
        output.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
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
        
        let firstFace = faces[0]
        
        guard let contour = firstFace.landmarks?.faceContour else {
            return
        }
        
        
        
        var faceBoxOnscreen = self.previewLayer!.layerRectConverted(fromMetadataOutputRect: firstFace.boundingBox)
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
            for i in 0..<contour.pointCount {
                var point = contour.normalizedPoints[i]
                point.x = 1.0 - point.x
                
                let pointView = UIView()
                pointView.frame = CGRect(x: 0, y: 0, width: 2.0, height: 2.0)
                pointView.center = CGPoint(x: x + w * point.x, y: self.previewLayer!.frame.size.height - (y + h * point.y))
                pointView.layer.cornerRadius = 1.0
                pointView.backgroundColor = .red
                pointView.clipsToBounds = true
                
                self.cameraView.addSubview(pointView)
                
            }
            //            self.faceRectLayer.frame = firstFace.boundingBox
        }
        
        //        self.view.layer.addSublayer(faceRectLayer)
    }
    
}

