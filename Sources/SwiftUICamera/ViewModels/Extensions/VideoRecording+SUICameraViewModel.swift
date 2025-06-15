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
    
    internal func fetchSupportedVideoQualities(of device: AVCaptureDevice) -> [SUICameraVideoQuality] {
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
}
