import Foundation
import UIKit

/*
 * Notes:
 * Unless specified otherwise, timing is relative to the total duration (as a percentage).
 * For example, duration of 1.0 is the full duration, 0.5 is 50% of the duration, and 0.0
 * is 0% of the total duration.
 */

struct LockMasterAnimation {
    /* Fade Properties */
    let hasFade: Bool = true
    let fadeBeginTime: Double = 0.0
    let fadeDuration: Double = 1.0
    let fadeAdditionalDuration: Double = 0.05 // exact value, not relative to duration

    /* Animations */
    let animations: [AnimationSegment]
}

struct AnimationSegment {
    /* Mask */
    let isMask: Bool = false
    let maskPath: CGPath? = nil

    /* Animation Properties */
    let keyPath: String

    let fromValue: Any?
    let toValue: Any?

    let beginTime: Double = 0.0
    let duration: Double = 1.0

    let fillMode: CAMediaTimingFillMode = .backwards
    let easingType: CAMediaTimingFunctionName = .linear
}