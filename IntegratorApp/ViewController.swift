//
//  ViewController.swift
//  IntegratorApp
//
//  Created by Jorge Poveda on 27/2/23.
//

import UIKit
import PackageDepA

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        PackageDepA().version
    }
}
