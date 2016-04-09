//
//  BreakoutView.swift
//  Breakout
//
//  Created by Adela  Yang on 4/7/16.
//  Copyright © 2016 Adela  Yang. All rights reserved.
//

import UIKit

class BreakoutView: UIView {
     let space: CGFloat = 2.0
    
    private var bezierPaths = [String: UIBezierPath]()
    
    func setPaths(path: UIBezierPath?, named name: String) {
        bezierPaths[name] = path
        setNeedsDisplay() // calls drawRect
    }

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        for (_, path) in bezierPaths {
            path.stroke()
        }

    }


}
