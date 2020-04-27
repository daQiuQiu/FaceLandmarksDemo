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
    var faceRectLayer = CALayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        
        setupCapture()
    }
    
     func setupCapture() {
            let captureSession = AVCaptureSession()
            captureSession.sessionPreset = .photo
            
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            
            let input = try? AVCaptureDeviceInput(device: device!)
            captureSession.addInput(input!)
            
            captureSession.startRunning()
            
            self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            self.previewLayer?.frame = self.view.frame
            view.layer.addSublayer(self.previewLayer!)
            view.layer.addSublayer(faceRectLayer)
            
            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            captureSession.addOutput(output)
            
        }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer)else {
            return
        }
        
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
        
        let faceRectWidth = self.previewLayer!.frame.size.width * firstFace.boundingBox.size.width
        let faceRectHeight = self.previewLayer!.frame.size.width * firstFace.boundingBox.size.width
        let faceX = self.previewLayer!.frame.size.width * firstFace.boundingBox.origin.x
        //Y 左下
        let faceY = firstFace.boundingBox.origin.y * self.previewLayer!.frame.size.height
        
        
        faceRectLayer.frame = CGRect(x: faceX, y: faceY, width: faceRectWidth, height: faceRectHeight)
        faceRectLayer.borderColor = UIColor.blue.cgColor
        faceRectLayer.borderWidth = 1.0
//        self.view.layer.addSublayer(faceRectLayer)
    }

}

