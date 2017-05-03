//
//  RotationGestureRecognizer.swift
//  VocalFun
//
//  Created by Gaurav Pathak on 4/30/17.
//  Copyright © 2017 gpmax. All rights reserved.
//
import UIKit
import UIKit.UIGestureRecognizerSubclass

class RotationGestureRecognizer: UIPanGestureRecognizer {
    
    var rotation: CGFloat = 0.0

    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: #selector(MainPanelViewController.handleRotation))
        
        minimumNumberOfTouches = 1
        maximumNumberOfTouches = 1
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
         super.touchesMoved(touches, with: event)
         updateRotationWithTouches(touches: touches)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        updateRotationWithTouches(touches: touches)
    }
    
    
    func updateRotationWithTouches(touches: Set<NSObject>) {
        if let touch = touches[touches.startIndex] as? UITouch {
            self.rotation = rotationForLocation(location: touch.location(in: self.view))
        }
    }
    
    func rotationForLocation(location: CGPoint) -> CGFloat {
        let offset = CGPoint(x: location.x - view!.bounds.midX, y: location.y - view!.bounds.midY)
        return atan2(offset.y, offset.x)
    }
}
