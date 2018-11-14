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


class VideoCallController: UIViewController, RTCPeerConnectionDelegate{
    
    var viewController: UIViewController?
    
    @IBOutlet weak var personView: RTCEAGLVideoView!
    @IBOutlet weak var userVIew: RTCEAGLVideoView!
    
    var captureController: RTCCapturer!
    
    var localVideoTrack: RTCVideoTrack?
    var remoteVideoTrack: RTCVideoTrack?
    let isVideoCall = true
    
    @IBOutlet private weak var _buttonCalling: UIButton!
    
    @IBAction func startCallingNow(_ sender: Any) {
        self.makeCall()
    }
    
    fileprivate var connectionFactory: RTCPeerConnectionFactory = RTCPeerConnectionFactory()
    fileprivate var peerConnection: RTCPeerConnection?
    fileprivate let defaultConnectionConstraint = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: ["DtlsSrtpKeyAgreement": "true"])
    
    fileprivate let videoCallConstraint = RTCMediaConstraints(mandatoryConstraints: ["OfferToReceiveAudio" : "true", "OfferToReceiveVideo": "true"],
                                                              optionalConstraints: nil)
    
    
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
        SocketManager.sharedInstance.getManager().defaultSocket.on("webrtc_forward") {
            data, ack in
            
            print("THE DATA \(data) && ACK \(ack)")
            
        }
    }
    
    private func makeCall() {
        //SocketManager.sharedInstance.getManager().defaultSocket.emit("webrtc_credentials")
        let urls = [
            "stun:webrtc.neo.ovh:3478",
            "turn:webrtc.neo.ovh:3478" ]

        self.startCalling(password: "aze", username: "azea", urls: ["azeaea"])
//        self.getVideoConfigurationFromServer(route: "webrtc_config").done { (item) in
//
//            let values: [[String: Any]] = item as! [[String: Any]]
//            for item in values {
//                let username = item["username"] as! String
//                let password = item["password"] as! String
//                print("password \(password)")
//                self.startCalling(password: password, username: username, urls: urls)
//                break
//            }
//        }
        
    }
    
    func defaultICEServer(username: String, password: String) -> [RTCIceServer] {
        let urls = [
            "stun:webrtc.neo.ovh:3478",
            "turn:webrtc.neo.ovh:3478" ]
        
        return [RTCIceServer(urlStrings: urls, username: username, credential: password)]
    }
    
    func didCreateLocalCapturer(didCreateLocalCapturer capturer: RTCCameraVideoCapturer) {
        print("did create local capturer yes")
    }
    
    func localStream() -> RTCMediaStream {
        let factory = self.connectionFactory
        let localStream = factory.mediaStream(withStreamId: "RTCmS")
        
        if self.isVideoCall {
            if !AVCaptureState.isVideoDisabled {
                
                let videoSource: RTCVideoSource = factory.videoSource()
                let capturer = RTCCameraVideoCapturer(delegate: videoSource)
                
                self.didCreateLocalCapturer(didCreateLocalCapturer: capturer)
                
                let videoTrack = factory.videoTrack(with: videoSource, trackId: "RTCvS0")
                videoTrack.isEnabled = true
                localStream.addVideoTrack(videoTrack)
                
            } else {
                print("video is not enable...")
            }
        }
        
        if !AVCaptureState.isAudioDisabled {
            let audioTrack = factory.audioTrack(withTrackId: "RTCaS0")
            localStream.addAudioTrack(audioTrack)
        } else {
            print("audio is not enable...")
        }
        return localStream
    }
    

    private func didReceiveLocalVideoTrack(didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack) {
        print("didReceiveLocalVideoTrack")
    }
    
    private func startConnection() {
        guard let peerConnection = self.peerConnection else {
            print("Peer connection guard")
            return
        }
        let localstream = self.localStream()
        peerConnection.add(localstream)
        if let localVideoTrack = localstream.videoTracks.first {
            self.didReceiveLocalVideoTrack(didReceiveLocalVideoTrack: localVideoTrack)
        }
    }
    
    struct  WebRtcData: SocketData {
        let email: String
        let message: String
        
        func socketRepresentation() -> SocketData {
            return ["email": email, "message": message]
        }
    }
    
    private func makeOffer() {
        self.peerConnection?.offer(for: self.videoCallConstraint, completionHandler: { (sdp, error) in
           // print("the sdp is ...\(sdp)")
            SocketManager.sharedInstance.getManager().defaultSocket.emit("webrtc_forward", WebRtcData(email: User.sharedInstance.getParameter(parameter: "email"), message: "CALLING"))
            
        })
    }
    
    private func startCalling(password: String, username: String, urls: [String]) {
        RTCPeerConnectionFactory.initialize()
        self.connectionFactory = RTCPeerConnectionFactory()
        
        let configuration = RTCConfiguration()
        
        //configuration.iceServers = self.defaultICEServer(username: username, password: password)
        self.peerConnection = self.connectionFactory.peerConnection(with: configuration, constraints: self.defaultConnectionConstraint, delegate: self)
        self.startConnection()
        print("TEST HERE")
        self.makeOffer()
        
    }
    

    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        print("first")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        print("second")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        print("third")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        print("fourth")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        print("fifth")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        print("six")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        print("hey")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        print("tg")
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        
    }
}
