//
//  SUICameraViewModel.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 14/06/25.
//

@preconcurrency import AVFoundation
import UIKit

public final class SUICameraViewModel: NSObject, ObservableObject, @unchecked Sendable {
    public init(with config: SUICameraConfig) {
        self.config = config
        super.init()
        
        _ = self.setup()
    }
    
    // MARK: Observable Members
    @Published internal var _busy: Bool = false
    @Published internal var supportedVideoQualities: [SUICameraVideoQuality] = []
    @Published internal var supportedShutterSpeeds: [SUICameraShutterSpeed] = []
    @Published internal var supportedISO: [SUICameraISO] = []
    @Published internal var supportedWhiteBalance: [SUICameraWB] = []
    @Published internal var deviceOrientation: UIDeviceOrientation = .portrait
    
    // MARK: Final Members
    internal let config: SUICameraConfig
    
    internal let mainqueue = DispatchQueue.main
    internal let bgqueue = DispatchQueue(label: "swiftuicamera", qos: .background)
    
    internal let photoOutput = AVCapturePhotoOutput()
    internal let videoOutput = AVCaptureMovieFileOutput()
    internal let frameOutput = AVCaptureVideoDataOutput()
    
    internal let cicontext = CIContext()
    
    // MARK: Variables
    internal var session: AVCaptureSession?
    public var dataDelegate: SUICameraDataDelegate? = nil
    
    // MARK: Getters & Setters
    var busy: Bool {
        get { _busy }
        set {
            mainqueue.async {
                self._busy = newValue
            }
        }
    }
    
    var currentVideoInputDevice: AVCaptureDevice? { config.videoDevice?.avCaptureDevice }
    
    var captureOrientation: AVCaptureVideoOrientation {
        switch deviceOrientation {
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        default:
            return .portrait
        }
    }
    
    var videoRotationAngle: CGFloat {
        switch deviceOrientation {
        case .landscapeRight: return 90.0
        case .portraitUpsideDown: return 180.0
        case .landscapeLeft: return 270.0
        default: return 0.0
        }
    }
    
    internal func configure(
        session: AVCaptureSession,
        releaseLock: Bool = true,
        body: @Sendable @escaping () -> Void,
        completion: (@Sendable () -> Void)? = nil
    ) -> Void {
        bgqueue.async {
            self.busy = true
            session.beginConfiguration()
            body()
            session.commitConfiguration()
            completion?()
            if releaseLock { self.busy = false }
        }
    }
    
    func attach(device: any SUICameraCaptureDevice, to session: AVCaptureSession) throws -> Void {
        func removeDevice(of type: DeviceType) -> Void {
            for input in session.inputs {
                guard let device = (input as? AVCaptureDeviceInput)?.device else { continue }
                
                if device.hasMediaType(type.avMediaType) {
                    session.removeInput(input)
                }
            }
        }
        
        guard let avCaptureDevice = device.avCaptureDevice else { return }
        
        removeDevice(of: device.deviceType)
        
        let videoInput = try AVCaptureDeviceInput(device: avCaptureDevice)
        
        if !session.addInputIfPossible(videoInput) {
            throw SUICameraError.unableToAttachDevice
        }
    }
    
    @objc
    @MainActor
    private func updateOrientation() -> Void { deviceOrientation = UIDevice.current.orientation }
    
    func setup() -> AVCaptureSession {
        // MARK: Update Device Orientation
        NotificationCenter.default.addObserver(self, selector: #selector(updateOrientation), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        // MARK: Create Capture Session
        let session = AVCaptureSession()
        self.session = session
        
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .videoRecording)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        configure(session: session) {
            session.sessionPreset = self.config.initialPreset
            
            do {
                // MARK: Add Video Input Device
                if let videoDevice = self.config.videoDevice {
                    try self.attach(device: videoDevice, to: session)
                }
                
                // MARK: Add Audio Input Device
                if let audioDevice = self.config.audioDevice {
                    try self.attach(device: audioDevice, to: session)
                }
                
                // MARK: Add Photo Output
                _ = session.addOutputIfPossible(self.photoOutput)
                
                // MARK: Add Video Output
                _ = session.addOutputIfPossible(self.videoOutput)
                
                // MARK: Add Frame Output
                self.frameOutput.setSampleBufferDelegate(self, queue: self.bgqueue)
                _ = session.addOutputIfPossible(self.frameOutput)
            } catch {
                debugPrint("----->>> createSession() ERROR: \(error)")
            }
        } completion: {
            session.startRunning()
        }
        
        return session
    }
    
    public func capturePhoto() -> Void {
        guard let session = session else { return }
        
        configure(session: session, releaseLock: false) {
            session.sessionPreset = .photo
        } completion: {
            guard let connection = self.photoOutput.connection(with: .video), connection.isActive else { return }
            
            let photoSettings = AVCapturePhotoSettings()
            photoSettings.photoQualityPrioritization = .balanced
            
            self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    public func startVideoRecording(at url: URL) -> Void {
        guard let session = session else { return }
        
        configure(session: session, releaseLock: false) {
            session.sessionPreset = .high
        } completion: {
            guard let connection = self.videoOutput.connection(with: .video),
                  connection.isActive,
                  !self.videoOutput.isRecording,
                  url.isFileURL
            else { return }
            
            self.videoOutput.startRecording(to: url, recordingDelegate: self)
        }
    }
    
    public func stopVideoRecording() -> Void {
        bgqueue.async {
            if self.videoOutput.isRecording {
                self.videoOutput.stopRecording()
            }
        }
    }
    
    func fetchSupportedVideoQualities(of device: AVCaptureDevice) -> [SUICameraVideoQuality] {
        var videoQualities = [SUICameraVideoQuality]()
        
        for format in device.formats {
            let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            let frameRateRanges = format.videoSupportedFrameRateRanges
            
            for range in frameRateRanges {
                let frameRate = Int(range.maxFrameRate)
                
                guard let videoQuality = SUICameraVideoQuality.fromRawVideoQuality(dimensions, fps: frameRate) else { continue }
                videoQualities.append(videoQuality)
            }
        }
        
        return videoQualities
    }
    
    func fetchSupportedShutterSpeeds(of device: AVCaptureDevice) -> [SUICameraShutterSpeed] {
        let minExposureDuration = CMTimeGetSeconds(device.activeFormat.minExposureDuration)
        let maxExposureDuration = CMTimeGetSeconds(device.activeFormat.maxExposureDuration)
        
        var shutterSpeeds = SUICameraShutterSpeed.allCases.filter { shutterSpeed in
            let actualSpeed = 1.0 / Float64(shutterSpeed.rawValue)
            return (minExposureDuration...maxExposureDuration).contains(actualSpeed)
        }
        
        if !shutterSpeeds.contains(.auto) {
            shutterSpeeds.append(.auto)
        }
        
        return shutterSpeeds
    }
    
    func fetchSupportedISO(of device: AVCaptureDevice) -> [SUICameraISO] {
        let minISO = Int(device.activeFormat.minISO)
        let maxISO = Int(device.activeFormat.maxISO)
        
        guard minISO < maxISO else { return [] }
        return SUICameraISO.allCases.filter { (minISO...maxISO).contains($0.rawValue) }
    }
    
    func fetchSupportedWB(of device: AVCaptureDevice) -> [SUICameraWB] {
        func wbGainAvailable(for value: SUICameraWB) -> Bool {
            let minWB = 2300
            let maxWB = 7500
            
            guard (minWB...maxWB).contains(value.rawValue) else { return false }
            
            let temperatureAndTintValues = AVCaptureDevice.WhiteBalanceTemperatureAndTintValues(temperature: Float(value.rawValue), tint: value.tint)
            
            let wbGains = device.deviceWhiteBalanceGains(for: temperatureAndTintValues)
            let maxGain = device.maxWhiteBalanceGain
            
            return (wbGains.redGain <= maxGain) && (wbGains.greenGain <= maxGain) && (wbGains.blueGain <= maxGain)
        }
        
        return SUICameraWB.allCases.filter { wbGainAvailable(for: $0) }
    }
    
    func stopSession() -> Void {
        session?.stopRunning()
        session = nil
    }
    
    internal func uiimage(from ciimage: CIImage) -> UIImage? {
        if let cgimage = self.cicontext.createCGImage(ciimage, from: ciimage.extent) {
            return UIImage(cgImage: cgimage)
        }
        
        return nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        stopSession()
    }
}

extension SUICameraViewModel: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        self.dataDelegate?.photoOutput?(photo, error: error)
        self.busy = false
    }
}

extension SUICameraViewModel: AVCaptureFileOutputRecordingDelegate {
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
        self.dataDelegate?.finishedRecording?(at: outputFileURL, error: error)
        self.busy = false
    }
}

extension SUICameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        self.dataDelegate?.frameOutput?(ciImage: ciImage)
        self.dataDelegate?.frameOutput?(uiImage: uiimage(from: ciImage))
    }
}
