//
//  AVCaptureState.swift
//  Neo
//
//  Created by Thomas Martins on 12/11/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import Foundation
import AVFoundation

class AVCaptureState {
    static var isVideoDisabled: Bool {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        return status == .restricted || status == .denied
    }
    
    static var isAudioDisabled: Bool {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        return status == .restricted || status == .denied
    }
}
