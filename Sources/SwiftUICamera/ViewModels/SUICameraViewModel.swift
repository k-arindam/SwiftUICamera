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
        self.gridEnabled = config.initiallyGridEnabled
        
        self.deviceOrientation = UIDevice.current.orientation
        
        super.init()
        
        self.setup()
    }
    
    // MARK: Observable Members
    @Published internal var _busy: Bool = false
    @Published internal var currentMode: CameraMode
    @Published internal var previewScale: PreviewScale = .fit
    @Published internal var deviceOrientation: UIDeviceOrientation
    @Published internal var previewBounds: CGRect = .zero
    
    @Published public internal(set) var supportedVideoQualities: [SUICameraVideoQuality] = []
    @Published public internal(set) var currentVideoQuality: SUICameraVideoQuality = .vqFHD30FPS
    
    @Published public internal(set) var supportedShutterSpeeds: [SUICameraShutterSpeed] = []
    @Published public internal(set) var currentShutterSpeed: SUICameraShutterSpeed = .auto
    
    @Published public internal(set) var supportedISO: [SUICameraISO] = []
    @Published public internal(set) var currentISO: SUICameraISO = .auto
    
    @Published public internal(set) var supportedWhiteBalance: [SUICameraWB] = []
    @Published public internal(set) var currentWhiteBalance: SUICameraWB = .auto
    
    @Published public var gridEnabled: Bool
    
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
    internal var videoQualityDescriptions: [SUICameraVideoQuality: VQDescription] = [:]
    
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
    
    internal var currentDimension: CGSize? {
        if let desc = videoDevice?.avCaptureDevice?.activeFormat.formatDescription {
            let dims = CMVideoFormatDescriptionGetDimensions(desc)
            return CGSize(width: Int(dims.width), height: Int(dims.height))
        }
        
        return nil
    }
    
    @MainActor internal var actualPreviewBounds: CGRect? { calculateActualPreviewBounds() }
    
    @MainActor
    private func calculateActualPreviewBounds() -> CGRect? {
        let connectedScenes = UIApplication.shared.connectedScenes
        
        if let videoDimension = self.currentDimension,
           let windowScene = connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            let orientation = windowScene.interfaceOrientation
            
            var videoWidth = CGFloat(videoDimension.width)
            var videoHeight = CGFloat(videoDimension.height)
            
            if orientation.isPortrait {
                swap(&videoWidth, &videoHeight)
            }
            
            let layerRect = self.previewBounds
            let layerWidth = layerRect.width
            let layerHeight = layerRect.height
            
            let videoAspectRatio = videoWidth / videoHeight
            let layerAspectRatio = layerWidth / layerHeight
            
            var displayRect = layerRect
            
            if videoAspectRatio > layerAspectRatio {
                let newHeight = layerWidth / videoAspectRatio
                let yOffset = (layerHeight - newHeight) / 2
                displayRect.origin.y += yOffset
                displayRect.size.height = newHeight
            } else {
                let newWidth = layerHeight * videoAspectRatio
                let xOffset = (layerWidth - newWidth) / 2
                displayRect.origin.x += xOffset
                displayRect.size.width = newWidth
            }
            
            return displayRect
        }
        
        return nil
    }
    
    internal func configure(
        device: AVCaptureDevice,
        session: AVCaptureSession,
        releaseLock: Bool = true,
        body: @Sendable @escaping () -> Void,
        completion: (@Sendable (_ error: SUICameraError?) -> Void)? = nil
    ) -> Void {
        @Sendable func bodyInternal() throws(SUICameraError) -> Void {
            do {
                try device.lockForConfiguration()
                body()
                device.unlockForConfiguration()
            } catch {
                throw .system(error.localizedDescription)
            }
        }
        
        self.configure(session: session, releaseLock: releaseLock, body: bodyInternal, completion: completion)
    }
    
    internal func configure(
        session: AVCaptureSession,
        releaseLock: Bool = true,
        body: @Sendable @escaping () throws(SUICameraError) -> Void,
        completion: (@Sendable (_ error: SUICameraError?) -> Void)? = nil
    ) -> Void {
        self.bgqueue.async {
            var cameraError: SUICameraError? = nil
            
            defer {
                completion?(cameraError)
                if releaseLock { self.busy = false }
            }
            
            do {
                self.busy = true
                session.beginConfiguration()
                try body()
                session.commitConfiguration()
            } catch let error as SUICameraError {
                cameraError = error
            } catch {
                cameraError = .unknown
            }
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
        } completion: { error in
            session.startRunning()
            self.updateCapabilities()
        }
    }
    
    internal func clearCapabilities() -> Void {
        mainqueue.async {
            self.videoQualityDescriptions.removeAll()
            self.supportedVideoQualities.removeAll()
            self.supportedShutterSpeeds.removeAll()
            self.supportedISO.removeAll()
            self.supportedWhiteBalance.removeAll()
        }
    }
    
    internal func updateCapabilities() -> Void {
        clearCapabilities()
        guard let device = videoDevice?.avCaptureDevice else { return }
        
        let videoQualities = self.fetchSupportedVideoQualities(of: device)
        let shutterSpeeds = self.fetchSupportedShutterSpeeds(of: device)
        let iso = self.fetchSupportedISO(of: device)
        let whiteBalance = self.fetchSupportedWB(of: device)
        
        mainqueue.async {
            self.supportedVideoQualities = videoQualities
            self.supportedShutterSpeeds = shutterSpeeds
            self.supportedISO = iso
            self.supportedWhiteBalance = whiteBalance
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
        } completion: { error in
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
