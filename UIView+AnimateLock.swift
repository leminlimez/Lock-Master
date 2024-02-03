import Foundation
import UIKit

@objc(UIView) extension UIView {
    @objc open func animateLock(_ animType: AnimationType = AnimationType.shrink, duration: Double = 0.5, extendFadeBy: Double = 0.2,
        completion: (() -> ())? = nil) {
            self.layer.animateLock(animType: animType, duration: duration, fadeExtension: extendFadeBy, completion: completion)
    }
}