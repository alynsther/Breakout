//
//  BreakoutViewController.swift
//  Breakout
//
//  Created by Adela  Yang on 4/7/16.
//  Copyright © 2016 Adela  Yang. All rights reserved.
//

// Receieved code help from http://cs193p.m2m.at/cs193p-project-5-assignment-5-step-1-the-ball-winter-2015/

import UIKit

class BreakoutViewController: UIViewController, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate, UIAlertViewDelegate{
    
    @IBOutlet weak var gameView: BreakoutView!
    
    let breakout = BreakoutBehavior()
    
    lazy var animator : UIDynamicAnimator = {
        let lazyAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazyAnimator.delegate = self
        return lazyAnimator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        breakout.collisionDelegate = self
        
        animator.addBehavior(breakout)
        gameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "moveBall:"))
        
        gameView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "panPaddle:"))
        
        start()

    }
    
    // if there is not ball, initialize one and move it
    func moveBall(gesture: UITapGestureRecognizer) {
        if gesture.state == .Ended {
            if breakout.balls.count == 0 {
                let ball = makeBall()
                initBall(ball)
                breakout.addBall(ball)
            }
            breakout.moveBall(breakout.balls.last!)
        }
    }
    
    struct Constants {
        static let BallDiameter: CGFloat = 40.0
        static let BallColor = UIColor.cyanColor()
        
        static let BorderBarrier = "Border"
        static let PaddleBarrier = "Paddle"
        
        static let PaddleLength = CGSize(width: 240.0, height: 20.0)
        static let PaddleCornerRadius: CGFloat = 5.0
        static let PaddleColor = UIColor.redColor()
        
        static let BrickColumns = 2
        static let BrickRows = 2
        static let BrickTotalWidth: CGFloat = 1.0
        static let BrickTotalHeight: CGFloat = 0.3
        static let BrickTopSpacing: CGFloat = 0.05
        static let BrickSpacing: CGFloat = 5.0
        static let BrickCornerRadius: CGFloat = 2.5
//        static let BrickColors = [UIColor.greenColor(), UIColor.blueColor(), UIColor.redColor(), UIColor.yellowColor()]
        static let BrickColor = UIColor.whiteColor()
        
    }
    
    //MARK: BALL
    
    // balls is a view with round corners
    func makeBall() -> UIView {
        let ball = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: Constants.BallDiameter, height: Constants.BallDiameter)))
        ball.backgroundColor = Constants.BallColor
        ball.layer.cornerRadius = Constants.BallDiameter / 2.0
        ball.layer.borderColor = UIColor.blackColor().CGColor
        ball.layer.borderWidth = 2.0
        ball.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        ball.layer.shadowOpacity = 0.5
        return ball
    }
    
    // init ball in the center of the paddle
    func initBall(ball: UIView) {
        var center = paddle.center
        center.y -= Constants.PaddleLength.height / 2 + Constants.BallDiameter
        ball.center = center
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // barrier for top, left, and right of screen
        var rect = gameView.bounds
        rect.size.height *= 2
        breakout.addBarrier(UIBezierPath(rect: rect), named: Constants.BorderBarrier)
        
        initBricks()
        
        resetPaddle()
        
        // if rotated, place balls back on screen
        for ball in breakout.balls {
            if !CGRectContainsRect(gameView.bounds, ball.frame) {
                initBall(ball)
                animator.updateItemUsingCurrentState(ball)
            }
        }
        
        // if paddles is outside of the view, reposition it
        if !CGRectContainsRect(gameView.bounds, paddle.frame) {
            resetPaddle()
        }
        
    }
    
    //MARK: PADDLE
    
    lazy var paddle: UIView = {
        let paddle = UIView(frame: CGRect(origin: CGPoint(x: -1, y: -1), size: Constants.PaddleLength))
        paddle.backgroundColor = Constants.PaddleColor
        paddle.layer.cornerRadius = Constants.PaddleCornerRadius
        paddle.layer.borderColor = UIColor.redColor().CGColor
        paddle.layer.borderWidth = 2.0
        paddle.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        paddle.layer.shadowOpacity = 0.5
        
        self.gameView.addSubview(paddle)
        
        return paddle
    }()
    
    // paddles in the middle of bottom of screen
    private func resetPaddle() {
        if !CGRectContainsRect(gameView.bounds, paddle.frame) {
            paddle.center = CGPoint(x: gameView.bounds.midX, y: gameView.bounds.maxY - paddle.bounds.height)
        } else {
            paddle.center = CGPoint(x: paddle.center.x, y: gameView.bounds.maxY - paddle.bounds.height)
        }
        addPaddleBarrier()
    }
    
    func panPaddle(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            initPaddle(gesture.translationInView(gameView))
            gesture.setTranslation(CGPointZero, inView: gameView)
        default: break
        }
    }
    
    // change origin of the paddle, but keep it within limits
    func initPaddle(translation: CGPoint) {
        var origin = paddle.frame.origin
        origin.x = max(min(origin.x + translation.x, gameView.bounds.maxX - Constants.PaddleLength.width), 0.0)
        paddle.frame.origin = origin
        addPaddleBarrier()
    }
    
    // the barrier envelopes the dimensions of paddle
    func addPaddleBarrier() {
        breakout.addBarrier(UIBezierPath(roundedRect: paddle.frame, cornerRadius: Constants.PaddleCornerRadius), named: Constants.PaddleBarrier)
    }
    
    //MARK: BRICKS

    var bricks = [Int:Brick]()
    
    struct Brick {
        var relativeFrame: CGRect
        var view: UIView
    }
    
    // reintialize if game starts or rotated
    func initBricks() {
        for (index, brick) in bricks {
            brick.view.frame.origin.x = brick.relativeFrame.origin.x * gameView.bounds.width
            brick.view.frame.origin.y = brick.relativeFrame.origin.y * gameView.bounds.height
            brick.view.frame.size.width = brick.relativeFrame.width * gameView.bounds.width
            brick.view.frame.size.height = brick.relativeFrame.height * gameView.bounds.height
            brick.view.frame = CGRectInset(brick.view.frame, Constants.BrickSpacing, Constants.BrickSpacing)
            breakout.addBarrier(UIBezierPath(roundedRect: brick.view.frame, cornerRadius: Constants.BrickCornerRadius), named: index)
        }
    }
    
    
    func start() {
        if bricks.count > 0 { return }
        
        let deltaX = Constants.BrickTotalWidth / CGFloat(Constants.BrickColumns)
        let deltaY = Constants.BrickTotalHeight / CGFloat(Constants.BrickRows)
        var frame = CGRect(origin: CGPointZero, size: CGSize(width: deltaX, height: deltaY))
        
        for row in 0..<Constants.BrickRows {
            for column in 0..<Constants.BrickColumns {
                frame.origin.x = deltaX * CGFloat(column)
                frame.origin.y = deltaY * CGFloat(row) + Constants.BrickTopSpacing
                let brick = UIView(frame: frame)
//                brick.backgroundColor = Constants.BrickColors[row % Constants.BrickColors.count]
                brick.backgroundColor = Constants.BrickColor
                brick.layer.cornerRadius = Constants.BrickCornerRadius
                brick.layer.borderColor = UIColor.blackColor().CGColor
                brick.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
                brick.layer.shadowOpacity = 0.1
                
                gameView.addSubview(brick)
                
                bricks[row * Constants.BrickColumns + column] = Brick(relativeFrame: frame, view: brick)
            }
        }
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
        if let index = identifier as? Int {
            deleteBrick(index)
        }
    }
    
    // to remove a brick, get rid of the barrier
    private func deleteBrick(index: Int) {
        breakout.removeBarrier(index)
        if let brick = bricks[index] {
//            UIView.transitionWithView(brick.view, duration: 0.2, options: .TransitionFlipFromBottom, animations: {
//                brick.view.alpha = 0.5
//                }, completion: { (success) -> Void in
//                    self.breakout.addBrick(brick.view)
                    UIView.animateWithDuration(1.0, animations: {
                        brick.view.alpha = 0.0
                        }, completion: { (success) -> Void in
//                            self.breakout.removeBrick(brick.view)
                            brick.view.removeFromSuperview()
                            if self.bricks.count == 0 {
                                self.end()
                            }
                    })
//            })
            bricks.removeValueForKey(index)
        }
    }

    func end() {
        for ball in breakout.balls {
            breakout.removeBall(ball)
        }
        
        let alertController = UIAlertController(title: "It's Over", message: "", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Start Over", style: .Default, handler: { (action) in
            self.start()
        }))
        presentViewController(alertController, animated: true, completion: nil)
    }
}

