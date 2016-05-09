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
        addChildBehavior(gravity)
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

    var balls:[UIView] {
        get {
            return collider.items.filter{$0 is UIView}.map{$0 as! UIView}
        }
    }
    
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
    
    func addBrick(brick: UIView) {
        gravity.addItem(brick)
    }
    
    func removeBrick(brick: UIView) {
        gravity.removeItem(brick)
    }
    
    let gravity = UIGravityBehavior()
    

    
//    private let gravity = UIGravityBehavior()
//    
//    var collisionDelegate: UICollisionBehaviorDelegate? {
//        get { return collider.collisionDelegate }
//        set { collider.collisionDelegate = newValue }
//    }
    
    
    
//    private lazy var collider: UICollisionBehavior = {
//        let lazilyCreatedCollider = UICollisionBehavior()
//        lazilyCreatedCollider.action = {
//            for ball in self.balls {
//                if !CGRectIntersectsRect(self.dynamicAnimator!.referenceView!.bounds, ball.frame) {
//                    self.removeBall(ball)
//                }
//            }
//        }
//        return lazilyCreatedCollider
//    }()
    
//    private lazy var ballBehavior: UIDynamicItemBehavior = {
//        let lazilyCreatedBallBehavior = UIDynamicItemBehavior()
//        lazilyCreatedBallBehavior.allowsRotation = false
//        lazilyCreatedBallBehavior.elasticity = 1.0
//        lazilyCreatedBallBehavior.friction = 0.0
//        lazilyCreatedBallBehavior.resistance = 0.0
//        return lazilyCreatedBallBehavior
//    }()
//    
//    override init() {
//        super.init()
//        addChildBehavior(gravity)
//        addChildBehavior(collision)
//        addChildBehavior(ballBehavior)
//    }
//    
//    var balls:[UIView] {
//        get {
//            return collider.items.filter{$0 is UIView}.map{$0 as! UIView}
//        }
//    }
//    
//    var speed:CGFloat = 1.0
//    
//    func addBall(ball: UIView) {
//        dynamicAnimator?.referenceView?.addSubview(ball)
//        collider.addItem(ball)
//        ballBehavior.addItem(ball)
//    }
//    
//    func removeBall(ball: UIView) {
//        collider.removeItem(ball)
//        ballBehavior.removeItem(ball)
//        ball.removeFromSuperview()
//    }
//    
//    func pushBall(ball: UIView) {
//        let push = UIPushBehavior(items: [ball], mode: .Instantaneous)
//        push.magnitude = speed
//        
//        push.angle = CGFloat(Double(arc4random()) * M_PI * 2 / Double(UINT32_MAX))
//        push.action = { [weak push] in
//            if !push!.active {
//                self.removeChildBehavior(push!)
//            }
//        }
//        addChildBehavior(push)
//    }
//    
//    func addBarrier(path: UIBezierPath, named name: NSCopying) {
//        removeBarrier(name)
//        collider.addBoundaryWithIdentifier(name, forPath: path)
//    }
//    
//    func removeBarrier(name: NSCopying) {
//        collider.removeBoundaryWithIdentifier(name)
//    }
//    
//    func addBrick(brick: UIView) {
//        gravity.addItem(brick)
//    }
//    
//    func removeBrick(brick: UIView) {
//        gravity.removeItem(brick)
//    }
//
//
    
    
    
}
