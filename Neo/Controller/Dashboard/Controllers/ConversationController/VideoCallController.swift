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

extension StringProtocol where Index == String.Index {
    var lines: [SubSequence] {
        return split(maxSplits: .max, omittingEmptySubsequences: true, whereSeparator: { $0 == "\n" })
    }
    var removingAllExtraNewLines: String {
        return lines.joined(separator: "\n")
    }
}

struct  WebRtcData: SocketData {
    let email: String
    var message = Dictionary<String, Any>()
    
    func socketRepresentation() -> SocketData {
        
        return ["email": email, "message": message]
    }
}

struct sendMessageVideo: SocketData {
    let id: Int
    let message: String
    
    func socketRepresentation() -> SocketData {
        return ["user_id": id, "message": message]
    }
}

class VideoCallController: UIViewController{
    
    public let callingEmail: String? = nil
    public let callerEmail: String? = nil
    
    /// OLD
    var viewController: UIViewController?
    @IBOutlet weak var personView: RTCEAGLVideoView!
    @IBOutlet weak var userVIew: RTCEAGLVideoView!
    weak var remoteVideoTrack: RTCVideoTrack?
    weak var localVideoTrack: RTCVideoTrack?
   
    var isCallReady =  false
    var isCaller = false
    fileprivate var remoteIceCandidates: [RTCIceCandidate] = []
    @IBOutlet private weak var _buttonCalling: UIButton!
    
    /// NEW
    let webRTCClient = WebRTCClient()
    var hasLocalSdp: Bool = false
    var localCandidateCount = 0
    var remoteCandidateCount = 0
    
    //User to call
    public var OpponentEmail: String? = nil
    public var OpponentId: Int? = nil

    
    @IBAction func startCallingNow(_ sender: Any) {
        
        SocketManager.sharedInstance.getManager().defaultSocket.emit("webrtc_forward", sendMessageVideo(id: self.OpponentId!, message: "CALLING"))
        
        
        

        
        
        
        self.webRTCClient.offer { (sdp) in
            self.hasLocalSdp = true
            self.send(sdp: sdp)
            print("[\(User.sharedInstance.getEmail())] send an offer to -> [\(self.__TEMPORARY__GetInformations())]")




        }
    }
    
    
    @IBAction func didTouchSpeaker(_ sender: Any) {
        
        let vc = VideoViewTestController(webRTCClient: self.webRTCClient)
        self.present(vc, animated: true, completion: nil)
        
        print("the view -> \(vc)")
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    private func sendPing() {
        SocketManager.sharedInstance.getManager().defaultSocket.emit("webrtc_forward", sendMessageVideo(id: self.OpponentId!, message: "PING"))

    }
    
    private func sendPong() {
        SocketManager.sharedInstance.getManager().defaultSocket.emit("webrtc_forward", sendMessageVideo(id: self.OpponentId!, message: "PONG"))
    }
    
    private func OpponentReadyStartingCall() {
        self.webRTCClient.offer { (sdp) in
            self.hasLocalSdp = true
            self.send(sdp: sdp)
        }
    }
    
    private func stopCalling() {
        print("need to stop calling here")
    }
    
    private func handleCalling() {
        SocketManager.sharedInstance.getManager().defaultSocket.emit("webrtc_forward", sendMessageVideo(id: self.OpponentId!, message: "READY"))
    }
    
    private func manageSdp(sdp: JSON) {
        
        print("SDP GOT -> \(sdp)")
        
        if sdp["data"]["type"].stringValue.isEqualToString(find: "offer") {
            let currentSDPReceived = sdp["data"]["sdp"].stringValue
            let sdp = RTCSessionDescription(type: .offer, sdp: currentSDPReceived)
            
            self.webRTCClient.set(remoteSdp: sdp) { (error) in
            
                self.webRTCClient.answer(completion: { (sdp) in
                    self.hasLocalSdp = true
                    self.sendWeb(sdp: sdp.sdp, type: "answer")
                })
            }
            
        }
    }
    
    private func handleCandidate(candidate: JSON) {
//        if let candidate = RTCIceCandidate.fromJsonString(message.payload) {
//                                //self.delegate?.signalClient(self, didReceiveCandidate: candidate)
//                                self.webRTCClient.set(remoteCandidate: candidate)
//                                self.remoteCandidateCount += 1
//
//                            }
        
        
        let sdp = candidate["candidate"].stringValue
        let sdpLine = candidate["sdpMLineIndex"].intValue
        let sdpMid = candidate["sdpMid"].stringValue
        
        let candidate = RTCIceCandidate(sdp: sdp, sdpMLineIndex: Int32(sdpLine), sdpMid: sdpMid)
        
        print("IS OUR MINE THE BEST CANDIDATE NIL ? -> \(candidate)")
        
        self.webRTCClient.set(remoteCandidate: candidate)
        self.remoteCandidateCount += 1
        
        
        
        
    }
    
    private func setUpCall(data: JSON) {
        
        switch data[0]["content"]["message"]["type"] {
        case "sdp":
            self.manageSdp(sdp: data[0]["content"]["message"])
            
        case "candidate":
            print("WE GET CANDIDATE")
            
        default:
            print("UNDEFINED SETUPCALL -> \(data[0]["content"]["message"]["type"])")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.requestionAccessOnPhone()
        
        self.webRTCClient.delegate = self
        self.webRTCClient.getConfiguration {
            print("configuration done")
        }

        
        SocketManager.sharedInstance.getManager().defaultSocket.on("webrtc_forward") {
            data, ack in
            
            print("THE REAL DATA -> \(JSON(data[0]))")
            
            let _socketData = JSON(data[0])["content"]["message"].stringValue
            
            //if _socketData.is
            print("socket -> \(_socketData)")
            
            switch _socketData {
            case "UNAVAILABLE":
                print("the persone is UNAVAILABLE")
            case "READY":
                self.OpponentReadyStartingCall()
                print("the personne is READY")
            case "PING":
                self.sendPong()
            case "PONG":
                self.sendPing()
            case "QUITTING":
                self.stopCalling()
            case "CALLING":
                self.handleCalling()
            case "candidate":
                self.handleCandidate(candidate: JSON(data))
                
            default:
                print("default")
            }
            
        
            switch JSON(data)[0]["content"]["message"]["type"] {
            case "sdp":
                self.setUpCall(data: JSON(data))
            case "candidate":
                self.handleCandidate(candidate: JSON(data)[0]["content"]["message"]["data"])
            default:
                print("NOPE")
            }
        

            
            
            
            
//            guard let data = _socketData.data(using: .utf8),
//                let message = try? JSONDecoder().decode(VideoMessage.self, from: data) else {
//                    return
//            }
            
//            switch message.type {
//            case .candidate:
//                if let candidate = RTCIceCandidate.fromJsonString(message.payload) {
//                    //self.delegate?.signalClient(self, didReceiveCandidate: candidate)
//                    self.webRTCClient.set(remoteCandidate: candidate)
//                    self.remoteCandidateCount += 1
//
//                }
//            case .sdp:
//                if let sdp = RTCSessionDescription.fromJsonString(message.payload) {
//                    self.webRTCClient.set(remoteSdp: sdp, completion: { (error) in
//                        self.webRTCClient.answer(completion: { (sdp) in
//                            self.hasLocalSdp = true
//                            self.send(sdp: sdp)
//                        })
//                    })
//                }
//            }
        }
    }
    

    
    override func viewWillDisappear(_ animated: Bool) {
        
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
}

extension RTCIceCandidate {
    
    func jsonString() -> String? {
        let dict = [
            CodingKeys.sdp.rawValue: self.sdp,
            CodingKeys.sdpMid.rawValue: self.sdpMid,
            CodingKeys.sdpMLineIndex.rawValue: self.sdpMLineIndex
            ] as [String : Any?]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
            let jsonString = String(data: jsonData, encoding: .utf8)  {
            return jsonString
        }
        return nil
    }
    
    class func fromJsonString(_ string: String) -> RTCIceCandidate? {
        if let data = string.data(using: .utf8),
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
            let jsonDictionary = jsonObject  as? [String: Any?],
            let sdp = jsonDictionary[CodingKeys.sdp.rawValue] as? String ,
            let sdpMid = jsonDictionary[CodingKeys.sdpMid.rawValue] as? String?,
            let sdpMLineIndex = jsonDictionary[CodingKeys.sdpMLineIndex.rawValue] as? Int32{
            return RTCIceCandidate(sdp: sdp, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid)
        }
        
        return nil
    }
    
    enum CodingKeys: String, CodingKey {
        case sdp
        case sdpMLineIndex
        case sdpMid
    }
}

extension RTCSessionDescription {
    
    func jsonString() -> String? {
        let dict = [
            CodingKeys.sdp.rawValue: self.sdp,
            CodingKeys.type.rawValue: self.type.rawValue,
            ] as [String : Any?]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
            let jsonString = String(data: jsonData, encoding: .utf8)  {
            return jsonString
        }
        return nil
    }
    
    class func fromJsonString(_ string: String) -> RTCSessionDescription? {
        
        if let data = string.data(using: .utf8),

            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
            let jsonDictionary = jsonObject  as? [String: Any?],
            let sdp = jsonDictionary[CodingKeys.sdp.rawValue] as? String ,
            let typeNumber = jsonDictionary[CodingKeys.type.rawValue] as? Int,
            let type = RTCSdpType(rawValue: typeNumber) {
            return RTCSessionDescription(type: type, sdp: sdp)
        }
        
        return nil
    }
    
    enum CodingKeys: String, CodingKey {
        case sdp
        case type
    }
}

extension VideoCallController : WebRTCClientDelegate {
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        print("WE GENERATE LOCAL CANDIDATE")
        self.localCandidateCount += 1
        
        let jsonObject: [String: Any] = [
            "type": "candidate",
            "data": ["candidate": candidate.sdp, "sdpMid": candidate.sdpMid!, "sdpMLineIndex": candidate.sdpMLineIndex]
        ]
        
        
        SocketManager.sharedInstance.getManager().defaultSocket.emit("webrtc_forward", sendCandidate(user_id: self.OpponentId!, message: jsonObject))
        
        
        //sendCandidate
//        SocketManager.sharedInstance.getManager().defaultSocket.emit("webrtc_forward", WebRtcData(email: self.__TEMPORARY__GetInformations(), message: dict))
//
        //self.send(candidate: candidate)
        
    }
}

struct VideoMessage: Codable {
    enum PayloadType: String, Codable {
        case sdp, candidate
    }
    let type: PayloadType
    let payload: String
}

struct SendMessageWeb: SocketData {
    let id: Int
    let type: String
    let data: [String: String]
    
    func socketRepresentation() -> SocketData {
        return ["user_id": id, "type": type, "data": data]
    }
}

struct  WebRTC: SocketData {
    let email: String
    let message: String
    
    func socketRepresentation() -> SocketData {
        return ["email": email, "message": message]
    }
}

struct sendCandidate: SocketData {
    let user_id: Int
    var message = Dictionary<String, Any>()

    func socketRepresentation() -> SocketData {
        return ["user_id": user_id, "message": message]
    }
}

struct testSend: SocketData {
    let user_id: Int
    var message = Dictionary<String, Any>()
    
    func socketRepresentation() -> SocketData {
        
        return ["user_id": user_id, "message": message]
    }
}

extension VideoCallController {
    func send(candidate: RTCIceCandidate) {
        
        let message = VideoMessage(type: .candidate, payload: candidate.jsonString() ?? "")
        
        if let dataMessage = try? JSONEncoder().encode(message),
            let stringMessage = String(data: dataMessage, encoding: .utf8) {
            
            SocketManager.sharedInstance.getManager().defaultSocket.emit("webrtc_forward", WebRTC(email: self.__TEMPORARY__GetInformations(), message: stringMessage))
        }
    }
    
    func sendWeb(sdp: String, type: String) {
        
        
        var dict = Dictionary<String, Any>()
        
        let jsonObject: [String: Any] = [
            "type": "sdp",
            "data": ["sdp": sdp, "type": type]
        ]
        
        SocketManager.sharedInstance.getManager().defaultSocket.emit("webrtc_forward", testSend(user_id: self.OpponentId!, message: jsonObject))
        
//        print("WE SEND LIKE ->")
//        print(SendMessageWeb(id: self.OpponentId!, type: "answer", data: ["type": type, "sdp": sdp]))
//
//        SocketManager.sharedInstance.getManager().defaultSocket.emit("webrtc_forward", SendMessageWeb(id: self.OpponentId!, type: "sdp", data: ["type": type, "sdp": sdp]))
//
    }
    
    func send(sdp: RTCSessionDescription) {
        let message = VideoMessage(type: .sdp, payload: sdp.jsonString() ?? "")
        if let dataMessage = try? JSONEncoder().encode(message),
            let stringMessage = String(data: dataMessage, encoding: .utf8) {
            SocketManager.sharedInstance.getManager().defaultSocket.emit("webrtc_forward", sendMessageVideo(id: self.OpponentId!, message: stringMessage))
            
        }
    }
}
