//
//  BreakoutViewController.swift
//  Breakout
//
//  Created by Adela  Yang on 4/7/16.
//  Copyright © 2016 Adela  Yang. All rights reserved.
//

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
        
        
        //use attachments?
        gameView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "panPaddle:"))
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "swipePaddleLeft:")
        swipeLeft.direction = .Left
        gameView.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "swipePaddleRight:")
        swipeRight.direction = .Right
        gameView.addGestureRecognizer(swipeRight)
        
        start()

    }
    
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
        
        static let Attachment    = "Attachment"
        
        
        static let PaddleLength = CGSize(width: 240.0, height: 20.0)
        static let PaddleCornerRadius: CGFloat = 5.0
        static let PaddleColor = UIColor.redColor()
        
        static let BrickColumns = 5
        static let BrickRows = 4
        static let BrickTotalWidth: CGFloat = 1.0
        static let BrickTotalHeight: CGFloat = 0.3
        static let BrickTopSpacing: CGFloat = 0.05
        static let BrickSpacing: CGFloat = 5.0
        static let BrickCornerRadius: CGFloat = 2.5
//        static let BrickColors = [UIColor.greenColor(), UIColor.blueColor(), UIColor.redColor(), UIColor.yellowColor()]
        static let BrickColor = UIColor.whiteColor()
        
    }
    
    //MARK: BALL
    
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
    
    func initBall(ball: UIView) {
        var center = paddle.center
        center.y -= Constants.PaddleLength.height / 2 + Constants.BallDiameter
        ball.center = center
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var rect = gameView.bounds
        rect.size.height *= 2
        breakout.addBarrier(UIBezierPath(rect: rect), named: Constants.BorderBarrier)
        
        initBricks()
        
        resetPaddle()
        
        for ball in breakout.balls {
            if !CGRectContainsRect(gameView.bounds, ball.frame) {
                initBall(ball)
                animator.updateItemUsingCurrentState(ball)
            }
        }
        
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
    
    func swipePaddleLeft(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended:
            initPaddle(CGPoint(x: -gameView.bounds.maxX, y: 0.0))
        default: break
        }
    }
    
    func swipePaddleRight(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended:
            initPaddle(CGPoint(x: gameView.bounds.maxX, y: 0.0))
        default: break
        }
    }
    
    func initPaddle(translation: CGPoint) {
        var origin = paddle.frame.origin
        origin.x = max(min(origin.x + translation.x, gameView.bounds.maxX - Constants.PaddleLength.width), 0.0)
        paddle.frame.origin = origin
        addPaddleBarrier()
    }
    
    func addPaddleBarrier() {
        breakout.addBarrier(UIBezierPath(roundedRect: paddle.frame, cornerRadius: Constants.PaddleCornerRadius), named: Constants.PaddleBarrier)
    }
    
    var attachment: UIAttachmentBehavior? {
        willSet {
            if attachment != nil {
                animator.removeBehavior(attachment!)
                gameView.setPaths(nil, named: Constants.Attachment)
            }
        }
        
        didSet {
            if attachment != nil {
                animator.addBehavior(attachment!)
                attachment?.action = { [unowned self] in
                    if let attachedView = self.attachment?.items.first as? UIView {
                        let path = UIBezierPath()
                        path.moveToPoint(self.attachment!.anchorPoint)
                        path.addLineToPoint(attachedView.center)
                        self.gameView.setPaths(path, named: Constants.Attachment)
                    }
                }
            }
        }
    }
    
    //MARK: BRICKS

    var bricks = [Int:Brick]()
    
    struct Brick {
        var relativeFrame: CGRect
        var view: UIView
    }
    
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
                            self.breakout.removeBrick(brick.view)
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
    

    
    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        animator.addBehavior(breakout)
    
        //        gameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "pushBall:"))
        //        gameView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "panPaddle:"))
        //        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "swipePaddleLeft:")
        //        swipeLeft.direction = .Left
        //        gameView.addGestureRecognizer(swipeLeft)
        //        let swipeRight = UISwipeGestureRecognizer(target: self, action: "swipePaddleRight:")
        //        swipeRight.direction = .Right
        //        gameView.addGestureRecognizer(swipeRight)
        //
        //        breakout.collisionDelegate = self
        //        levelOne()
        
//    }

    
    

//    struct Constants {
//        //ball properties
//        static let BallRadius: CGFloat = 10.0
//        static let BallColor = UIColor.redColor()
//        
//        //paddle properties
//        static let PaddleSize = CGSize(width: 80.0, height: 20.0)
//        static let PaddleColor = UIColor.cyanColor()
//        
//        //brick properties
//        static let BrickColumns = 4
//        static let BrickRows = 4
//        static let BrickTotalWidth: CGFloat = 1.0
//        static let BrickTotalHeight: CGFloat = 0.3
//        static let BrickTopSpacing: CGFloat = 0.05
//        static let BrickSpacing: CGFloat = 5.0
//        static let BrickColor = [UIColor.blackColor()]
//        
//        //path names
//        static let BoxPathName = "Box"
//        static let PaddlePathName = "Paddle"
//    }
//    
//    
//    private lazy var paddle: UIView = {
//        let paddle = UIView(frame: CGRect(origin: CGPoint(x: -1, y: -1), size: Constants.PaddleSize))
//        paddle.backgroundColor = Constants.PaddleColor
//        self.gameView.addSubview(paddle)
//        
//        return paddle
//    }()
//    
//    private var bricks = [Int:Brick]()
//    
//    private struct Brick {
//        var relativeFrame: CGRect
//        var view: UIView
//        var action: BrickAction
//    }
//    
//    private typealias BrickAction = ((Int) -> Void)?
//    
//    private var autoStartTimer: NSTimer?
//
//    private func levelOne() {
//        if bricks.count > 0 { return }
//        
//        let deltaX = Constants.BrickTotalWidth / CGFloat(Constants.BrickRows)
//        let deltaY = Constants.BrickTotalHeight / CGFloat(Constants.BrickColumns)
//        var frame = CGRect(origin: CGPointZero, size: CGSize(width: deltaX, height: deltaY))
//        
//        for row in 0..<Constants.BrickRows {
//            for column in 0..<Constants.BrickColumns {
//                frame.origin.x = deltaX * CGFloat(column)
//                frame.origin.y = deltaY * CGFloat(row) + Constants.BrickTopSpacing
//                let brick = UIView(frame: frame)
//                brick.backgroundColor = Constants.BrickColor[row % Constants.BrickColor.count]
//                brick.layer.borderColor = UIColor.blackColor().CGColor
//                brick.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
//                brick.layer.shadowOpacity = 0.1
//                
//                gameView.addSubview(brick)
//                
//                var action: BrickAction = nil
//                
//                if row + 1 == Constants.BrickRows {
//                    brick.backgroundColor = UIColor.blackColor()
//                    action = { index in
//                        if brick.backgroundColor != UIColor.blackColor() {
//                            self.destroyBrickAtIndex(index)
//                        } else {
//                            NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "changeBrickColor:", userInfo: brick, repeats: false)
//                        }
//                    }
//                }
//                
//                bricks[row * Constants.BrickColumns + column] = Brick(relativeFrame: frame, view: brick, action: action)
//            }
//        }
//    }
//
//    func changeBrickColor(timer: NSTimer) {
//        if let brick = timer.userInfo as? UIView {
//            UIView.animateWithDuration(0.5, animations: { () -> Void in
//                brick.backgroundColor = UIColor.cyanColor()
//                }, completion: nil)
//        }
//    }
//    
//    private func levelFinished() {
//        autoStartTimer?.invalidate()
//        autoStartTimer = nil
//        for ball in breakout.balls {
//            breakout.removeBall(ball)
//            print("removed ball")
//        }
//        
////        if NSClassFromString("UIAlertController") != nil {
////            if #available(iOS 8.0, *) {
////                let alertController = UIAlertController(title: "Game Over", message: "", preferredStyle: .Alert)
////                alertController.addAction(UIAlertAction(title: "Play Again", style: .Default, handler: { (action) in
////                    self.levelOne()
////                    self.setAutoStartTimer()
////                }))
////                presentViewController(alertController, animated: true, completion: nil)
////            } else {
////                let alertView = UIAlertView(title: "Game Over", message: "asdf", delegate: self, cancelButtonTitle: "Play Again")
////                alertView.show()
////            }
////        }
//    }
////
////    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
////        levelOne()
////        setAutoStartTimer()
////        placeBricks()
////    }
//    
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
//        var rect = gameView.bounds
//        rect.size.height *= 2
//        breakout.addBarrier(UIBezierPath(rect: rect), named: Constants.BoxPathName)
//        
//        placeBricks()
//        
//        resetPaddle()
//        
//        for ball in breakout.balls {
//            if !CGRectContainsRect(gameView.bounds, ball.frame) {
//                placeBall(ball)
//                animator.updateItemUsingCurrentState(ball)
//            }
//        }
//
//    }
//    
//    func autoStart(timer: NSTimer) {
//        if breakout.balls.count < 1 {
//            let ball = createBall()
//            placeBall(ball)
//            breakout.addBall(ball)
//            breakout.pushBall(breakout.balls.last!)
//        }
//    }
//
//
//    
//    
//    // MARK: - ball
//    
//    private func placeBall(ball: UIView) {
//        var center = paddle.center
//        center.y -= Constants.PaddleSize.height / 2 + Constants.BallRadius
//        ball.center = center
//    }
//    
//    private func createBall() -> UIView {
//        let ball = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: Constants.BallRadius * 2.0, height: Constants.BallRadius * 2.0)))
//        ball.backgroundColor = Constants.BallColor
//        ball.layer.cornerRadius = Constants.BallRadius
//        ball.layer.borderColor = UIColor.blackColor().CGColor
//        ball.layer.borderWidth = 2.0
//        ball.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
//        ball.layer.shadowOpacity = 0.5
//        return ball
//    }
//    
//    func pushBall(gesture: UITapGestureRecognizer) {
//        if gesture.state == .Ended {
//            if breakout.balls.count < 1 {
//                let ball = createBall()
//                placeBall(ball)
//                breakout.addBall(ball)
//            }
//            breakout.pushBall(breakout.balls.last!)
//        }
//    }
//    
//    // MARK: - paddle
//    
//    private func resetPaddle() {
//        if !CGRectContainsRect(gameView.bounds, paddle.frame) {
//            paddle.center = CGPoint(x: gameView.bounds.midX, y: gameView.bounds.maxY - paddle.bounds.height)
//        } else {
//            paddle.center = CGPoint(x: paddle.center.x, y: gameView.bounds.maxY - paddle.bounds.height)
//        }
//        addPaddleBarrier()
//    }
//    
//    private func placePaddle(translation: CGPoint) {
//        var origin = paddle.frame.origin
//        origin.x = max(min(origin.x + translation.x, gameView.bounds.maxX - Constants.PaddleSize.width), 0.0)
//        paddle.frame.origin = origin
//        addPaddleBarrier()
//    }
//    
//    private func addPaddleBarrier() {
//        breakout.addBarrier(UIBezierPath(roundedRect: paddle.frame, cornerRadius: Constants.PaddleCornerRadius), named: Constants.PaddlePathName)
//    }
//    
//    func panPaddle(gesture: UIPanGestureRecognizer) {
//        switch gesture.state {
//        case .Ended: fallthrough
//        case .Changed:
//            placePaddle(gesture.translationInView(gameView))
//            gesture.setTranslation(CGPointZero, inView: gameView)
//        default: break
//        }
//    }
//    
//    func swipePaddleLeft(gesture: UIPanGestureRecognizer) {
//        switch gesture.state {
//        case .Ended:
//            placePaddle(CGPoint(x: -gameView.bounds.maxX, y: 0.0))
//        default: break
//        }
//    }
//    
//    func swipePaddleRight(gesture: UIPanGestureRecognizer) {
//        switch gesture.state {
//        case .Ended:
//            placePaddle(CGPoint(x: gameView.bounds.maxX, y: 0.0))
//        default: break
//        }
//    }
//    
//    // MARK: - bricks
//    
//    private func placeBricks() {
//        for (index, brick) in bricks {
//            brick.view.frame.origin.x = brick.relativeFrame.origin.x * gameView.bounds.width
//            brick.view.frame.origin.y = brick.relativeFrame.origin.y * gameView.bounds.height
//            brick.view.frame.size.width = brick.relativeFrame.width * gameView.bounds.width
//            brick.view.frame.size.height = brick.relativeFrame.height * gameView.bounds.height
//            brick.view.frame = CGRectInset(brick.view.frame, Constants.BrickSpacing, Constants.BrickSpacing)
//            breakout.addBarrier(UIBezierPath(roundedRect: brick.view.frame), named: index)
//        }
//    }
//    
//    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
//        if let index = identifier as? Int {
//            if let action = bricks[index]?.action {
//                action(index)
//            } else {
//                destroyBrickAtIndex(index)
//            }
//        }
//    }
//    
//    private func destroyBrickAtIndex(index: Int) {
//        breakout.removeBarrier(index)
//        if let brick = bricks[index] {
//            UIView.transitionWithView(brick.view, duration: 0.2, options: .TransitionFlipFromBottom, animations: {
//                brick.view.alpha = 0.5
//                }, completion: { (success) -> Void in
//                    self.breakout.addBrick(brick.view)
//                    UIView.animateWithDuration(1.0, animations: {
//                        brick.view.alpha = 0.0
//                        }, completion: { (success) -> Void in
//                            self.breakout.removeBrick(brick.view)
//                            brick.view.removeFromSuperview()
//                    })
//            })
//            bricks.removeValueForKey(index)
//            print("\(self.bricks.count)")
//            if self.bricks.count == 0 {
//                print("\(self.bricks.count)")
//                self.levelFinished()
//            }
//        }
//    }

    

}

