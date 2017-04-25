//
//  MainPanelViewController.swift
//  VocalFun
//
//  Created by Gaurav Pathak on 4/19/17.
//  Copyright © 2017 gpmax. All rights reserved.
//

import UIKit

class MainPanelViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    let transition = TransitionEffect()
    
    @IBOutlet weak var micButton: DesinableButtons!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let secondVC = segue.destination as! RecordingViewController
        secondVC.transitioningDelegate = self
        secondVC.modalPresentationStyle = .custom
    }
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = micButton.center
        transition.circleColor = micButton.backgroundColor!
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = micButton.center
        transition.circleColor = micButton.backgroundColor!
        
        return transition
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

