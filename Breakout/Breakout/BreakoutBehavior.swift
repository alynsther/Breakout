//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by Adela  Yang on 4/7/16.
//  Copyright © 2016 Adela  Yang. All rights reserved.
//

import UIKit

class BreakoutBehavior: UIDynamicBehavior {
    
    //creates a collisiion behavior at the edge of the screen that will cause them to collide and stop
    lazy var collider: UICollisionBehavior = {
        let lazyCollider = UICollisionBehavior()
        lazyCollider.translatesReferenceBoundsIntoBoundary = true
        return lazyCollider
    }()
    
    lazy var breakBehavior: UIDynamicItemBehavior = {
        let lazyBreakBehavior = UIDynamicItemBehavior()
        lazyBreakBehavior.allowsRotation = false
        lazyBreakBehavior.elasticity = 0.75
        return lazyBreakBehavior
    }()

    override init() {
        super.init()
        addChildBehavior(collider)
        addChildBehavior(breakBehavior)
    }
    
    func addBarrier(path: UIBezierPath, named name: String) {
        collider.removeBoundaryWithIdentifier(name)
        collider.addBoundaryWithIdentifier(name, forPath: path)
    }
    
    func addBall(ball: UIView) {
        dynamicAnimator?.referenceView?.addSubview(ball)
        collider.addItem(ball)
        breakBehavior.addItem(ball)
    }
}
