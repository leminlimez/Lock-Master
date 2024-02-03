import Foundation

/**
 The type of animation to play
 */
@objc public enum AnimationType: Int {
    case shrink             // id: 0
    case expand             // id: 1
    case slideLeft          // id: 2
    case slideRight         // id: 3
    case slideUp            // id: 4
    case slideDown          // id: 5
    case tv                 // id: 6
    case offBtnFadeInto     // id: 7
    case offBtnFadeOut      // id: 8 (Unused)
    case genie              // id: 9
    case flip               // id: 10
    case spinSlower         // id: 11
    case spinFaster         // id: 12
    case tvNoFadeToWhite    // id: 13

    case strips             // id: 14
}