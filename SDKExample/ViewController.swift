//
//  ViewController.swift
//  SDKExample
//
//  Created by Eoin O'Connell on 24/02/2020.
//  Copyright © 2020 Drift. All rights reserved.
//

import UIKit
import Drift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func showConversationsPressed() {
        Drift.showConversations()
    }
    
}

