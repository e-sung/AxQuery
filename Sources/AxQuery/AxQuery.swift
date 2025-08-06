import UIKit

/// A query builder for finding UI elements using accessibility properties.
public struct AxQuery {
    internal let matchers: [Matcher]
    internal let combinator: Combinator
    
    public enum Combinator { case and, or }
    
    internal enum Matcher {
        case role(UIAccessibilityTraits)
        case label(TextMatch)
        case identifier(String)
        case value(TextMatch)
        case hint(TextMatch)
        case action(String)
        case enabled(Bool)
        case selected(Bool)
    }
    
    private init(matchers: [Matcher], combinator: Combinator) {
        self.matchers = matchers
        self.combinator = combinator
    }
    
    public static func role(_ trait: UIAccessibilityTraits) -> AxQuery {
        return AxQuery(matchers: [.role(trait)], combinator: .and)
    }
    
    public static func label(_ match: TextMatch) -> AxQuery {
        return AxQuery(matchers: [.label(match)], combinator: .and)
    }
    
    public static func identifier(_ id: String) -> AxQuery {
        return AxQuery(matchers: [.identifier(id)], combinator: .and)
    }
    
    public static func value(_ match: TextMatch) -> AxQuery {
        return AxQuery(matchers: [.value(match)], combinator: .and)
    }
    
    public static func hint(_ match: TextMatch) -> AxQuery {
        return AxQuery(matchers: [.hint(match)], combinator: .and)
    }
    
    public static func action(_ actionName: String) -> AxQuery {
        return AxQuery(matchers: [.action(actionName)], combinator: .and)
    }
    
    public static func enabled(_ isEnabled: Bool = true) -> AxQuery {
        return AxQuery(matchers: [.enabled(isEnabled)], combinator: .and)
    }
    
    public static func selected(_ isSelected: Bool = true) -> AxQuery {
        return AxQuery(matchers: [.selected(isSelected)], combinator: .and)
    }
    
    // MARK: - Composition
    
    public func and(_ other: AxQuery) -> AxQuery {
        return AxQuery(
            matchers: self.matchers + other.matchers,
            combinator: .and
        )
    }
    
    public func or(_ other: AxQuery) -> AxQuery {
        return AxQuery(
            matchers: self.matchers + other.matchers,
            combinator: .or
        )
    }
    
    // MARK: - Internal matching logic
    internal func matches(_ view: UIView) -> Bool {
        let results = matchers.map { matcher in
            switch matcher {
            case .role(let trait):
                return view.accessibilityTraits.contains(trait)
            case .label(let textMatch):
                return textMatch.matches(view.effectiveAccessibilityLabel)
            case .identifier(let id):
                return view.accessibilityIdentifier == id
            case .value(let textMatch):
                return textMatch.matches(view.effectiveAccessibilityValue)
            case .hint(let textMatch):
                return textMatch.matches(view.accessibilityHint)
            case .action(let actionName):
                let customActions = view.accessibilityCustomActions?.compactMap { $0.name } ?? []
                return customActions.contains(actionName)
            case .enabled(let isEnabled):
                let viewIsEnabled = !view.accessibilityTraits.contains(.notEnabled)
                return viewIsEnabled == isEnabled
            case .selected(let isSelected):
                let viewIsSelected = view.accessibilityTraits.contains(.selected)
                return viewIsSelected == isSelected
            }
        }
        
        switch combinator {
        case .and:
            return results.allSatisfy { $0 }
        case .or:
            return results.contains { $0 }
        }
    }
}

// MARK: - CustomStringConvertible
extension AxQuery: CustomStringConvertible {
    public var description: String {
        let matcherDescriptions = matchers.map { matcher in
            switch matcher {
            case .role(let trait):
                return "role(\(trait))"
            case .label(let textMatch):
                return "label(\(textMatch))"
            case .identifier(let id):
                return "identifier(\"\(id)\")"
            case .value(let textMatch):
                return "value(\(textMatch))"
            case .hint(let textMatch):
                return "hint(\(textMatch))"
            case .action(let actionName):
                return "action(\"\(actionName)\")"
            case .enabled(let isEnabled):
                return "enabled(\(isEnabled))"
            case .selected(let isSelected):
                return "selected(\(isSelected))"
            }
        }
        
        let combinatorString = combinator == .and ? " AND " : " OR "
        return matcherDescriptions.joined(separator: combinatorString)
    }
}
