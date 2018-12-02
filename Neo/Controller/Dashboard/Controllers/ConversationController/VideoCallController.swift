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

class VideoCallController: UIViewController{
    
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
    

    
    @IBAction func startCallingNow(_ sender: Any) {
        
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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.webRTCClient.delegate = self
        self.webRTCClient.getConfiguration {
            print("configuration done")
        }

        
        SocketManager.sharedInstance.getManager().defaultSocket.on("webrtc_forward") {
            data, ack in
            
            
            
            
            let getData = JSON(data[0])["content"]["message"].stringValue
            
            guard let data = getData.data(using: .utf8),
                let message = try? JSONDecoder().decode(VideoMessage.self, from: data) else {
                    return
            }
            
            switch message.type {
            case .candidate:
                if let candidate = RTCIceCandidate.fromJsonString(message.payload) {
                    //self.delegate?.signalClient(self, didReceiveCandidate: candidate)
                    self.webRTCClient.set(remoteCandidate: candidate)
                    self.remoteCandidateCount += 1
                    
                }
            case .sdp:
                if let sdp = RTCSessionDescription.fromJsonString(message.payload) {
                    self.webRTCClient.set(remoteSdp: sdp, completion: { (error) in
                        self.webRTCClient.answer(completion: { (sdp) in
                            self.hasLocalSdp = true
                            self.send(sdp: sdp)
                        })
                    })
                }
            }
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
        
        
        var dict = Dictionary<String, Any>()
        
        let jsonObject: [String: Any] = [
            "label": candidate.sdpMLineIndex,
            "id": candidate.sdpMid!,
            "candidate": candidate.sdp
        ]
        
        dict["candidate"] = jsonObject
        
        SocketManager.sharedInstance.getManager().defaultSocket.emit("webrtc_forward", WebRtcData(email: self.__TEMPORARY__GetInformations(), message: dict))
        
        self.send(candidate: candidate)
        
    }
}

struct VideoMessage: Codable {
    enum PayloadType: String, Codable {
        case sdp, candidate
    }
    let type: PayloadType
    let payload: String
}

struct  WebRTC: SocketData {
    let email: String
    let message: String
    
    func socketRepresentation() -> SocketData {
        return ["email": email, "message": message]
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
    
    func send(sdp: RTCSessionDescription) {
        let message = VideoMessage(type: .sdp, payload: sdp.jsonString() ?? "")
        if let dataMessage = try? JSONEncoder().encode(message),
            let stringMessage = String(data: dataMessage, encoding: .utf8) {
            SocketManager.sharedInstance.getManager().defaultSocket.emit("webrtc_forward", WebRTC(email: self.__TEMPORARY__GetInformations(), message: stringMessage))
        }
    }
}
