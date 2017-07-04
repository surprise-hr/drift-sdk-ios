//
//  ViewController.swift
//  SDKExample
//
//  Created by Eoin O'Connell on 29/05/2017.
//  Copyright © 2017 drift. All rights reserved.
//

import UIKit
import Drift

class ViewController: UIViewController {

    @IBAction func showConversationButton(_ sender: Any) {
        Drift.showConversations()
    }
}

