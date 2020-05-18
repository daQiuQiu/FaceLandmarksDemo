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
import SceneKit
import ModelIO
import SnapKit
import Toast_Swift
//import TTEmotion

class VNDistanceViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var previewLayer1: AVCaptureVideoPreviewLayer?
    let captureSession1 = AVCaptureSession()
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    var faceRectLayer = UIView()
    let captureSession = AVCaptureSession()
    var height: CGFloat = 0
    var width: CGFloat = 0
    var fLength: Float = 0
    var faceLandMarks:[VNFaceLandmarkRegion2D] = []
    //    let ttManager = TTEmotionManager.init()
    var clap: CGRect = CGRect.zero
    var eyeDistance: Float = 0
    var resolutionFactor: Float = 0
    var connection:AVCaptureConnection?
    var previewFactor: CGFloat = 0
    var upScale: CGFloat = 0
    var sensorX: Float = 0
    
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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("didAppear")
        self.fLength = 0
        self.resolutionFactor = Float(3.0 / UIScreen.main.scale)
        self.view.backgroundColor = .red
        self.cameraView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        //        self.cameraView.frame = self.view.frame
        self.cameraView.center = self.view.center
        //        self.cameraView.contentMode = .scaleAspectFit
        self.cameraView.backgroundColor = .black
        self.view.addSubview(self.cameraView)
        self.cameraView.addSubview(faceRectLayer)
        self.view.addSubview(self.distanceLabel)
        
        
        setupCapture()
        
        captureSession.startRunning()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            //            self.setupCam()
            //            self.captureSession1.startRunning()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    deinit {
        print("Vision VC deinit")
    }
    
    func setupCapture() {
        let camera = SceneKit.SCNCamera()
        print("focal = \(camera.focalDistance)")
        
        let mdl = ModelIO.MDLCamera()
        print("mld focal = \(mdl.focalLength)")
        
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        try? device?.lockForConfiguration()
        //        captureSession.sessionPreset = .iFrame960x540
        
        captureSession.commitConfiguration()
        device?.unlockForConfiguration()
        
        print("device aperture = \(device?.lensAperture)")
        //        print("eqv focal length = \(self.getEquivalentFocalLength(format: device!.activeFormat))")
        let input = try? AVCaptureDeviceInput(device: device!)
        
        
        self.fLength = self.getEquivalentFocalLength(format: device!.activeFormat)
        
        captureSession.addInput(input!)
        
        
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.frame = CGRect(x: 0, y: 0, width: self.cameraView.frame.width, height: self.cameraView.frame.height)
        //        self.previewLayer?.contentsGravity = .resizeAspectFit
        self.previewLayer?.videoGravity = .resizeAspect
        self.faceRectLayer.layer.borderColor = UIColor.blue.cgColor
        self.faceRectLayer.layer.borderWidth = 3.0
        self.faceRectLayer.backgroundColor = UIColor.clear
        self.cameraView.layer.addSublayer(self.previewLayer!)
        
        //获取静态图片
        //        let stillOutput = AVCapturePhotoOutput()
        //        let setting = AVCapturePhotoSettings.init(format: [AVVideoCodecKey:AVVideoCodecType.jpeg])
        
        
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
        
        if connection == self.connection {
            print("conn")
        }
        
        
        if let fdesc = CMSampleBufferGetFormatDescription(sampleBuffer) {
            self.clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, originIsAtTopLeft: true)
            self.previewFactor =  (self.previewLayer!.frame.size.width * self.previewLayer!.frame.size.height * UIScreen.main.scale) / (self.clap.size.width * self.clap.size.height * self.upScale)
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
        
        
        
        
        
        var faceBoxOnscreen = self.previewLayer!.layerRectConverted(fromMetadataOutputRect: firstFace.boundingBox)
        
        let widthScale = faceBoxOnscreen.size.width / self.clap.size.width
        let heightScale = faceBoxOnscreen.size.height / self.clap.size.height
        
        let x = faceBoxOnscreen.origin.x
        let y = faceBoxOnscreen.origin.y
        let w = faceBoxOnscreen.size.width
        let h = faceBoxOnscreen.size.height
        
        
        //左眼球
        if let leftPupil = firstFace.landmarks?.leftPupil {
            self.faceLandMarks.append(leftPupil)
            //右眼球
            if let rightPupil = firstFace.landmarks?.rightPupil {
                self.faceLandMarks.append(rightPupil)
                
                guard let leftEyePoint = leftPupil.normalizedPoints.first else { return }
                guard let rightEyePoint = rightPupil.normalizedPoints.first else { return }
                
                let leftX = leftEyePoint.y * h + x
                let rightX = rightEyePoint.y * h + x
                
                let leftY = leftEyePoint.x * w + y
                let rightY = rightEyePoint.x * w + y
                
                
                self.eyeDistance = sqrtf(powf(Float(leftX - rightX), 2) + powf(Float(leftY - rightY), 2))
            }
        }
        
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
            
            
            let distanceTest = self.fLength * (Float(self.clap.size.height) / self.eyeDistance) / 10 * self.resolutionFactor
            //            let distanceTest = self.fLength * (Float(self.clap.size.height) / self.eyeDistance * Float(1.0 / self.previewFactor)) / 10
            //            //            if UIDevice.current.orientation.isLandscape {
            //            //                distanceTest = self.fLength * (Float(self.clap.size.width) / self.eyeDistance) / 10
            //            }
            
            let distanceEye = self.fLength * (Float(self.clap.size.height / (self.previewLayer!.frame.width * self.upScale) * 65.0) / self.eyeDistance)
            
            let eyeFactor = Float(Float(self.previewLayer!.frame.width) / (2.0 * self.eyeDistance))
            
            let distanceAndroid = self.fLength * (63.0 / self.sensorX) * eyeFactor / 3.0
            
            let distanceAli = ( 63 * Float(self.view.frame.width) / 24 / (self.eyeDistance)) * self.fLength / 10.0 * (Float(UIScreen.main.scale / self.upScale))
            
            let distance = (700.0 - (w + h)) / 10.0
            self.distanceLabel.text = ("distance = \(String(format: "%.2f", distanceAli)) CM")
            print("distance = \(distance) CM")
            print("testDistance = \(distanceAli) eyeDistance = \(self.eyeDistance) focal length = \(self.fLength)")
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
    
    func getEquivalentFocalLength(format : AVCaptureDevice.Format) -> Float {
        // get reported field of view. Documentation says this is the horizontal field of view
        
        // convert to radians
        self.upScale = format.videoZoomFactorUpscaleThreshold
        let fov = format.videoFieldOfView * Float.pi/180.0
        // angle and opposite of right angle triangle are half the fov and half the width of
        // 35mm film (ie 18mm). The adjacent value of the right angle triangle is the equivalent
        // focal length. Using some right angle triangle math you can work out focal length
        let focalLen = 15.5 / tan(fov/2)
        
        let radi = format.videoFieldOfView / 2 * Float.pi/180.0
        
        self.sensorX = tan(radi) * 2 * focalLen
        return focalLen
    }
    
    //MARK: 方向控制
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
}

