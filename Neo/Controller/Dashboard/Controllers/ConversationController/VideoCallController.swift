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

struct  WebRtcData: SocketData {
    let email: String
    var message = Dictionary<String, Any>()
    
    func socketRepresentation() -> SocketData {
        
        return ["email": email, "message": message]
    }
}

class VideoCallController: UIViewController, RTCClientDelegate{
    
    var viewController: UIViewController?
    
    @IBOutlet weak var personView: RTCEAGLVideoView!
    @IBOutlet weak var userVIew: RTCEAGLVideoView!
    
    weak var remoteVideoTrack: RTCVideoTrack?
    weak var localVideoTrack: RTCVideoTrack?
    
    var client: RTCClient? = nil
    
    var captureController: RTCCapturer!
    var videoClient: RTCClient?
    var isCallReady =  false
    var isCaller = false
    
    @IBOutlet private weak var _buttonCalling: UIButton!
    
    @IBAction func startCallingNow(_ sender: Any) {
        
        self.initClient {
            print("** USER -> \(User.sharedInstance.getEmail()) starting call with -> \(self.__TEMPORARY__GetInformations())")
            self.isCaller = true
            self.client?.makeOffer()
        }
    }
    
    private func requestionAccessOnPhone() -> Bool{
        var audioRequest = false
        var cameraRequest = false
        
        AVAudioSession.sharedInstance().requestRecordPermission { (result) in
           audioRequest = result
        }

        AVCaptureDevice.requestAccess(for: AVMediaType.video) { (result) in
            cameraRequest = result
        }
        
        return audioRequest && cameraRequest
    }
    
    override func viewDidLoad() {
        
        SocketManager.sharedInstance.getManager().defaultSocket.on("webrtc_forward") {
            data, ack in
            
            var info = JSON(data[0])["content"]["message"]
            
            if info["offer"] != nil {
                
                self.initClient {
                    self.client?.createAnswerForOfferReceived(withRemoteSDP: info["offer"].stringValue)
                }
            } else if info["answer"] != nil {
                self.client?.handleAnswerReceived(withRemoteSDP: info["answer"].stringValue)
                print("we handle the sdp remote")
            }
            else if info["ice"] != nil {
                
                let sdp = info["ice"]["candidate"].stringValue
                let sdpMlineindex = Int32(info["info"]["label"].intValue)
                let sdpmid = info["info"]["id"].stringValue
                
                let ice = RTCIceCandidate(sdp: sdp, sdpMLineIndex: sdpMlineindex, sdpMid: sdpmid)
                
                self.client?.addIceCandidate(iceCandidate: ice)
                
                print("USER = \(User.sharedInstance.getEmail()) ADDING ICE \(info["ice"])")
                
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //self.client.disconnect()
    }
    
    private func initClient(completion: @escaping () -> ()) {
        
        SocketManager.sharedInstance.getManager().defaultSocket.emit("webrtc_credentials")
        
        SocketManager.sharedInstance.getManager().defaultSocket.on("webrtc_config") {
            data, ack in
            
            var informations = JSON(data[0])
            
            let urls = ["stun:webrtc.neo.ovh:3478",
                        "turn:webrtc.neo.ovh:3478"]
            
            let iceServer: RTCIceServer = RTCIceServer(urlStrings: urls, username: informations["username"].stringValue, credential:informations["password"].stringValue)
            
            let client = RTCClient(iceServers: [iceServer], videoCall: true)
            client.delegate = self
            self.videoClient = client
            self.client = client
            self.isCallReady = true
            self.client?.startConnection()
            print("*** starting the connection *** // user -> \(informations["username"].stringValue)")
            
            completion()
        }
    }
    
    func rtcClient(client: RTCClient, didCreateLocalCapturer capturer: RTCCameraVideoCapturer) {
        if UIDevice.current.name != "Simulator" {
            let settingsModel = RTCCapturerSettingsModel()
            self.captureController = RTCCapturer.init(withCapturer: capturer, settingsModel: settingsModel)
            captureController.startCapture()
        }
    }

    func rtcClient(client: RTCClient, didGenerateIceCandidate iceCandidate: RTCIceCandidate) {

        var dict = Dictionary<String, Any>()
        
        let jsonObject: [String: Any] = [
            "label": iceCandidate.sdpMLineIndex,
            "id": iceCandidate.sdpMid!,
            "candidate": iceCandidate.sdp
        ]
        
        dict["ice"] = jsonObject
        
        SocketManager.sharedInstance.getManager().defaultSocket.emit("webrtc_forward", WebRtcData(email: self.__TEMPORARY__GetInformations(), message: dict))
    }
    
    func rtcClient(client : RTCClient, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack) {
        print("we received video local")
        localVideoTrack.add(self.userVIew)
        self.localVideoTrack = localVideoTrack
    }
    func rtcClient(client : RTCClient, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack) {
        print("we received video remote")
        
        if (UIDevice.current.name).isEqualToString(find: "Thomas's iPhone") {
            remoteVideoTrack.add(self.personView)
            self.remoteVideoTrack = remoteVideoTrack
        }else {
            remoteVideoTrack.add(self.userVIew)
            self.localVideoTrack = remoteVideoTrack
        }
    }
    
    private func __TEMPORARY__GetInformations() -> String{
        var email = ""
        
        if (UIDevice.current.name).isEqualToString(find: "Thomas's iPhone") {
            email = "ok@o.com"
        }else {
            email = "j@j.com"
        }
        return email
    }
    
    func rtcClient(client: RTCClient, startCallWithSdp sdp: String) {
        
        if isCaller {
            var dict = Dictionary<String, String>()
            dict["offer"] = sdp
            SocketManager.sharedInstance.getManager().defaultSocket.emit("webrtc_forward", WebRtcData(email: self.__TEMPORARY__GetInformations(), message: dict))
        } else {
            var dict = Dictionary<String, String>()
            dict["answer"] = sdp
            SocketManager.sharedInstance.getManager().defaultSocket.emit("webrtc_forward", WebRtcData(email: self.__TEMPORARY__GetInformations(), message: dict))
        }
    }
    
    func rtcClient(client : RTCClient, didReceiveError error: Error) {
        print("AN ERROR OCCURED -> \(error)")
    }
}
