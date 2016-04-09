//
//  BreakoutViewController.swift
//  Breakout
//
//  Created by Adela  Yang on 4/7/16.
//  Copyright © 2016 Adela  Yang. All rights reserved.
//

import UIKit

class BreakoutViewController: UIViewController, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate{
    
    @IBOutlet weak var gameView: BreakoutView!
    
    @IBAction func paddle(sender: UIPanGestureRecognizer) {
    }
    
    @IBAction func ball(sender: UITapGestureRecognizer) {
        start()
    }
    
    
    struct PathNames {
        static let PaddleBarrier = "Paddle Barrier"
        static let TargetBarrier = "Target Barrier"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let barrierSize = targetSize
        let barrierOrigin = CGPoint(x: gameView.bounds.midX-barrierSize.width/2, y:
            gameView.bounds.midY-barrierSize.height/2)
        let path = UIBezierPath(ovalInRect: CGRect(origin: barrierOrigin, size: barrierSize))
        breakBehavior.addBarrier(path, named: PathNames.PaddleBarrier)
    }
    
    
    // Mark: Targets
    
    var targetsPerRow = 5
    var targetsPerColumn = 10
    
    let breakBehavior = BreakoutBehavior()
    
//    var lastBreakView = UIView?()
//
    lazy var animator : UIDynamicAnimator = {
        let lazyAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazyAnimator.delegate = self
        return lazyAnimator
    }()
    
    var targetSize:CGSize {
        let size = gameView.bounds.size.width / CGFloat(targetsPerRow)
        return CGSize(width: size, height: size)
    }
    
    func start() {
        var frame = CGRect(origin: CGPointZero, size: targetSize)
        frame.origin.x = CGFloat.random(targetsPerRow) * targetSize.width
        let breakView = UIView(frame:frame)
        breakView.backgroundColor = UIColor.blackColor()
        breakBehavior.addBall(breakView)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        animator.addBehavior(breakBehavior)
        // Do any additional setup after loading the view.
    }

}

private extension CGFloat {
    static func random(max: Int) -> CGFloat {
        return CGFloat(arc4random() % UInt32(max))
    }
}


/*
class DropItViewController: UIViewController, UIDynamicAnimatorDelegate{
    
    var dropsPerRow = 10
    let dropItBehavior = DropItBehavior()
    var lastDroppedView = UIView?()
    
    struct Pathnames {
        static let MiddleBarrier = "MiddleBarrier"
    }
    
    lazy var animator : UIDynamicAnimator = {
        let lazyAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazyAnimator.delegate = self
        return lazyAnimator
    }()
    
    var attachment: UIAttachmentBehavior?
    
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        removeCompleteRow()
    }
    
    var dropSize:CGSize {
        let size = gameView.bounds.size.width / CGFloat(dropsPerRow)
        return CGSize(width: size, height: size)
    }
    
    @IBOutlet weak var gameView: BezierPathsView!
    
    @IBAction func drop(sender: UITapGestureRecognizer) {
        drop()
    }
    
    @IBAction func grabDrop(sender: UIPanGestureRecognizer) {
        
    }
    
    
    func drop() {
        var frame = CGRect(origin: CGPointZero, size: dropSize)
        frame.origin.x = CGFloat.random(dropsPerRow) * dropSize.width
        let dropView = UIView(frame: frame)
        dropView.backgroundColor = UIColor.random
        gameView.addSubview(dropView)
        dropItBehavior.addDrop(dropView)
        lastDroppedView = dropView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.addBehavior(dropItBehavior)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let barrierSize = dropSize
        let barrierOrigin = CGPoint(x: gameView.bounds.midX-barrierSize.width/2, y: gameView.bounds.midY-barrierSize.height/2)
        let path = UIBezierPath(ovalInRect: CGRect(origin: barrierOrigin, size: barrierSize))
        dropItBehavior.addBarrier(path, named: Pathnames.MiddleBarrier)
        gameView.setPaths(path, named: Pathnames.MiddleBarrier)
    }
    
    func removeCompleteRow() {
        var dropsToRemove = [UIView]()
        var dropFrame = CGRect(x: 0, y: gameView.frame.maxY, width: dropSize.width, height: dropSize.height)
        
        repeat{
            dropFrame.origin.y -= dropSize.height
            dropFrame.origin.x = 0
            var dropsFound = [UIView]()
            var rowIsComplete = true
            
            for _ in 0..<dropsPerRow {
                if let hitView = gameView.hitTest(CGPoint(x: dropFrame.midX, y: dropFrame.midY), withEvent: nil) {
                    if hitView.superview == gameView {
                        dropsFound.append(hitView)
                    }
                    else {
                        rowIsComplete = false
                    }
                }
                
                dropFrame.origin.x += dropSize.width
            }
            
            if rowIsComplete {
                dropsToRemove += dropsFound
            }
        } while dropsToRemove.count == 0 && dropFrame.origin.y > 0
        
        for drop in dropsToRemove {
            dropItBehavior.removeDrop(drop)
        }
    }
    
}

private extension CGFloat {
    static func random(max: Int) -> CGFloat {
        return CGFloat(arc4random() % UInt32(max))
    }
}



private extension UIColor {
    class var random: UIColor {
        switch  arc4random() % 5{
        case 0: return UIColor.greenColor()
        case 1: return UIColor.blueColor()
        case 2: return UIColor.orangeColor()
        case 3: return UIColor.redColor()
        case 4: return UIColor.purpleColor()
        default: return UIColor.blackColor()
        }
    }
}
*/