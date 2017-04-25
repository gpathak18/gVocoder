//
//  RecordingViewController.swift
//  VocalFun
//
//  Created by Gaurav Pathak on 4/19/17.
//  Copyright © 2017 gpmax. All rights reserved.
//

import UIKit

class RecordingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButton(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

