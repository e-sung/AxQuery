import UIKit

// MARK: Core Query Methods
/// Query methods for finding accessible UI elements within a view hierarchy.
///
/// These methods search through the view's accessible descendants - elements that are
/// exposed to assistive technologies like VoiceOver. This matches how real users
/// with disabilities experience your interface.
public extension UIView {
    /// Finds exactly one element matching a query.
    /// It returns an error if no elements are found or if multiple elements match the query.
    func getBy(_ query: AxQuery) -> Result<UIView, AxQueryError> {
        let elements = exposedAccessibleViews()
        let matches = elements.filter { query.matches($0) }
        
        if matches.isEmpty {
            return .failure(.noElementsFound(query.description))
        }
        
        if matches.count > 1 {
            return .failure(.multipleElementsFound(query.description, count: matches.count))
        }
        
        return .success(matches[0])
    }
    
    /// Finds zero or one element matching a query.
    func queryBy(_ query: AxQuery) -> Result<UIView?, AxQueryError> {
        let elements = exposedAccessibleViews()
        let matches = elements.filter { query.matches($0) }
        
        if matches.count > 1 {
            return .failure(.multipleElementsFound(query.description, count: matches.count))
        }
        
        return .success(matches.first)
    }
    
    /// Alias for `getBy(_:)` - finds exactly one element matching a query.
    /// This method is identical to `getBy` and exists for API consistency with
    /// testing libraries that use "find" terminology.
    func findBy(_ query: AxQuery) -> Result<UIView, AxQueryError> {
        return getBy(query)
    }
    
    /// Finds all elements matching a query, requiring at least one match.
    func getAllBy(_ query: AxQuery) -> Result<[UIView], AxQueryError> {
        let elements = exposedAccessibleViews()
        let matches = elements.filter { query.matches($0) }
        
        if matches.isEmpty {
            return .failure(.noElementsFound(query.description))
        }
        
        return .success(matches)
    }
    
    /// Finds all elements matching a query, returning empty array if none found.
    func queryAllBy(_ query: AxQuery) -> [UIView] {
        let elements = exposedAccessibleViews()
        return elements.filter { query.matches($0) }
    }
    
    /// Alias for `queryAllBy(_:)` - finds all elements matching a query.
    ///
    /// This method is identical to `queryAllBy` and exists for API consistency
    /// with testing libraries that use "find" terminology.
    func findAllBy(_ query: AxQuery) -> [UIView] {
        return queryAllBy(query)
    }
    
    /// Checks if any elements match a query without returning them.
    func contains(_ query: AxQuery) -> Bool {
        let elements = exposedAccessibleViews()
        return !elements.filter { query.matches($0) }.isEmpty
    }
}

// MARK: - Convenience Query Methods on UIView

public extension UIView {
    /// Finds an element by its accessibility role, optionally filtered by accessible name.
    func getByRole(_ trait: UIAccessibilityTraits, name: TextMatch? = nil) -> Result<UIView, AxQueryError> {
        var query = AxQuery.role(trait)
        if let name = name {
            query = query.and(.label(name))
        }
        return getBy(query)
    }
    
    /// Finds an element by its accessibility label text.
    func getByLabelText(_ match: TextMatch) -> Result<UIView, AxQueryError> {
        return getBy(.label(match))
    }
    
    /// Finds an element by its accessibility identifier (test ID).
    func getByTestId(_ identifier: String) -> Result<UIView, AxQueryError> {
        return getBy(.identifier(identifier))
    }
    
    /// Finds an element by its current display value.
    func getByDisplayValue(_ match: TextMatch) -> Result<UIView, AxQueryError> {
        return getBy(.value(match))
    }
    
    /// Finds an element by its accessibility hint text.
    func getByHintText(_ match: TextMatch) -> Result<UIView, AxQueryError> {
        return getBy(.hint(match))
    }
}

// MARK: - Helper methods for UIView hierarchy
internal extension UIView {
    /// List of all subviews that are accessible via assistive technology such as VoiceOver
    func exposedAccessibleViews() -> [UIView] {
        var allCandidate = allSubviews
        allCandidate.insert(self, at: 0)
        return allCandidate.filter { $0.isExposedToAssistiveTech }
    }
    
    /// List of all subviews in view tree
    var allSubviews: [UIView] {
        return self.subviews.flatMap { [$0] + $0.allSubviews }
    }
}
