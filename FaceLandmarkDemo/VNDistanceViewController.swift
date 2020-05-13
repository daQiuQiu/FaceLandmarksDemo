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
//import TTEmotion

class VNDistanceViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    var faceRectLayer = UIView()
    let captureSession = AVCaptureSession()
    var height: CGFloat = 0
    var width: CGFloat = 0
    var faceLandMarks:[VNFaceLandmarkRegion2D] = []
//    let ttManager = TTEmotionManager.init()
    var clap: CGRect = CGRect.zero
    
    lazy var distanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.frame = CGRect(x: 100, y: 650, width: 400, height: 60)
        label.textColor = .white
        return label
    }()
//    var ttManager: TTEmotionManager = TTEmotionManager()
    
    var cameraView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .red
        self.cameraView.frame = CGRect(x: 0, y: 0, width: 300, height: 400)
//        self.cameraView.frame = self.view.frame
        self.cameraView.center = self.view.center
        //        self.cameraView.contentMode = .scaleAspectFit
        self.cameraView.backgroundColor = .black
        self.view.addSubview(self.cameraView)
        self.cameraView.addSubview(faceRectLayer)
        self.view.addSubview(self.distanceLabel)
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
//        self.previewLayer?.contentsGravity = .resizeAspectFill
        self.previewLayer?.videoGravity = .resize
        self.faceRectLayer.layer.borderColor = UIColor.blue.cgColor
        self.faceRectLayer.layer.borderWidth = 3.0
        self.faceRectLayer.backgroundColor = UIColor.clear
        self.cameraView.layer.addSublayer(self.previewLayer!)
        
        //获取静态图片
        let stillOutput = AVCapturePhotoOutput()
        let setting = AVCapturePhotoSettings.init(format: [AVVideoCodecKey:AVVideoCodecType.jpeg])
        
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        captureSession.addOutput(output)
        
//        captureSession.addOutput(stillOutput)
//        stillOutput.capturePhoto(with: setting, delegate: self)
        
        self.cameraView.bringSubviewToFront(self.faceRectLayer)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        print("拍照！")
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let buffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)else {
            return
        }
        
        

//        let image = self.convert(buffer: buffer)
//        self.ttManager.visionDetectFace(image: image, frame: self.previewLayer!.frame) { (model, dic) in
//                print("result = \(dic)")
//        }
        
        
        
        if let fdesc = CMSampleBufferGetFormatDescription(sampleBuffer) {
           self.clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, originIsAtTopLeft: true)
        }
        
        
        //downMirrored 一定要用downMirrored 不然方向不对
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .downMirrored, options: [:])
        
        let faceRequest = VNDetectFaceLandmarksRequest.init { [weak self] (vnRequest, error) in
//            print("提取成功 = \(vnRequest.results)")
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
        
        

        var faceBoxOnscreen = self.previewLayer!.layerRectConverted(fromMetadataOutputRect: firstFace.boundingBox)
        
        let widthScale = faceBoxOnscreen.size.width / self.clap.size.width
        let heightScale = faceBoxOnscreen.size.height / self.clap.size.height
        
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
            
            let distance = (700.0 - (w + h)) / 10.0
            self.distanceLabel.text = ("distance = \(String(format: "%.2f", distance)) CM")
            print("distance = \(distance) CM")
        }

    }
    
    
    
    func processLandmarkDetail() {
        
    }
    
    func eyeTest() {
        
    }
    
    //buffer -> uiimage
    func convert(buffer:CVPixelBuffer) -> UIImage
    {
        
         let ciimage: CIImage = CIImage(cvPixelBuffer: buffer)
         let context:CIContext = CIContext.init(options: nil)
         let cgImage:CGImage = context.createCGImage(ciimage, from: ciimage.extent)!
         let image:UIImage = UIImage.init(cgImage: cgImage)
         return image
    }
    
}

