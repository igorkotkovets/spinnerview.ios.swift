//
//  SpinnerView.swift
//  SpinnerView
//
//  Created by Igor Kotkovets on 4/15/20.
//

import Foundation
import UIKit
import os.log

@IBDesignable public class SpinnerView: UIView {

    @IBInspectable dynamic public var lineColor: UIColor = UIColor.red {
        didSet {
            animatingLayer.strokeColor = lineColor.cgColor
        }
    }

    @IBInspectable public var lineWidth: CGFloat = 4 {
        didSet {
            updateLayerPosition()
        }
    }
    @IBInspectable public var animationDuration: CFTimeInterval = 4
    @IBInspectable public var isAnimating: Bool = true {
        didSet {
            if isAnimating {
                startAnimation()
            }
            else {
                stopAnimation()
            }
        }
    }
    let animatingLayer = CAShapeLayer()
    var angleRad: CGFloat = (330*2*CGFloat.pi/360)
    var angleDegree: CGFloat = 330 {
        didSet {
            angleRad = 2*CGFloat.pi*angleDegree/360
            updateLayerPosition()
        }
    }
    var outLog = OSLog(subsystem: "SpinnerView", category: String(describing: self))

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public class var layerClass: AnyClass {
        return CAShapeLayer.self
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        updateLayerPosition()
    }

    public override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        updateLayerPosition()
    }

    override public func prepareForInterfaceBuilder() {
        animatingLayer.path = UIBezierPath(ovalIn: circleFrame).cgPath
    }

    var circleFrame: CGRect {
        return bounds.insetBy(dx: lineWidth/2, dy: lineWidth/2)
    }

    func updateLayerPosition() {
        animatingLayer.frame = bounds
        let radius = (bounds.size.width-lineWidth)/2
        let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let path = UIBezierPath(arcCenter: center,
                                radius: radius,
                                startAngle: 0,
                                endAngle: angleRad,
                                clockwise: true)
        animatingLayer.path = path.cgPath
    }

    func updateAnimationState() {
        if isAnimating {
            startAnimation()
        }
    }

    let STROKE_ANIMATION_KEY = "animatingStrokeStart"
    let ROTATION_ANIMATION_KEY = "animatingRotate"

    func startAnimation() {
        prepareLayerForAnimation()

        if  animatingLayer.animation(forKey: STROKE_ANIMATION_KEY) == nil {
            forwardAnimation()
        }

        if animatingLayer.animation(forKey: ROTATION_ANIMATION_KEY) == nil {
            rotateAnimation()
        }
    }

    private func prepareLayerForAnimation() {
        animatingLayer.fillColor = UIColor.clear.cgColor
        animatingLayer.strokeStart = 0
        animatingLayer.strokeColor = lineColor.cgColor
        animatingLayer.lineWidth = lineWidth
        layer.addSublayer(animatingLayer)
    }

    func forwardAnimation() {
        CATransaction.begin()
        let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        strokeEnd.fromValue = 0
        strokeEnd.toValue = 1
        strokeEnd.duration = animationDuration/2
        strokeEnd.fillMode = .forwards
        strokeEnd.isRemovedOnCompletion = false
        strokeEnd.timingFunction = CAMediaTimingFunction(name: .linear)
        CATransaction.setCompletionBlock{ [weak self] in
            self?.reverseAnimation()
        }
        animatingLayer.add(strokeEnd, forKey: STROKE_ANIMATION_KEY)
        CATransaction.commit()
    }

    fileprivate func rotateAnimation() {
        let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
        rotate.fromValue = 0
        rotate.toValue = 2*CGFloat.pi
        rotate.repeatCount = MAXFLOAT
        rotate.autoreverses = false
        rotate.duration = animationDuration/4
        animatingLayer.add(rotate, forKey: ROTATION_ANIMATION_KEY)
    }

    func reverseAnimation() {
        CATransaction.begin()
        let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        strokeEnd.fromValue = animatingLayer.presentation()?.strokeEnd
        strokeEnd.toValue = 0
        strokeEnd.duration = animationDuration/2
        strokeEnd.fillMode = .forwards
        strokeEnd.isRemovedOnCompletion = false
        strokeEnd.timingFunction = CAMediaTimingFunction(name: .easeIn)
        CATransaction.setCompletionBlock{ [weak self] in
            self?.forwardAnimation()
        }
        animatingLayer.add(strokeEnd, forKey: STROKE_ANIMATION_KEY)
        CATransaction.commit()
    }

    func stopAnimation() {
        animatingLayer.removeAnimation(forKey: ROTATION_ANIMATION_KEY)
        animatingLayer.removeAnimation(forKey: STROKE_ANIMATION_KEY)
        animatingLayer.removeFromSuperlayer()
    }
}
