//
//  ViewController.swift
//  PhotoStorageOptimizer
//
//  Created by ruixingchen on 2020/4/28.
//  Copyright © 2020 ruixingchen. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    let tabView = NSTabView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.tabView)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

