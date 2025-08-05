import Foundation
#if canImport(RegexBuilder)
import RegexBuilder
#endif

/// Strategies for matching text in accessibility properties.
public enum TextMatch {
    case exact(String)
    case substring(String, caseSensitive: Bool = true)
    case nsRegex(NSRegularExpression)
    #if canImport(RegexBuilder)
    case regexBuilder(Any) // Use Any to avoid availability issues, cast at runtime
    #endif
    case predicate((String?) -> Bool)
    
    internal func matches(_ text: String?) -> Bool {
        switch self {
        case .exact(let expected):
            return text == expected
        case .substring(let substring, let caseSensitive):
            guard let text = text else { return false }
            return caseSensitive ? 
                text.contains(substring) : 
                text.lowercased().contains(substring.lowercased())
        case .nsRegex(let regex):
            guard let text = text else { return false }
            return regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil
        #if canImport(RegexBuilder)
        case .regexBuilder(let regex):
            guard let text = text else { return false }
            if #available(iOS 16.0, macOS 13.0, macCatalyst 16.0, *) {
                if let regexComponent = regex as? any RegexComponent {
                    return text.contains(regexComponent)
                }
            }
            return false
        #endif
        case .predicate(let predicate):
            return predicate(text)
        }
    }
}

extension TextMatch {

    public static func exactMatch(_ text: String) -> TextMatch {
        return .exact(text)
    }

    public static func contains(_ text: String, caseSensitive: Bool = true) -> TextMatch {
        return .substring(text, caseSensitive: caseSensitive)
    }

    public static func nsRegularExpression(_ regex: NSRegularExpression) -> TextMatch {
        return .nsRegex(regex)
    }

    #if canImport(RegexBuilder)
    @available(iOS 16.0, macOS 13.0, macCatalyst 16.0, *)
    public static func regex<R: RegexComponent>(_ regex: R) -> TextMatch {
        return .regexBuilder(regex)
    }
    #endif

    public static func regexPattern(_ pattern: String, options: NSRegularExpression.Options = []) -> TextMatch {
        // Try Swift Regex first on iOS 16+
        #if canImport(RegexBuilder)
        if #available(iOS 16.0, macOS 13.0, macCatalyst 16.0, *) {
            do {
                let regex = try Regex(pattern)
                return .regexBuilder(regex)
            } catch {
                // Fall through to NSRegularExpression
            }
        }
        #endif
        
        // Fallback to NSRegularExpression
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: options)
            return .nsRegex(regex)
        } catch {
            // Final fallback to literal string matching if regex is invalid
            return .exact(pattern)
        }
    }
    
    public static func customPredicate(_ predicate: @escaping (String?) -> Bool) -> TextMatch {
        return .predicate(predicate)
    }
}

extension TextMatch: CustomStringConvertible {
    public var description: String {
        switch self {
        case .exact(let text):
            return "exactMatch(\"\(text)\")"
        case .substring(let text, let caseSensitive):
            return "contains(\"\(text)\", caseSensitive: \(caseSensitive))"
        case .nsRegex(_):
            return "nsRegex(...)"
        #if canImport(RegexBuilder)
        case .regexBuilder(_):
            if #available(iOS 16.0, macOS 13.0, macCatalyst 16.0, *) {
                return "regexBuilder(...)"
            } else {
                return "regexBuilder(...)" // Should not happen due to availability checks
            }
        #endif
        case .predicate(_):
            return "customPredicate(...)"
        }
    }
}
