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
    open func animateLock(animType: AnimationType = AnimationType.centerShrink, duration: Double = 0.5,
        completion: (() -> ())? = nil) {
        guard let snapshot = self.snapshot() else {
            return
        }
        let initialSublayers = self.sublayers ?? []
        let snapshotLayer = CALayer()
        snapshotLayer.frame = UIScreen.main.bounds
        snapshotLayer.contents = snapshot
        snapshotLayer.shouldRasterize = true
        snapshotLayer.drawsAsynchronously = true
        self.addSublayer(snapshotLayer)

        // CG Animation Stuff
        let alphaAnimation = CABasicAnimation(keyPath: "opacity")
        alphaAnimation.fromValue = 1.0
        alphaAnimation.toValue = 0.0
        alphaAnimation.duration = duration
        alphaAnimation.beginTime = 0
        alphaAnimation.fillMode = CAMediaTimingFillMode.backwards
        alphaAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        snapshotLayer.opacity = 0.0
        snapshotLayer.add(alphaAnimation, forKey: nil)

        // Determine which animation to play
        if (animType == AnimationType.centerShrink) {
            // Shrink to Center
            let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
            let targetScale: CGFloat = 0.0
            scaleAnim.fromValue = 1.0
            scaleAnim.toValue = targetScale
            scaleAnim.duration = duration
            scaleAnim.beginTime = 0
            scaleAnim.fillMode = CAMediaTimingFillMode.backwards
            snapshotLayer.setValue(targetScale, forKeyPath: "transform.scale")
            snapshotLayer.add(scaleAnim, forKey: nil)
        } else if (animType == AnimationType.tv) {
            // TV Off
            // Height Animation
            let scaleAnimY = CABasicAnimation(keyPath: "transform.scale.y")
            let targetScale: CGFloat = 0.01
            scaleAnimY.fromValue = 1.0
            scaleAnimY.toValue = targetScale
            scaleAnimY.duration = duration * 0.5
            scaleAnimY.beginTime = 0
            scaleAnimY.fillMode = CAMediaTimingFillMode.backwards
            snapshotLayer.setValue(targetScale, forKeyPath: "transform.scale.y")
            snapshotLayer.add(scaleAnimY, forKey: nil)

            // Width Animation
            let scaleAnimX = CABasicAnimation(keyPath: "transform.scale.x")
            scaleAnimX.fromValue = 1.0
            scaleAnimX.toValue = targetScale
            scaleAnimX.duration = duration * 0.5
            scaleAnimX.beginTime = duration * 0.5
            scaleAnimX.fillMode = CAMediaTimingFillMode.backwards
            snapshotLayer.setValue(targetScale, forKeyPath: "transform.scale.x")
            snapshotLayer.add(scaleAnimX, forKey: nil)
        }

        // finish the animation
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration + 0.05) {
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
}