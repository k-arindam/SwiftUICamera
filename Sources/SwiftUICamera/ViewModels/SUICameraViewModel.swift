//
//  SUICameraViewModel.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 14/06/25.
//

@preconcurrency import AVFoundation
import UIKit

public final class SUICameraViewModel: NSObject, ObservableObject, @unchecked Sendable {
    @MainActor
    public init(with config: SUICameraConfig) {
        self.videoDevice = config.videoDevice
        self.audioDevice = config.audioDevice
        self.currentMode = config.initialMode
        
        self.deviceOrientation = UIDevice.current.orientation
        
        super.init()
        
        self.setup()
    }
    
    // MARK: Observable Members
    @Published internal var _busy: Bool = false
    @Published internal var currentMode: CameraMode
    @Published internal var previewScale: PreviewScale = .fit
    @Published internal var supportedVideoQualities: [SUICameraVideoQuality] = []
    @Published internal var supportedShutterSpeeds: [SUICameraShutterSpeed] = []
    @Published internal var supportedISO: [SUICameraISO] = []
    @Published internal var supportedWhiteBalance: [SUICameraWB] = []
    @Published internal var deviceOrientation: UIDeviceOrientation
    
    // MARK: Final Members
    internal let mainqueue = DispatchQueue.main
    internal let bgqueue = DispatchQueue(label: "in.karindam.SUICameraViewModel", qos: .background)
    
    internal let photoOutput = AVCapturePhotoOutput()
    internal let videoOutput = AVCaptureMovieFileOutput()
    internal let frameOutput = AVCaptureVideoDataOutput()
    
    internal let cicontext = CIContext(options: [
        .useSoftwareRenderer: false,
        .cacheIntermediates: true
    ])
    internal let ciImageRenderThread = CIImageRenderThread()
    internal let tmpDir = FileManager.default.temporaryDirectory
    internal let supportedOrientation: [UIDeviceOrientation] = [.portrait, .landscapeRight, .landscapeLeft]
    
    // MARK: Variables
    internal var session: AVCaptureSession?
    internal var videoDevice: SUICameraVideoDevice? = nil
    internal var audioDevice: SUICameraAudioDevice? = nil
    
    public var dataDelegate: SUICameraDataDelegate? = nil
    
    // MARK: Getters & Setters
    internal var busy: Bool {
        get { _busy }
        set {
            mainqueue.async {
                self._busy = newValue
            }
        }
    }
    
    public var currentCameraMode: CameraMode {
        get { currentMode }
        set { switchMode(to: newValue) }
    }
    
    internal var currentVideoInputDevice: AVCaptureDevice? { videoDevice?.avCaptureDevice }
    
    @available(iOS, deprecated: 17.0)
    internal var captureOrientation: AVCaptureVideoOrientation {
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
    
    internal var uiimageOrientation: UIImage.Orientation {
        switch deviceOrientation {
        case .portraitUpsideDown:
            return .left
        case .landscapeLeft:
            return .up
        case .landscapeRight:
            return .down
        default:
            return .right
        }
    }
    
    internal var videoRotationAngle: CGFloat {
        switch deviceOrientation {
        case .landscapeRight: return 180.0
        case .portraitUpsideDown: return 270.0
        case .landscapeLeft: return 0.0
        default: return 90.0
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
    
    internal func attach(device: any SUICameraCaptureDevice, to session: AVCaptureSession) throws -> Void {
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
    private func updateOrientation() -> Void {
        let currentOrientation = UIDevice.current.orientation
        
        if self.supportedOrientation.contains(currentOrientation) {
            self.deviceOrientation = currentOrientation
        }
    }
    
    private func cleanTmpFiles() -> Void {
        let manager = FileManager.default
        
        guard let files = try? manager.contentsOfDirectory(atPath: tmpDir.path()) else { return }
        
        for file in files {
            let fileURL = tmpDir.appending(path: file)
            try? manager.removeItem(at: fileURL)
        }
    }
    
    private func setup() -> Void {
        // MARK: Clean Temporary Files Created By Previous Session
        self.cleanTmpFiles()
        
        // MARK: Update Device Orientation
        NotificationCenter.default.addObserver(self, selector: #selector(updateOrientation), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        // MARK: Create Capture Session
        let session = AVCaptureSession()
        self.session = session
        
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .videoRecording)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        configure(session: session) {
            session.sessionPreset = self.currentMode.preset
            
            do {
                // MARK: Add Video Input Device
                if let videoDevice = self.videoDevice {
                    try self.attach(device: videoDevice, to: session)
                }
                
                // MARK: Add Audio Input Device
                if let audioDevice = self.audioDevice {
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
    }
    
    public func change(aspectRatio to: Int) -> Void {
        guard currentMode == .photo else { return }
    }
    
    public func change(previewScale to: PreviewScale) -> Void {
        guard previewScale != to else { return }
        mainqueue.async {
            self.previewScale = to
        }
    }
    
    public func switchMode(to mode: CameraMode) -> Void {
        self.switchMode(to: mode, releaseLock: true) { _ in }
    }
    
    internal func switchMode(
        to mode: CameraMode,
        releaseLock: Bool = true,
        completion: @Sendable @escaping (_ mutated: Bool) -> Void
    ) -> Void {
        guard self.currentMode != mode, let session else {
            completion(false)
            return
        }
        
        mainqueue.async { self.currentMode = mode }
        
        self.configure(session: session, releaseLock: releaseLock) {
            session.sessionPreset = mode.preset
        } completion: {
            completion(true)
        }
    }
    
    private func stopSession() -> Void {
        session?.stopRunning()
        session = nil
    }
    
    internal func uiimage(from ciimage: CIImage, orientation: UIImage.Orientation = .up) -> UIImage? {
        if let cgimage = self.cicontext.createCGImage(ciimage, from: ciimage.extent) {
            let uiImage = UIImage(
                cgImage: cgimage,
                scale: 1.0,
                orientation: orientation
            )
            
            return uiImage
        }
        
        return nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        stopSession()
    }
}
