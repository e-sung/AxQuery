import Foundation
import UIKit

internal extension UIResponder {
    var isExposedToAssistiveTech: Bool {
        if isAccessibilityElement {
            if allItemsInResponderChain.contains(where: { $0.isExposedToAssistiveTech }) == true {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }

    var allItemsInResponderChain: [UIResponder] {
        var chain = [UIResponder]()
        var nextResponder = next
        while nextResponder != nil {
            chain.append(nextResponder!)
            nextResponder = nextResponder?.next
        }
        return chain
    }
}
