//
//  VideoCallController.swift
//  Neo
//
//  Created by Thomas Martins on 04/11/2018.
//  Copyright © 2018 Neo. All rights reserved.
//

import UIKit

class VideoCallController: UIViewController {

    var viewController: UIViewController?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.performVideoCall()
    }
    
    private func performVideoCall() {
        print("Performing video call..")
    }
}
