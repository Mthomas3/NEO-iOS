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

class VideoCallController: UIViewController{

    var viewController: UIViewController?
    
    var webRTCClient = WebRTCClient()
    var hasLocalSdp: Bool = false
    var remoteCandidateCount = 0
    var isViewDisplayed = false
    var isCaller = false
    var isUserConnected = false
    var callTimer = Timer()
    var eventTimer = Timer()
    var isReadySet = false
    
    var ping = false
    var pong = false
    
    public var OpponentEmail: String? = nil
    public var OpponentId: Int? = nil
    
    struct socketDataObject: SocketData {
        
        let user_id: Int
        var message = Dictionary<String, Any>()
        
        func socketRepresentation() -> SocketData {
            return ["user_id": user_id, "message": message]
        }
    }
    
    struct socketDataMessage: SocketData {
        let id: Int
        let message: String
        
        func socketRepresentation() -> SocketData {
            return ["user_id": id, "message": message]
        }
    }
    
    @IBAction func showVideo(_ sender: Any) {
        let vc = VideoViewTestController(webRTCClient: self.webRTCClient)
        self.present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func needToCall(_ sender: Any) {
        SocketManager.sharedInstance.getManager().defaultSocket.emit("webrtc_forward", socketDataMessage(id: self.OpponentId!, message: "CALLING"))
        self.isUserConnected = true
    }
    
    private func requestionAccessOnPhone() -> Bool {
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
    
    @IBAction func clickTest(_ sender: Any) {
//        let vc = VideoViewTestController(webRTCClient: self.webRTCClient)
//        self.present(vc, animated: true, completion: nil)
    }
    
    public func presentVideoView() {
        if !isViewDisplayed {
            self.isViewDisplayed = true
            let vc = VideoViewTestController(webRTCClient: self.webRTCClient)
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    private func sendPing() {
        if isUserConnected {
            SocketManager.sharedInstance.getManager().defaultSocket.emit("webrtc_forward", socketDataMessage(id: self.OpponentId!, message: "PING"))
            print("SEND PING")
        }
  }
    
    private func sendPong() {
        
        if isUserConnected {
            SocketManager.sharedInstance.getManager().defaultSocket.emit("webrtc_forward", socketDataMessage(id: self.OpponentId!, message: "PONG"))
            print("SEND PONG")

        }
    }
    
    private func stopCalling() {
        
        self.dismiss(animated: true) {
            self.webRTCClient.disconnectPeerUser()
            self.isUserConnected = false
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func handleReady() {
        self.isReadySet = true
        self.webRTCClient.getConfiguration {
            self.webRTCClient.offer(completion: { (sdp) in
                self.hasLocalSdp = true
                self.isUserConnected = true
                self.sendWeb(sdp: sdp.sdp, type: "offer")
            })
        }
    }
    
    private func handleCalling() {
        
        print("CHECK HANDLE CALLING WEBRTC -> \(self.webRTCClient)")
        
        print("isConnecter -> \(self.isUserConnected) isCaller -> \(self.isCaller) isDisplayed -> \(self.isViewDisplayed)")
        
        self.webRTCClient.getConfiguration {
            SocketManager.sharedInstance.getManager().defaultSocket.emit("webrtc_forward", socketDataMessage(id: self.OpponentId!, message: "READY"))
            self.isUserConnected = true
        }
    }
    
    private func manageSdp(sdp: JSON) {
        
        if sdp["data"]["type"].stringValue.isEqualToString(find: "offer") {

            let currentSDPReceived = sdp["data"]["sdp"].stringValue
            let sdp = RTCSessionDescription(type: .offer, sdp: currentSDPReceived)

            self.webRTCClient.set(remoteSdp: sdp) { (error) in

                self.webRTCClient.answer(completion: { (sdp) in
                    print("Making the answer ***")
                    self.hasLocalSdp = true
                    self.sendWeb(sdp: sdp.sdp, type: "answer")
                })
            }
        } else if sdp["data"]["type"].stringValue.isEqualToString(find: "answer") {

            let currentSDPReceived = sdp["data"]["sdp"].stringValue
            let sdp = RTCSessionDescription(type: .answer, sdp: currentSDPReceived)

            self.webRTCClient.set(remoteSdp: sdp) { (error) in
                print("[Setting REMOTE SDP -> \(error)]")
            }
        }
    }
    
    private func handleCandidate(candidate: JSON) {
        
        let sdp = candidate["candidate"].stringValue
        let sdpLine = candidate["sdpMLineIndex"].intValue
        let sdpMid = candidate["sdpMid"].stringValue
        let candidate = RTCIceCandidate(sdp: sdp, sdpMLineIndex: Int32(sdpLine), sdpMid: sdpMid)

        self.webRTCClient.set(remoteCandidate: candidate)
        print("WE PASS IN THE REMOTE CHECK HERE DUDE")
        self.remoteCandidateCount += 1
        if self.remoteCandidateCount >= 1 {
            self.presentVideoView()
        }
        print(self.remoteCandidateCount)
    }
    
    private func setUpCall(data: JSON) {
        
        switch data[0]["content"]["message"]["type"] {
        case "sdp":
            print("SDP : \(data[0]["content"]["message"])")
            self.manageSdp(sdp: data[0]["content"]["message"])
        default:
            print("UNDEFINED SETUPCALL -> \(data[0]["content"]["message"]["type"])")
        }
    }
    
    private func OpponentUnavailable() {
        self.webRTCClient.disconnectPeerUser()
        self.isUserConnected = false
        self.navigationController?.popViewController(animated: true)
    }
    
    private func handleSocketOnData(data: JSON) {
        
        switch JSON(data[0])["content"]["message"].stringValue {
            case "CALLING":
                self.handleCalling()
            case "PING":
                print("INSIDE PING")
                self.ping = true
                self.pong = true

                self.sendPong()
            case "PONG":
                print("INSIDE PONG")
                self.pong = true
                self.ping = true

                self.sendPing()
            case "QUITTING":
                self.stopCalling()
            case "READY":
                self.handleReady()
            case "UNAVAILABLE":
                self.OpponentUnavailable()
            case "candidate":
                self.handleCandidate(candidate: JSON(data))
            default:
                print("undefined first witch ** (\(JSON(data)[0]["content"])) **")
            
            }
            
            switch JSON(data)[0]["content"]["message"]["type"] {
                case "sdp":
                    self.setUpCall(data: JSON(data))
                case "candidate":
                    self.handleCandidate(candidate: JSON(data)[0]["content"]["message"]["data"])
                default:
                    print("undefined second witch ** (\(JSON(data)[0]["content"])) **")
            }
    }
    
    @objc func checkPong() {
        print("** INSIDE CHECK PONG **")
        print("value ping -> \(self.ping) && value pong -> \(self.pong)")
        
        if self.ping == false && self.pong == false {
            
            self.isViewDisplayed = false
            self.isUserConnected = false
            self.webRTCClient.disconnectPeerUser()
            self.dismiss(animated: true)
            self.navigationController?.popViewController(animated: true)
            
        }
        
        self.ping = false
        self.pong = false
    }
    
    func scheduledTimerWithTimeInterval(){
        callTimer = Timer.scheduledTimer(timeInterval: 25, target: self, selector: #selector(VideoCallController.updateCounting), userInfo: nil, repeats: false)
        
        eventTimer = Timer.scheduledTimer(timeInterval: 12, target: self, selector: #selector(VideoCallController.checkPong), userInfo: nil, repeats: true)
    }
    
    @objc func updateCounting(){
        
        if !isReadySet && isCaller {
            self.isUserConnected = false
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func handleUserNotConnected() {
        print("IS USER NOT CONNECTED?")
        self.isUserConnected = false
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if isViewDisplayed {
            print("INSIDE VIEW WILL APPEAR")
            self.isViewDisplayed = false
            self.isUserConnected = false
            self.webRTCClient.disconnectPeerUser()
            self.navigationController?.popViewController(animated: true)
            SocketManager.sharedInstance.getManager().defaultSocket.emit("webrtc_forward", socketDataMessage(id: self.OpponentId!, message: "QUITTING"))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scheduledTimerWithTimeInterval()
        
        self.webRTCClient.delegate = self
        
        if (self.requestionAccessOnPhone()) {
            DisplayMessage.displayMessageAsAlert(title: "Accès Micro + Video", message: "Veuillez autoriser les accés", controller: self)
            let result = self.requestionAccessOnPhone()
            print(result)
        }

        if isCaller {
            SocketManager.sharedInstance.getManager().defaultSocket.emit("webrtc_forward", socketDataMessage(id: self.OpponentId!, message: "CALLING"))
            self.isUserConnected = true
            
        } else {
            self.handleCalling()
        }

        SocketManager.sharedInstance.getManager().defaultSocket.on("webrtc_forward") {
            data, ack in
            self.handleSocketOnData(data: JSON(data))
        }
    }
}

extension VideoCallController : WebRTCClientDelegate {
    
    struct sendCandidateObject: SocketData {
        let user_id: Int
        var message = Dictionary<String, Any>()
        
        func socketRepresentation() -> SocketData {
            return ["user_id": user_id, "message": message]
        }
    }

    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        
        let jsonObject: [String: Any] = [
            "type": "candidate",
            "data": ["candidate": candidate.sdp, "sdpMid": candidate.sdpMid!, "sdpMLineIndex": candidate.sdpMLineIndex]
        ]
        
        SocketManager.sharedInstance.getManager().defaultSocket.emit("webrtc_forward", sendCandidateObject(user_id: self.OpponentId!, message: jsonObject))
    }
}

extension VideoCallController {           
    
    func sendWeb(sdp: String, type: String) {
     
        let jsonObject: [String: Any] = [
            "type": "sdp",
            "data": ["sdp": sdp, "type": type]
        ]
        
        SocketManager.sharedInstance.getManager().defaultSocket.emit("webrtc_forward", socketDataObject(user_id: self.OpponentId!, message: jsonObject))
    }
}
