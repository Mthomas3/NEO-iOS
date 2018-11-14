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
    
    @IBOutlet weak var personView: RTCEAGLVideoView!
    @IBOutlet weak var userVIew: RTCEAGLVideoView!
    
    var captureController: RTCCapturer!
    
    var localVideoTrack: RTCVideoTrack?
    var remoteVideoTrack: RTCVideoTrack?
    private var client: RTCClient!
    
    
    private func getVideoConfigurationFromServer(route: String) -> Promise<[Any]> {
        return Promise { seal in
            SocketManager.sharedInstance.getManager().defaultSocket.on(route) {
                data, ack in
                    seal.resolve(data, nil)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.client.disconnect()
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
        
        client = RTCClient(iceServers: nil, videoCall: true)
        client.delegate = self
        client.startConnection()
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
        //self.captureController.switchCamera()
        print("*** METHOD didCreateLocalCapturer \(capturer)***")
        
    }
    
    func rtcClient(client: RTCClient, didGenerateIceCandidate iceCandidate: RTCIceCandidate) {
        
        print("CADIDAT = \(iceCandidate)")
        self.client.addIceCandidate(iceCandidate: iceCandidate)
        print("*** METHOD didGenerateIceCandidate ***")
    }
    
    func rtcClient(client: RTCClient, didReceiveRemoteVideoTrack localVideoTrack: RTCVideoTrack) {
        self.remoteVideoTrack = localVideoTrack
        self.remoteVideoTrack?.add(personView)
        print("*** METHOD didReceiveRemoteVideoTrack ***")
    }
    
    func rtcClient(client: RTCClient, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack) {

        self.localVideoTrack = localVideoTrack
        self.localVideoTrack?.add(userVIew)
        print("*** METHOD didReceiveLocalVideoTrack ***")
    }
    
    func rtcClient(client: RTCClient, startCallWithSdp sdp: String) {
        self.client.handleAnswerReceived(withRemoteSDP: sdp)
        print("*** METHOD startCallWithSdp ***")
    }
}
