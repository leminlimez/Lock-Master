import Foundation
import UIKit
import QuartzCore

struct Rectangle {
    let center: CGPoint
    let width: CGFloat
    let height: CGFloat

    var boundingRect: CGRect {
        return CGRect(
            x: self.center.x - self.width * 0.5,
            y: self.center.y - self.height * 0.5,
            width: self.width, height: self.height
        )
    }

    var path: CGPath {
        let x: CGFloat = self.center.x - (self.width / 2.0)
        let y: CGFloat = self.center.y - (self.height / 2.0)
        
        let rectPath = UIBezierPath()
        rectPath.move(to: CGPoint(x: x, y: y))
        rectPath.addLine(to: rectPath.currentPoint)
        rectPath.addLine(to: CGPoint(x: x + self.width, y: y))
        rectPath.addLine(to: rectPath.currentPoint)
        rectPath.addLine(to: CGPoint(x: x + self.width, y: y + self.height))
        rectPath.addLine(to: rectPath.currentPoint)
        rectPath.addLine(to: CGPoint(x: x, y: y + self.height))
        rectPath.addLine(to: rectPath.currentPoint)
        rectPath.close()
        
        return rectPath.cgPath
    }
}

extension CALayer {
    private enum GridSortDirection: Int {
        case up
        case down
        case left
        case right
        case downLeft
        case downRight
        case none
    }

    open func animateLock(animType: AnimationType = AnimationType.shrink, duration: Double = 0.5, fadeExtension: Double = 0.2,
        completion: (() -> ())? = nil) {
        // TODO: Make a determining property for the animation type enum (Basic or Advanced)
        if (animType == .strips) {
            // Advanced Rectangle Animation
            self.createGridRectangles(rows: 12, columns: 1, direction: .left) { rects in
                DispatchQueue.main.async {
                    self.animateAdvancedRectangleLock(withRectangles: rects, animType: animType, duration: duration, fadeExtension: fadeExtension, completion: completion)
                }
            }
        } else if (animType == .checkerFlip) {
            // Advanced Rectangle Animation
            self.createGridRectangles(rows: 8, columns: 16, direction: .none) { rects in
                DispatchQueue.main.async {
                    self.animateAdvancedRectangleLock(withRectangles: rects, animType: animType, duration: duration, fadeExtension: fadeExtension, completion: completion)
                }
            }
        } else {
            // Basic Animation
            self.animateBasicLock(animType: animType, duration: duration, fadeExtension: fadeExtension, completion: completion)
        }
    }


    // MARK: Advanced Animations
    private func animateAdvancedRectangleLock(withRectangles rects: [Rectangle],
        animType: AnimationType = AnimationType.shrink, duration: Double = 0.5, fadeExtension: Double = 0.2,
        completion: (() -> ())? = nil) {
        guard let snapshot = self.snapshot() else {
            return
        }
        let scale = UIScreen.main.scale
        let initialSublayers = self.sublayers ?? []
        var rectLayers = [CALayer]()

        for (i, rect) in rects.enumerated() {
            let bounds = rect.boundingRect
            let rectImg = snapshot.cropping(to: bounds.applying(CGAffineTransform(scaleX: scale, y: scale)))

            let rectLayer = CALayer()
            rectLayer.frame = bounds
            rectLayer.contents = rectImg
            rectLayer.shouldRasterize = true
            rectLayer.drawsAsynchronously = true
            rectLayers.append(rectLayer)
            self.addSublayer(rectLayer)

            // animation-specific
            switch (animType) {
            case .strips:
                /* Start Strips Effect */
                var transformRotate3D = CATransform3DIdentity
                transformRotate3D.m34 = 1.0 / -500.0
                let rotationAngle = -90.0 * .pi / 180.0
                transformRotate3D = CATransform3DRotate(transformRotate3D, rotationAngle, 1.0, 0.0, 0.0)
                rectLayer.transform = transformRotate3D
                
                rectLayer.setValue(rotationAngle, forKeyPath: "transform.rotation.x")
                
                // this needs to be in a group, otherwise those without begin time of 0.0 will just disappear
                // animation groups are stupid
                let animGroup = CAAnimationGroup()
                animGroup.animations = [
                    createFloatAnim(
                        fromValue: 0.0, toValue: rotationAngle,
                        beginTime: 0.8 * (Double(i) / Double(rects.count)) * duration, duration: duration * 0.2,
                        keyPath: "transform.rotation.x", easingType: .easeOut
                    )
                ]
                animGroup.duration = duration
                rectLayer.add(animGroup, forKey: nil)
                /* End Strips Effect */
            case .checkerFlip:
                /* Start Checker Flip Effect */
                let order: Int = (i % 8) + (i / 8)//(i % 5) + (i / 5)
                let startOffset: Double = 0.8 * (Double(order) / 23) * duration
                var transformRotate3D = CATransform3DIdentity
                transformRotate3D.m34 = 1.0 / -500.0
                let rotationAngle = 90.0 * .pi / 180.0
                transformRotate3D = CATransform3DRotate(transformRotate3D, rotationAngle, 1.0, 1.0, 0.0)
                rectLayer.transform = transformRotate3D
                
                rectLayer.setValue(rotationAngle, forKeyPath: "transform.rotation.x")
                rectLayer.setValue(rotationAngle, forKeyPath: "transform.rotation.y")
                
                let animGroup = CAAnimationGroup()
                animGroup.animations = [
                    createFloatAnim(
                        fromValue: 0.0, toValue: rotationAngle,
                        beginTime: startOffset, duration: duration * 0.2,
                        keyPath: "transform.rotation.x", easingType: .easeOut
                    ),
                    createFloatAnim(
                        fromValue: 0.0, toValue: rotationAngle,
                        beginTime: startOffset, duration: duration * 0.2,
                        keyPath: "transform.rotation.y", easingType: .easeOut
                    )
                ]
                animGroup.duration = duration
                rectLayer.add(animGroup, forKey: nil)
                /* End Checker Flip Effect */
            default:
                print("No advanced rectangle animation for that!")
            }
        }

        // finish the animation
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration + fadeExtension) {
            rectLayers.forEach { $0.removeFromSuperlayer() }
            completion?()
        }

        initialSublayers.forEach { (layer) in
            layer.opacity = 0.0
        }

        self.contents = nil
        self.backgroundColor = UIColor.clear.cgColor
        self.masksToBounds = false
    }


    // MARK: Basic Animations
    private func animateBasicLock(animType: AnimationType = AnimationType.shrink, duration: Double = 0.5, fadeExtension: Double = 0.2,
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

        // Determine which animation to play
        switch (animType) {
        case .shrink:
            /* Start Shrink to Center */
            let targetScale: CGFloat = 0.0
            snapshotLayer.setValue(targetScale, forKeyPath: "transform.scale")
            snapshotLayer.add(createFloatAnim(toValue: targetScale, duration: duration), forKey: nil)
            /* End Shrink */
        case .expand:
            /* Start Expand to Center */
            let targetScale: CGFloat = 10.0 // OLD VALUE: 5.0
            snapshotLayer.setValue(targetScale, forKeyPath: "transform.scale")
            snapshotLayer.setValue(0.0, forKeyPath: "opacity")
            let expandAnims = CAAnimationGroup()
            expandAnims.animations = [
                createFloatAnim(fromValue: 1.0, toValue: targetScale, duration: duration, easingType: .easeIn),
                createFloatAnim(fromValue: 1.0, toValue: 0.0, duration: duration, keyPath: "opacity")
            ]
            expandAnims.duration = duration
            snapshotLayer.add(expandAnims, forKey: nil)
            /* End Expand */
        case .slideLeft, .slideRight, .slideUp, .slideDown:
            /* Start Slide to a Side */
            let screenCenter = CGPoint(x: snapshotLayer.bounds.size.width / 2.0, y: snapshotLayer.bounds.size.height / 2.0)
            let targetPosX: CGFloat = self.bounds.width * (animType == .slideLeft ? -1 : (animType == .slideRight ? 1.5 : 0.5))
            let targetPosY: CGFloat = self.bounds.height * (animType == .slideUp ? -1 : (animType == .slideDown ? 1.5 : 0.5))
            let targetPos: CGPoint = CGPoint(x: targetPosX, y: targetPosY)
            snapshotLayer.setValue(targetPos, forKeyPath: "position")
            snapshotLayer.add(
                createPointAnim(fromValue: screenCenter, toValue: targetPos, duration: duration),
                forKey: nil
            )
            /* End Slide to a Side */
        case .tv, .tvNoFadeToWhite:
            /* Start CRT TV */
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

            // Color Animation
            if animType == .tv {
                let colorLayer = CALayer()
                colorLayer.frame = snapshotLayer.bounds
                colorLayer.backgroundColor = UIColor.white.cgColor
                colorLayer.opacity = 1.0
                snapshotLayer.addSublayer(colorLayer)
                snapshotLayer.opacity = 0.0
                
                let colorAnims = CAAnimationGroup()

                colorAnims.animations = [
                    createFloatAnim(
                        fromValue: 0.0, toValue: 1.0,
                        beginTime: duration * 0.3, duration: duration * 0.2,
                        keyPath: "opacity"
                    )
                ]
                colorAnims.duration = duration
                colorLayer.add(colorAnims, forKey: nil)
            }
            snapshotLayer.add(scaleAnims, forKey: nil)
            /* End CRT TV */
        case .offBtnFadeInto, .offBtnFadeOut:
            /* Start Fade Into or From Off Button */
            // Mask
            maskLayer.frame = snapshotLayer.frame
            let screenCenter = CGPoint(x: snapshotLayer.bounds.size.width / 2.0, y: snapshotLayer.bounds.size.height / 2.0)
            let offBtnPos = CGPoint(x: screenCenter.x + snapshotLayer.bounds.size.width * 0.55, y: screenCenter.y - snapshotLayer.bounds.size.height * 0.175)
            let rectPath = Rectangle(center: screenCenter, width: snapshotLayer.bounds.size.width, height: snapshotLayer.bounds.size.height).path
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
        case .flip, .spinSlower, .spinFaster:
            /* Start Flip/Spin Effect */
            var transformRotate3D = CATransform3DIdentity
            transformRotate3D.m34 = 1.0 / -500.0
            let rotationAngle = animType == .flip ? 90.0 : (animType == .spinSlower ? 270.0 : 630.0)
            transformRotate3D = CATransform3DRotate(transformRotate3D, rotationAngle * .pi / 180.0, 0.0, 1.0, 0.0)
            snapshotLayer.transform = transformRotate3D
            
            snapshotLayer.setValue(rotationAngle * .pi / 180.0, forKeyPath: "transform.rotation.y")
            
            snapshotLayer.add(createFloatAnim(
                fromValue: 0.0, toValue: rotationAngle * .pi / 180.0,
                beginTime: 0.0, duration: duration,
                keyPath: "transform.rotation.y", easingType: animType == .flip ? .easeOut : .easeInEaseOut
            ), forKey: nil)
            /* End Flip/Spin Effect */
        default:
            print("No basic animation for that!")
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

    
    // MARK: Additional Functions
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

    private func createGridRectangles(rows: Int, columns: Int, direction: GridSortDirection,
        completion: @escaping([Rectangle]) -> ()) {
        DispatchQueue.global(qos: .background).async {
            let width: CGFloat = (self.bounds.width / CGFloat(rows))
            let height: CGFloat = (self.bounds.height / CGFloat(columns))

            // create the rects
            var rects: [Rectangle] = []
            for col in 0..<columns {
                for row in 0..<rows {
                    rects.append(Rectangle(
                        center: CGPoint(x: (width * CGFloat(row)) + (width * 0.5), y: (height * CGFloat(col)) + (height * 0.5)),
                        width: width, height: height
                    ))
                }
            }

            // sort the rects
            if direction == .none {
                completion(rects)
            } else {
                let sortedRects = rects.sorted(by: { (rect1, rect2) -> Bool in
                    switch (direction) {
                    case .up:
                        return rect1.center.y < rect2.center.y
                    case .down:
                        return rect1.center.y > rect2.center.y
                    case .left:
                        return rect1.center.x < rect2.center.x
                    case .right:
                        return rect1.center.x > rect2.center.x
                    case .downLeft:
                        return (floor(rect1.center.y) == floor(rect2.center.y) ? rect1.center.x < rect2.center.x : rect1.center.y < rect2.center.y)
                    case .downRight:
                        return (floor(rect1.center.y) == floor(rect2.center.y) ? rect1.center.x > rect2.center.x : rect1.center.y < rect2.center.y)
                    case .none:
                        return true
                    }
                })

                completion(sortedRects)
            }
        }
    }
}