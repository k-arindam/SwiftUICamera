//
//  VideoRecording+SUICameraViewModel.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 15/06/25.
//

@preconcurrency import AVFoundation

extension SUICameraViewModel: AVCaptureFileOutputRecordingDelegate {
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
        self.dataDelegate?.finishedRecording?(at: outputFileURL, error: error)
        self.busy = false
    }
    
    public func startVideoRecording() -> Void {
        let fileType = AVFileType.mov.rawValue
        let videoID = UUID().uuidString
        
        guard let uttype = UTType(fileType) else { return }
        
        let videoURL = tmpDir.appendingPathComponent("\(videoID).mov", conformingTo: uttype)
        startVideoRecording(at: videoURL)
    }
    
    public func startVideoRecording(at url: URL) -> Void {
        self.switchMode(to: .video, releaseLock: false) { mutated in
            guard let connection = self.videoOutput.connection(with: .video),
                  connection.isActive,
                  !self.videoOutput.isRecording,
                  url.isFileURL
            else { return }
            
            let rotation = self.videoRotationAngle
            if connection.isVideoRotationAngleSupported(rotation) {
                connection.videoRotationAngle = rotation
            }
            
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
    
    public func change(videoQuality to: SUICameraVideoQuality) -> Void {
        guard !busy,
              currentVideoQuality != to,
              let session,
              let description = videoQualityDescriptions[to],
              let device = videoDevice?.avCaptureDevice
        else { return }
        
        mainqueue.async { self.currentVideoQuality = to }
        configure(device: device, session: session) {
            device.activeFormat = description.format
            device.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(description.frameRate))
            device.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(description.frameRate))
        }
    }
    
    internal func fetchSupportedVideoQualities(of device: AVCaptureDevice) -> [SUICameraVideoQuality] {
        var videoQualities = [SUICameraVideoQuality]()
        
        for format in device.formats {
            let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            let frameRateRanges = format.videoSupportedFrameRateRanges
            
            for range in frameRateRanges {
                let frameRate = Int(range.maxFrameRate)
                
                guard let videoQuality = SUICameraVideoQuality.fromRawVideoQuality(dimensions, fps: frameRate),
                      !videoQualities.contains(videoQuality)
                else { continue }
                
                let description = VQDescription(format: format, frameRate: frameRate)
                
                videoQualities.append(videoQuality)
                videoQualityDescriptions.updateValue(description, forKey: videoQuality)
            }
        }
        
        return videoQualities
    }
}
