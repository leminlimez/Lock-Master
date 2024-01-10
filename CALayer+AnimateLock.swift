// The MIT License
//
// Copyright (c) 2018 Dariusz Bukowski
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import UIKit
import QuartzCore

extension CALayer {
    open func animateLock(animType: AnimationType = AnimationType.shrink, duration: Double = 0.5,
        completion: (() -> ())? = nil) {
        guard let snapshot = self.snapshot() else {
            return
        }
        let initialSublayers = self.sublayers ?? []
        let snapshotLayer = CALayer()
        let maskLayer = CAShapeLayer()
        snapshotLayer.frame = UIScreen.main.bounds
        snapshotLayer.contents = snapshot
        snapshotLayer.shouldRasterize = true
        snapshotLayer.drawsAsynchronously = true
        self.addSublayer(snapshotLayer)

        // CG Animation Stuff
        if animType != .tv {
            let alphaAnimation = CABasicAnimation(keyPath: "opacity")
            alphaAnimation.fromValue = 1.0
            alphaAnimation.toValue = 0.0
            alphaAnimation.duration = duration + 0.05
            alphaAnimation.beginTime = 0
            alphaAnimation.fillMode = CAMediaTimingFillMode.backwards
            alphaAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
            snapshotLayer.opacity = 0.0
            snapshotLayer.add(alphaAnimation, forKey: nil)
        }

        // Determine which animation to play
        switch (animType) {
        case .shrink, .expand:
            // Shrink or Expand to Center
            let targetScale: CGFloat = animType == .expand ? 5.0 : 0.0
            snapshotLayer.setValue(targetScale, forKeyPath: "transform.scale")
            snapshotLayer.add(createFloatAnim(toValue: targetScale, duration: duration), forKey: nil)
        case .slideLeft, .slideRight, .slideUp, .slideDown:
            // Slide to a side
            let targetPosX: CGFloat = self.bounds.width * (animType == .slideLeft ? -1 : (animType == .slideRight ? 1 : 0.5))
            let targetPosY: CGFloat = self.bounds.height * (animType == .slideUp ? -1 : (animType == .slideDown ? 1 : 0.5))
            let targetPos: CGPoint = CGPoint(x: targetPosX, y: targetPosY)
            snapshotLayer.add(
                createPointAnim(fromValue: snapshotLayer.position, toValue: targetPos, duration: duration),
                forKey: nil
            )
        case .tv:
            // TV Off
            let scaleAnims = CAAnimationGroup()
            // Width Animation
            let targetScaleWidth: CGFloat = 3/snapshotLayer.bounds.size.width
            snapshotLayer.setValue(targetScaleWidth, forKeyPath: "transform.scale.x")
            
            // Height Animation
            let targetScaleHeight: CGFloat = 3/snapshotLayer.bounds.size.height
            snapshotLayer.setValue(targetScaleHeight, forKeyPath: "transform.scale.y")

            scaleAnims.animations = [
                createFloatAnim(
                    fromValue: 1.0, toValue: targetScaleHeight,
                    beginTime: 0, duration: duration * 0.2,
                    keyPath: "transform.scale.y", easingType: .easeIn
                ),
                createFloatAnim(
                    fromValue: 1.0, toValue: targetScaleWidth,
                    beginTime: duration * 0.25, duration: duration * 0.25,
                    keyPath: "transform.scale.x", easingType: .easeOut
                )
            ]
            scaleAnims.duration = duration * 0.5
            snapshotLayer.add(scaleAnims, forKey: nil)

            // Background Color Animation
            // doesn't work yet
            /*let bgAnim = CABasicAnimation(keyPath: "backgroundColor")
            bgAnim.fromValue = UIColor.white.withAlphaComponent(0.0).cgColor
            bgAnim.toValue = UIColor.white.withAlphaComponent(1.0).cgColor
            bgAnim.duration = duration * 0.9
            bgAnim.beginTime = duration * 0.1
            bgAnim.fillMode = CAMediaTimingFillMode.backwards
            bgAnim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
            snapshotLayer.backgroundColor = UIColor.white.withAlphaComponent(1.0).cgColor
            snapshotLayer.add(bgAnim, forKey: nil)*/
        case .offBtnFadeInto:
            // Fade Into Off Button
            // Mask
            maskLayer.frame = snapshotLayer.frame
            let rectPath = makeRectanglePath(width: snapshotLayer.bounds.size.width, height: snapshotLayer.bounds.size.height)
            maskLayer.path = rectPath.cgPath
            snapshotLayer.mask = maskLayer

            maskLayer.setValue(0.0, forKeyPath: "transform.scale")

            // Path Animation
            let offBtnPos = CGPoint(x: snapshotLayer.bounds.size.width * 0.5, y: -snapshotLayer.bounds.size.height * 0.35)
            let pathAnim = CABasicAnimation(keyPath: "path")
            pathAnim.fromValue = rectPath.cgPath
            pathAnim.toValue = makeCirclePath(center: offBtnPos, radius: snapshotLayer.bounds.size.width).cgPath
            pathAnim.duration = duration * 0.6
            pathAnim.beginTime = 0.0

            let maskAnims = CAAnimationGroup()
            maskAnims.animations = [
                pathAnim
                /*createFloatAnim(
                    fromValue: 1.0, toValue: 0.0,
                    beginTime: duration * 0.1, duration: duration * 0.9,
                    easingType: .easeOut
                )*/
            ]
            maskAnims.duration = duration
            maskLayer.add(maskAnims, forKey: nil)
        case .offBtnFadeOut:
            // Fade From Off Button
            maskLayer.frame = CGRect(origin: CGPoint(x: snapshotLayer.bounds.size.width * 0.3, y: -snapshotLayer.bounds.size.height * 0.18), size: snapshotLayer.bounds.size)
            maskLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: snapshotLayer.bounds.size.height * 1.5, height: snapshotLayer.bounds.size.height * 1.5), cornerRadius: 800.0).cgPath
            maskLayer.backgroundColor = UIColor.black.cgColor
            maskLayer.setValue(1.0, forKeyPath: "transform.scale")
            snapshotLayer.addSublayer(maskLayer)

            maskLayer.add(
                createFloatAnim(
                    fromValue: 0.0, toValue: 1.0,
                    beginTime: 0, duration: duration * 0.5,
                    easingType: .easeIn
                ), forKey: nil
            )
        case .genie:
            // Genie Suck Effect (into off button)
            // 3D Transformation
            snapshotLayer.transform = CATransform3DMakeRotation(CGFloat.pi / 2, 1, 0, 0)
            snapshotLayer.add(
                createFloatAnim(
                    fromValue: 0.0, toValue: (.pi * 0.5),
                    beginTime: 0.0, duration: duration * 0.5,
                    keyPath: "transform.rotation.y", easingType: .easeOut
                ), forKey: nil
            )
            /*let warpAnim = CABasicAnimation(keyPath: "rotation.y")
            warpAnim.fromValue = 0.0
            warpAnim.toValue = [60.0 * .pi / 180.0, 0.0, 1.0, 0.0]
            warpAnim.duration = duration
            warpAnim.beginTime = 0.0
            warpAnim.fillMode = CAMediaTimingFillMode.backwards
            warpAnim.timingFunction = CAMediaTimingFunction(name: .easeOut)
            // Animation Group
            let animGroup = CAAnimationGroup()
            animGroup.animations = [
                createFloatAnim(
                    fromValue: 1.0, toValue: 0.0,
                    beginTime: duration * 0.1, duration: duration * 0.9,
                    easingType: .easeOut
                )
            ]
            snapshotLayer.add(warpAnim, forKey: nil)*/
        }

        // finish the animation
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration + 0.1) {
            snapshotLayer.removeFromSuperlayer()
            maskLayer.removeFromSuperlayer()
            completion?()
        }

        initialSublayers.forEach { (layer) in
            layer.opacity = 0.0
        }

        self.contents = nil
        self.backgroundColor = UIColor.clear.cgColor
        self.masksToBounds = false
    }

    private func snapshot() -> CGImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        self.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image?.cgImage
    }

    private func createFloatAnim(
        fromValue: CGFloat = 1.0, toValue: CGFloat = 0.0,
        beginTime: Double = 0.0, duration: Double = 0.5,
        fillMode: CAMediaTimingFillMode = CAMediaTimingFillMode.backwards,
        keyPath: String = "transform.scale",
        easingType: CAMediaTimingFunctionName = .linear
    ) -> CABasicAnimation {
        let scaleAnim = CABasicAnimation(keyPath: keyPath)
        scaleAnim.fromValue = fromValue
        scaleAnim.toValue = toValue
        scaleAnim.duration = duration
        scaleAnim.beginTime = beginTime
        scaleAnim.fillMode = fillMode
        scaleAnim.timingFunction = CAMediaTimingFunction(name: easingType)
        return scaleAnim
    }

    private func createPointAnim(
        fromValue: CGPoint = CGPoint(x: 0, y: 0), toValue: CGPoint = CGPoint(x: 100, y: 100),
        beginTime: Double = 0.0, duration: Double = 0.5,
        fillMode: CAMediaTimingFillMode = CAMediaTimingFillMode.backwards,
        keyPath: String = "position"
    ) -> CABasicAnimation {
        let posAnim = CABasicAnimation(keyPath: keyPath)
        posAnim.fromValue = fromValue
        posAnim.toValue = toValue
        posAnim.duration = duration
        posAnim.beginTime = beginTime
        posAnim.fillMode = fillMode
        return posAnim
    }

    private func makeCirclePath(center: CGPoint = CGPoint(x: 0.0, y: 0.0), radius: CGFloat) -> UIBezierPath {
        let circlePath = UIBezierPath()
        circlePath.addArc(withCenter: center, radius: radius, startAngle: -CGFloat.pi, endAngle: -CGFloat.pi/2, clockwise: true)
        circlePath.addArc(withCenter: center, radius: radius, startAngle: -CGFloat.pi/2, endAngle: 0, clockwise: true)
        circlePath.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat.pi/2, clockwise: true)
        circlePath.addArc(withCenter: center, radius: radius, startAngle: CGFloat.pi/2, endAngle: CGFloat.pi, clockwise: true)
        circlePath.addArc(withCenter: center, radius: radius, startAngle: CGFloat.pi, endAngle: -CGFloat.pi, clockwise: true)
        circlePath.close()
        return circlePath
    }

    private func makeRectanglePath(center: CGPoint = CGPoint(x: 0.0, y: 0.0), width: CGFloat, height: CGFloat) -> UIBezierPath {
        let x: CGFloat = center.x - (width / 2.0)
        let y: CGFloat = center.y - (height / 2.0)
        
        let rectPath = UIBezierPath()
        rectPath.move(to: CGPoint(x: x, y: y))
        rectPath.addLine(to: rectPath.currentPoint)
        rectPath.addLine(to: CGPoint(x: x + width, y: y))
        rectPath.addLine(to: rectPath.currentPoint)
        rectPath.addLine(to: CGPoint(x: x + width, y: y + height))
        rectPath.addLine(to: rectPath.currentPoint)
        rectPath.addLine(to: CGPoint(x: x, y: y + height))
        rectPath.addLine(to: rectPath.currentPoint)
        rectPath.close()
        
        return rectPath
    }
}