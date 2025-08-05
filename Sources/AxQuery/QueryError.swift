import Foundation
import UIKit

public enum AxQueryError: Error, LocalizedError {
    case noElementsFound(String)
    case multipleElementsFound(String, count: Int)
    case elementShouldNotExist(String)
    case elementCountMismatch(expected: Int, actual: Int, query: String)
    case invalidQuery(String)
    
    public var errorDescription: String? {
        switch self {
        case .noElementsFound(let query):
            return "No elements found matching query: \(query)"
        case .multipleElementsFound(let query, let count):
            return "Found \(count) elements matching query (expected 1): \(query)"
        case .elementShouldNotExist(let query):
            return "Element should not exist but was found: \(query)"
        case .elementCountMismatch(let expected, let actual, let query):
            return "Expected \(expected) elements but found \(actual) matching: \(query)"
        case .invalidQuery(let reason):
            return "Invalid query: \(reason)"
        }
    }
}

public enum AccessibilityAssertionError: Error, LocalizedError {
    case propertyMismatch(property: String, expected: String, actual: String?)
    case unexpectedProperty(property: String, value: String)
    case traitMismatch(expected: UIAccessibilityTraits, actual: UIAccessibilityTraits)
    case customConditionFailed(description: String)
    
    public var errorDescription: String? {
        switch self {
        case .propertyMismatch(let property, let expected, let actual):
            return "Expected \(property) to be '\(expected)' but was '\(actual ?? "nil")'"
        case .unexpectedProperty(let property, let value):
            return "Expected \(property) to not have value '\(value)'"
        case .traitMismatch(let expected, let actual):
            return "Expected traits to contain \(expected) but was \(actual)"
        case .customConditionFailed(let description):
            return "Custom assertion failed: \(description)"
        }
    }
}