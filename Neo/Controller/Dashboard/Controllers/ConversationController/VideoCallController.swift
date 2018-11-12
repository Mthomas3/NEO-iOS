//
//  VideoCallController.swift
//  Neo
//
//  Created by Thomas Martins on 04/11/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit
import SocketIO
import SwiftyJSON
import PromiseKit
import WebRTC


class VideoCallController: UIViewController, RTCClientDelegate{
    var viewController: UIViewController?
    @IBOutlet private weak var _userView: UIView!
    @IBOutlet private weak var _hangUpButton: UIButton!
    
    @IBOutlet weak var personView: RTCEAGLVideoView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var _currentUserView: UIStackView!
    private var views: [UIView] = []

    var captureController: RTCCapturer! 

    
    var localVideoTrack: RTCVideoTrack?
    var remoteVideoTrack: RTCVideoTrack?
    
    private func getVideoConfigurationFromServer(route: String) -> Promise<[Any]> {
        return Promise { seal in
            SocketManager.sharedInstance.getManager().defaultSocket.on(route) {
                data, ack in
                    seal.resolve(data, nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Calling..."
        SocketManager.sharedInstance.getManager().defaultSocket.emit("webrtc_credentials")
        self.makeCall()
    }
    
    private func makeCall() {
        let urls = [
            "stun:webrtc.neo.ovh",
            "turn:webrtc.neo.ovh:3478" ]
        
        self.getVideoConfigurationFromServer(route: "webrtc_config").done { (item) in
            
            let values: [[String: Any]] = item as! [[String: Any]]
            for item in values {
                let username = item["username"] as! String
                let password = item["password"] as! String
                print("BEFORE")
                self.startCalling(password: password, username: username, urls: urls)
                break
            }
        }
    }
    
    private func startCalling(password: String, username: String, urls: [String]) {
        
        print("ICE SERVER = password -> \(password) && username -> \(username) && urls -> \(urls)")
        
        let ice = RTCIceServer.init(urlStrings: urls, username: username, credential: password)
        
        let client = RTCClient(iceServers: [ice], videoCall: true)
        client.delegate = self
        client.startConnection()
        self.configVideo()
        print("CALLING \(client)")
    }
    
    private func configVideo() {
        
    
        
    }
    
    func rtcClient(client : RTCClient, didReceiveError error: Error) {
        print("WEBRTC an error occured -> \(error)")
    }
    
    func rtcClient(client: RTCClient, didCreateLocalCapturer capturer: RTCCameraVideoCapturer) {
        if UIDevice.current.model != "Simulator" {
            print("YES IT IS")
            
            let settingsModel = RTCCapturerSettingsModel()
            self.captureController = RTCCapturer.init(withCapturer: capturer, settingsModel: settingsModel)
            captureController.startCapture()
        }
        print("*** METHOD didCreateLocalCapturer \(capturer)***")
        
    }
    
    func rtcClient(client: RTCClient, didGenerateIceCandidate iceCandidate: RTCIceCandidate) {
        print("*** METHOD didGenerateIceCandidate ***")
    }
    
    func rtcClient(client: RTCClient, didReceiveRemoteVideoTrack localVideoTrack: RTCVideoTrack) {
        self.remoteVideoTrack = localVideoTrack
        self.remoteVideoTrack?.add(personView)
        print("*** METHOD didReceiveRemoteVideoTrack ***")
        
    }
    
    func rtcClient(client: RTCClient, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack) {

        self.remoteVideoTrack = localVideoTrack
        self.remoteVideoTrack?.add(personView)
    
        print("*** METHOD didReceiveLocalVideoTrack ***")
    }
    
    func rtcClient(client: RTCClient, startCallWithSdp sdp: String) {
        print("*** METHOD startCallWithSdp ***")
    }
    
    private func configureAudio() {
        
//        QBRTCConfig.mediaStreamConfiguration().audioCodec = .codecOpus
//        QBRTCAudioSession.instance().initialize { (configuration: QBRTCAudioSessionConfiguration) -> () in
//
//            var options = configuration.categoryOptions
//            if #available(iOS 10.0, *) {
//                options = options.union(AVAudioSessionCategoryOptions.allowBluetoothA2DP)
//                options = options.union(AVAudioSessionCategoryOptions.allowAirPlay)
//            } else {
//                options = options.union(AVAudioSessionCategoryOptions.allowBluetooth)
//            }
//
//            configuration.categoryOptions = options
//            configuration.mode = AVAudioSessionModeVideoChat
//        }
//        QBRTCAudioSession.instance().currentAudioDevice = .speaker
    }
    
    private func setVideoSettings() {
        
        
//        QBRTCConfig.mediaStreamConfiguration().videoCodec = .H264
//
//        let videoFormat = QBRTCVideoFormat()
//        videoFormat.frameRate = 21
//        videoFormat.pixelFormat = .format420f
//        videoFormat.width = 640
//        videoFormat.height = 480
//
//        self.videoCapture = QBRTCCameraCapture(videoFormat: videoFormat, position: .front)
//        self.videoCapture.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
//
//        self.videoCapture.startSession {
//
//            let localView = LocalVideoView(withPreviewLayer:self.videoCapture.previewLayer)
//            self.views.append(localView)
//            self.stackView.addArrangedSubview(localView)
//        }
        
    }
}
