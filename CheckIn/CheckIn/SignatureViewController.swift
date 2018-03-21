//
//  SignatureViewController.swift
//  CheckIn
//
//  Created by Anand Kelkar on 20/03/18.
//  Copyright © 2018 Sam Walk. All rights reserved.
//

import Foundation
import UIKit

class SignatureViewController: UIViewController
{
    @IBOutlet weak var mainView: UIView!
    
    var lastPoint:CGPoint?
    var swipped = false
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("began")
        swipped=false
        if let touch = touches.first {
            lastPoint = touch.location(in: mainView)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("moving")
        swipped=true
        if let touch = touches.first {
            let currentPoint = touch.location(in: mainView)
            drawLine(lastPoint: lastPoint!, currentPoint: currentPoint)
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("ended")
        if(!swipped)
        {
            print("printing dot")
            drawPoint(point: lastPoint!)
//            drawLine(lastPoint: lastPoint!, currentPoint: CGPoint(x:(lastPoint?.x)!,y:(lastPoint?.y)!+0.5))
        }
    }
    
    func drawLine(lastPoint:CGPoint,currentPoint:CGPoint)
    {
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        linePath.move(to: lastPoint)
        linePath.addLine(to: currentPoint)
        line.path = linePath.cgPath
        line.strokeColor = UIColor.black.cgColor
        line.lineWidth = 1
        line.lineJoin = kCALineJoinRound
        mainView.layer.addSublayer(line)
    }
    
    func drawPoint(point:CGPoint)
    {
        let layer = CAShapeLayer()
        let dotPath = UIBezierPath(ovalIn: CGRect(x:point.x, y:point.y, width:1, height:1))
        layer.path = dotPath.cgPath
        layer.strokeColor = UIColor.black.cgColor
        layer.lineJoin = kCALineJoinRound
        mainView.layer.addSublayer(layer)
    }
    
    
    
}
