//
//  CIImageRenderThread.swift
//  SwiftUICamera
//
//  Created by Arindam Karmakar on 16/06/25.
//

import Foundation
import UIKit

internal final class CIImageRenderThread: NSObject {
    internal override init() {
        super.init()
        
        thread = Thread(target: self, selector: #selector(threadEntry), object: nil)
        thread?.name = Thread.ciImageRenderThread + id.uuidString
        thread?.qualityOfService = .background
        thread?.start()
    }
    
    private let id: UUID = .init()
    private var thread: Thread? = nil
    
    @objc private func threadEntry() -> Void {
        RunLoop.current.add(NSMachPort(), forMode: .default)
        RunLoop.current.run()
    }
    
    @objc private func threadExit() -> Void {
        Thread.current.cancel()
        CFRunLoopStop(RunLoop.current.getCFRunLoop())
    }
    
    @objc private func _render(_ obj: Any?) -> Void {
        guard let request = obj as? RenderRequest else { return }
        
        autoreleasepool {
            let ciImage = request.image
            let ctx = Thread.current.ciContext
            
            if let cgimage = ctx.createCGImage(ciImage, from: ciImage.extent) {
                let uiImage = UIImage(
                    cgImage: cgimage,
                    scale: 1.0,
                    orientation: request.orientation
                )
                
                request.completion(uiImage)
            }
            
            request.completion(nil)
        }
    }
    
    internal func output(with request: RenderRequest) -> Void {
        guard let thread else {
            request.completion(nil)
            return
        }
        
        self.perform(
            #selector(_render),
            on: thread,
            with: request,
            waitUntilDone: false
        )
    }
    
    deinit {
        if let thread {
            perform(
                #selector(threadExit),
                on: thread,
                with: nil,
                waitUntilDone: false
            )
        }
    }
    
    internal struct RenderRequest {
        let image: CIImage
        let orientation: UIImage.Orientation
        let completion: (UIImage?) -> Void
        
        init(image: CIImage, orientation: UIImage.Orientation = .up, completion: @escaping (UIImage?) -> Void) {
            self.image = image
            self.orientation = orientation
            self.completion = completion
        }
    }
}

fileprivate extension Thread {
    static let ciImageRenderThread: String = "in.karindam.CIImageRenderThread"
    
    var ciContext: CIContext {
        if let ctx = threadDictionary[Self.ciImageRenderThread] as? CIContext {
            return ctx
        }
        
        let options: [CIContextOption: Any] = [
            .useSoftwareRenderer: false,
            .cacheIntermediates: true
        ]
        let newCtx = CIContext(options: options)
        threadDictionary[Self.ciImageRenderThread] = newCtx
        return newCtx
    }
}
