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
    open func animateLock(animType: AnimationType = AnimationType.shrink, duration: Double = 0.5, fadeExtension: Double = 0.2,
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
        /*if animType != .tv && animType != .offBtnFadeInto && animType != .offBtnFadeOut {
            let alphaAnimation = CABasicAnimation(keyPath: "opacity")
            alphaAnimation.fromValue = 1.0
            alphaAnimation.toValue = 0.0
            alphaAnimation.duration = duration + 0.05
            alphaAnimation.beginTime = 0
            alphaAnimation.fillMode = CAMediaTimingFillMode.backwards
            alphaAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
            snapshotLayer.opacity = 0.0
            snapshotLayer.add(alphaAnimation, forKey: nil)
        }*/

        // Determine which animation to play
        switch (animType) {
        case .shrink, .expand:
            /* Start Shrink or Expand to Center */
            let targetScale: CGFloat = animType == .expand ? 5.0 : 0.0
            snapshotLayer.setValue(targetScale, forKeyPath: "transform.scale")
            snapshotLayer.add(createFloatAnim(toValue: targetScale, duration: duration), forKey: nil)
            /* End Shrink or Expand */
        case .slideLeft, .slideRight, .slideUp, .slideDown:
            /* Start Slide to a Side */
            let targetPosX: CGFloat = self.bounds.width * (animType == .slideLeft ? -1 : (animType == .slideRight ? 1 : 0.5))
            let targetPosY: CGFloat = self.bounds.height * (animType == .slideUp ? -1 : (animType == .slideDown ? 1 : 0.5))
            let targetPos: CGPoint = CGPoint(x: targetPosX, y: targetPosY)
            snapshotLayer.add(
                createPointAnim(fromValue: snapshotLayer.position, toValue: targetPos, duration: duration),
                forKey: nil
            )
            /* End Slide to a Side */
        case .tv:
            /* Start CRT TV */
            let scaleAnims = CAAnimationGroup()
            // Width Animation
            let targetScaleWidth: CGFloat = 3/snapshotLayer.bounds.size.width
            snapshotLayer.setValue(targetScaleWidth, forKeyPath: "transform.scale.x")
            
            // Height Animation
            let targetScaleHeight: CGFloat = 3/snapshotLayer.bounds.size.height
            snapshotLayer.setValue(targetScaleHeight, forKeyPath: "transform.scale.y")

            // Color Animation
            let colorLayer = CALayer()
            colorLayer.frame = snapshotLayer.bounds
            colorLayer.backgroundColor = UIColor.white.cgColor
            colorLayer.opacity = 1.0
            snapshotLayer.addSublayer(colorLayer)
            snapshotLayer.opacity = 0.0
            
            let colorAnims = CAAnimationGroup()

            scaleAnims.animations = [
                createFloatAnim(
                    fromValue: 1.0, toValue: targetScaleHeight,
                    beginTime: 0, duration: duration * 0.45,
                    keyPath: "transform.scale.y", easingType: .easeIn
                ),
                createFloatAnim(
                    fromValue: 1.0, toValue: targetScaleWidth,
                    beginTime: duration * 0.5, duration: duration * 0.4,
                    keyPath: "transform.scale.x", easingType: .easeOut
                ),
                createFloatAnim(
                    fromValue: 1.0, toValue: 0.0,
                    beginTime: duration * 0.9, duration: duration * 0.1,
                    keyPath: "opacity"
                )
            ]
            scaleAnims.duration = duration
            colorAnims.animations = [
                createFloatAnim(
                    fromValue: 0.0, toValue: 1.0,
                    beginTime: duration * 0.3, duration: duration * 0.2,
                    keyPath: "opacity"
                )
            ]
            colorAnims.duration = duration
            snapshotLayer.add(scaleAnims, forKey: nil)
            colorLayer.add(colorAnims, forKey: nil)
            /* End CRT TV */
        case .offBtnFadeInto, .offBtnFadeOut:
            /* Start Fade Into or From Off Button */
            // Mask
            maskLayer.frame = snapshotLayer.frame
            let screenCenter = CGPoint(x: snapshotLayer.bounds.size.width / 2.0, y: snapshotLayer.bounds.size.height / 2.0)
            let offBtnPos = CGPoint(x: screenCenter.x + snapshotLayer.bounds.size.width * 0.55, y: screenCenter.y - snapshotLayer.bounds.size.height * 0.175)
            let rectPath = makeRectanglePath(center: screenCenter, width: snapshotLayer.bounds.size.width, height: snapshotLayer.bounds.size.height).cgPath
            let circlePath = makeCirclePath(center: screenCenter, radius: snapshotLayer.bounds.size.width).cgPath
            maskLayer.path = animType == .offBtnFadeInto ? circlePath : rectPath
            if animType == .offBtnFadeInto {
                snapshotLayer.mask = maskLayer
            } else {
                maskLayer.backgroundColor = UIColor.black.cgColor
                snapshotLayer.addSublayer(maskLayer)
            }

            maskLayer.setValue(animType == .offBtnFadeInto ? 0.0 : 1.0, forKeyPath: "transform.scale")

            // Path Animation
            let pathAnim = CABasicAnimation(keyPath: "path")
            if animType == .offBtnFadeInto {
                pathAnim.fromValue = rectPath
                pathAnim.toValue = circlePath
                pathAnim.duration = duration * 0.6
                pathAnim.beginTime = 0.0
                maskLayer.position = offBtnPos
            } else {
                pathAnim.fromValue = circlePath
                pathAnim.toValue = rectPath
                pathAnim.duration = duration * 0.8
                pathAnim.beginTime = 0.0
                maskLayer.position = screenCenter
            }
            pathAnim.timingFunction = CAMediaTimingFunction(name: animType == .offBtnFadeInto ? .easeIn : .easeOut)

            let maskAnims = CAAnimationGroup()
            maskAnims.animations = [
                pathAnim,
                createFloatAnim(
                    fromValue: animType == .offBtnFadeInto ? 1.0 : 0.0,
                    toValue: animType == .offBtnFadeInto ? 0.0 : 1.0,
                    beginTime: 0.0, duration: duration,
                    easingType: .linear
                ),
                createPointAnim(
                    fromValue: animType == .offBtnFadeInto ? screenCenter : offBtnPos,
                    toValue: animType == .offBtnFadeInto ? offBtnPos : screenCenter,
                    beginTime: 0.0, duration: animType == .offBtnFadeInto ? duration * 0.9 : duration,
                    easingType: .linear
                )
            ]
            maskAnims.duration = duration
            maskLayer.add(maskAnims, forKey: nil)
            /* End Fade Into or From Off Button */
        case .genie:
            /* Start Genie Suck Effect (into off button) */
            // 3D Transformation
            let screenCenter = CGPoint(x: snapshotLayer.bounds.size.width / 2.0, y: snapshotLayer.bounds.size.height / 2.0)
            let offBtnPos = CGPoint(x: screenCenter.x + snapshotLayer.bounds.size.width * 0.55, y: screenCenter.y - snapshotLayer.bounds.size.height * 0.175)
            snapshotLayer.setValue(offBtnPos, forKeyPath: "position")
            
            var transformRotate3D = CATransform3DIdentity
            transformRotate3D.m34 = 1.0 / -500.0
            let rotationAngle = 45.0
            transformRotate3D = CATransform3DRotate(transformRotate3D, rotationAngle * .pi / 180.0, 0.0, 1.0, 0.0)
            snapshotLayer.transform = transformRotate3D
            
            snapshotLayer.setValue(rotationAngle * .pi / 180.0, forKeyPath: "transform.rotation.y")
            snapshotLayer.setValue(0.05, forKeyPath: "transform.scale")
            
            let animGroup = CAAnimationGroup()
            
            animGroup.animations = [
                createFloatAnim(
                    fromValue: 0.0, toValue: rotationAngle * .pi / 180.0,
                    beginTime: 0.0, duration: duration * 0.6,
                    keyPath: "transform.rotation.y", easingType: .easeOut
                ),
                createPointAnim(
                    fromValue: screenCenter, toValue: offBtnPos,
                    beginTime: 0.0, duration: duration,
                    easingType: .easeIn
                ),
                createFloatAnim(
                    fromValue: 1.0, toValue: 0.0,
                    beginTime: 0.0, duration: duration,
                    easingType: .easeIn
                )
            ]
            animGroup.duration = duration
            snapshotLayer.add(animGroup, forKey: nil)
            /* End Genie Suck Effect */
        case .flip, .spin:
            /* Start Flip/Spin Effect */
            var transformRotate3D = CATransform3DIdentity
            transformRotate3D.m34 = 1.0 / -500.0
            let rotationAngle = animType == .flip ? 90.0 : 630.0
            transformRotate3D = CATransform3DRotate(transformRotate3D, rotationAngle * .pi / 180.0, 0.0, 1.0, 0.0)
            snapshotLayer.transform = transformRotate3D
            
            snapshotLayer.setValue(rotationAngle * .pi / 180.0, forKeyPath: "transform.rotation.y")
            
            snapshotLayer.add(createFloatAnim(
                fromValue: 0.0, toValue: rotationAngle * .pi / 180.0,
                beginTime: 0.0, duration: duration,
                keyPath: "transform.rotation.y", easingType: animType == .flip ? .easeOut : .easeInEaseOut
            ), forKey: nil)
            /* End Flip/Spin Effect */
        }

        // finish the animation
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration + fadeExtension) {
            maskLayer.removeFromSuperlayer()
            snapshotLayer.removeFromSuperlayer()
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
        keyPath: String = "position",
        easingType: CAMediaTimingFunctionName = .linear
    ) -> CABasicAnimation {
        let posAnim = CABasicAnimation(keyPath: keyPath)
        posAnim.fromValue = fromValue
        posAnim.toValue = toValue
        posAnim.duration = duration
        posAnim.beginTime = beginTime
        posAnim.fillMode = fillMode
        posAnim.timingFunction = CAMediaTimingFunction(name: easingType)
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