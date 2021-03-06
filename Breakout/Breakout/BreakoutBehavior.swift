//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by Adela  Yang on 4/7/16.
//  Copyright © 2016 Adela  Yang. All rights reserved.
//

import UIKit

class BreakoutBehavior: UIDynamicBehavior {
    
    lazy var collider : UICollisionBehavior = {
        let lazyCollision = UICollisionBehavior()
        //checks if the ball intersects the game view, if not remove
        lazyCollision.action = {
            for ball in self.balls {
                if !CGRectIntersectsRect(self.dynamicAnimator!.referenceView!.bounds, ball.frame) {
                    self.removeBall(ball)
                }
            }
        }
        return lazyCollision
    }()

    override init() {
        super.init()
        addChildBehavior(collider)
        addChildBehavior(ballBehavior)
    }

    lazy var ballBehavior: UIDynamicItemBehavior = {
        let lazyBall = UIDynamicItemBehavior()
        lazyBall.allowsRotation = false
        lazyBall.elasticity = 1.0
        lazyBall.friction = 0.0
        lazyBall.resistance = 0.0
        return lazyBall
    }()

    func addBall(ball: UIView) {
        dynamicAnimator?.referenceView?.addSubview(ball)
        collider.addItem(ball)
        ballBehavior.addItem(ball)
    }
    
    func removeBall(ball: UIView) {
        collider.removeItem(ball)
        ballBehavior.removeItem(ball)
        ball.removeFromSuperview()
    }

    // check if there is a ball, check items in the collider behavior and map it to an array
    var balls:[UIView] {
        get {
            return collider.items.filter{$0 is UIView}.map{$0 as! UIView}
        }
    }
    
    // move the ball at a random angle, remove behavior aspa
    func moveBall(ball: UIView) {
        let pushBehavior = UIPushBehavior(items: [ball], mode: .Instantaneous)
        pushBehavior.magnitude = 1.0
        
        pushBehavior.angle = CGFloat(Double(arc4random()) * M_PI * 2 / Double(UINT32_MAX))
        pushBehavior.action = { [weak pushBehavior] in
            if !pushBehavior!.active {
                self.removeChildBehavior(pushBehavior!)
            }
        }
        addChildBehavior(pushBehavior)
    }
    
    // remove previous barrier, in case of rotation
    func addBarrier(path: UIBezierPath, named name: NSCopying) {
        collider.removeBoundaryWithIdentifier(name)
        collider.addBoundaryWithIdentifier(name, forPath: path)
    }
    
    var collisionDelegate: UICollisionBehaviorDelegate? {
        get { return collider.collisionDelegate }
        set { collider.collisionDelegate = newValue }
    }
    
    func removeBarrier(name: NSCopying) {
        collider.removeBoundaryWithIdentifier(name)
    }
    
}
