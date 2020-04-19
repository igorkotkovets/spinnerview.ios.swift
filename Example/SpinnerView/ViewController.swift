//
//  ViewController.swift
//  SpinnerView
//
//  Created by Igor Kotkovets on 04/15/2020.
//  Copyright (c) 2020 Igor Kotkovets. All rights reserved.
//

import UIKit
import SpinnerView

class ViewController: UIViewController {
    @IBOutlet private var spinner: SpinnerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        spinner.isAnimating = true

    }

    @IBAction func didToggleAnimating(_ switchControl: UISwitch) {
        spinner.isAnimating = switchControl.isOn
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

