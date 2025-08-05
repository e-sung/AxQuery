import Testing
import UIKit
#if canImport(RegexBuilder)
import RegexBuilder
#endif
@testable import AxQuery

/// AxQuery Specification Tests
///
/// These tests serve as living documentation for AxQuery, demonstrating
/// how to query UIView hierarchies using accessibility properties.
/// Each test explains a specific concept and shows practical usage.
@Suite("AxQuery")
struct AxQuerySpec {
    
    // MARK: - Chapter 1: Understanding AxQuery
    
    @Suite("Building Queries")
    @MainActor
    struct QueryBuilding {
        
        @Test("AxQuery finds views by their accessibility properties")
        func queryingByAccessibilityProperties() {
            // Given: A login form with accessible elements
            let loginForm = createLoginForm()
            
            // AxQuery can find elements by their role (what they are)
            let submitButton = loginForm.getBy(.role(.button).and(.label(.contains("Submit"))))
            #expect(submitButton.resolvedView != nil)
            
            // Or by their identifier (test IDs for automation)
            let emailField = loginForm.getByTestId("email-input")
            #expect(emailField.resolvedView != nil)
            
            // Or by their label (what users hear in VoiceOver)
            let passwordField = loginForm.getBy(.label(.exactMatch("Password")))
            #expect(passwordField.resolvedView != nil)
        }
        
        @Test("Queries can be composed to be more specific")
        func composingQueriesForPrecision() {
            // Given: Multiple buttons with similar properties
            let view = UIView()
            
            // Two submit buttons - one enabled, one disabled
            let activeSubmit = createButton(label: "Submit", enabled: true)
            let disabledSubmit = createButton(label: "Submit", enabled: false)
            view.addSubview(activeSubmit)
            view.addSubview(disabledSubmit)
            
            // Problem: Simple query would find multiple elements
            let ambiguousResult = view.queryBy(.role(.button))
            #expect(ambiguousResult.resolvedError != nil) // Multiple elements found!
            
            // Solution: Compose queries with .and() to be specific
            let activeSubmitQuery = view.getBy(
                .role(.button)
                    .and(.label(.exactMatch("Submit")))
                    .and(.enabled(true))
            )
            #expect(activeSubmitQuery.resolvedView === activeSubmit)
        }
        
        @Test("Use OR queries when elements might have different properties")
        func alternativeQueriesWithOr() {
            // Given: A form where the submit action might be a button OR a link
            let form = UIView()
            
            // Some designs use buttons
            let submitButton = createButton(label: "Submit", traits: .button)
            
            // Others use links styled as buttons
            let submitLink = createButton(label: "Submit", traits: .link)
            
            // Randomly add one of them (simulating different UI states)
            form.addSubview(Bool.random() ? submitButton : submitLink)
            
            // Query that works for both cases - try button first, then link
            let buttonResult = form.queryBy(.label(.exactMatch("Submit")).and(.role(.button)))
            let linkResult = form.queryBy(.label(.exactMatch("Submit")).and(.role(.link)))
            let submitAction = buttonResult.resolvedView != nil ? buttonResult : linkResult
            #expect(submitAction.resolvedView != nil)
        }
        
        // Helper to create a realistic login form
        private func createLoginForm() -> UIView {
            let form = UIView()
            
            let emailField = UITextField()
            emailField.accessibilityLabel = "Email"
            emailField.accessibilityIdentifier = "email-input"
            emailField.isAccessibilityElement = true
            
            let passwordField = UITextField()
            passwordField.accessibilityLabel = "Password"
            passwordField.accessibilityIdentifier = "password-input"
            passwordField.isAccessibilityElement = true
            
            let submitButton = UIButton()
            submitButton.accessibilityLabel = "Submit Login"
            submitButton.accessibilityTraits = .button
            submitButton.isAccessibilityElement = true
            
            form.addSubview(emailField)
            form.addSubview(passwordField)
            form.addSubview(submitButton)
            
            return form
        }
        
        private func createButton(label: String, enabled: Bool = true, traits: UIAccessibilityTraits = .button) -> UIButton {
            let button = UIButton()
            button.accessibilityLabel = label
            button.accessibilityTraits = enabled ? traits : [traits, .notEnabled]
            button.isAccessibilityElement = true
            return button
        }
    }
    
    // MARK: - Chapter 2: Text Matching Strategies
    
    @Suite("Text Matching")
    @MainActor
    struct TextMatchingStrategies {
        
        @Test("exactMatch - for precise, unambiguous queries")
        func exactMatchForPrecision() {
            // Use exactMatch when you need to distinguish between similar elements
            let navigation = UIView()
            
            let saveButton = createButton(label: "Save")
            let saveAsButton = createButton(label: "Save As...")
            navigation.addSubview(saveButton)
            navigation.addSubview(saveAsButton)
            
            // exactMatch ensures we get the right button
            let result = navigation.getBy(.label(.exactMatch("Save")))
            #expect(result.resolvedView === saveButton) // Not "Save As..."!
        }
        
        @Test("contains - for flexible queries that handle dynamic content")
        func containsForFlexibility() {
            // Real-world labels often include dynamic content
            let cartButton = createButton(label: "Shopping Cart (3 items)")
            let view = UIView()
            view.addSubview(cartButton)
            
            // Using exactMatch would be brittle - the item count changes!
            // let brittle = view.getBy(.label(.exactMatch("Shopping Cart (3 items)")))
            
            // contains() is more robust for dynamic content
            let flexible = view.getBy(.label(.contains("Shopping Cart")))
            #expect(flexible.resolvedView === cartButton)
            
            // Case-insensitive matching helps with inconsistent capitalization
            let caseFlexible = view.getBy(.label(.contains("shopping cart", caseSensitive: false)))
            #expect(caseFlexible.resolvedView === cartButton)
        }
        
        @Test("regex patterns - for complex matching scenarios")
        func regexForComplexPatterns() {
            let form = UIView()
            
            // Common pattern: fields with validation messages
            let emailField = UITextField()
            emailField.accessibilityLabel = "Email (invalid.email@)"
            emailField.isAccessibilityElement = true
            
            let phoneField = UITextField()
            phoneField.accessibilityLabel = "Phone (555) 123-4567"
            phoneField.isAccessibilityElement = true
            
            form.addSubview(emailField)
            form.addSubview(phoneField)
            
            // Find fields with validation errors using regex string patterns (backward compatibility)
            let emailPattern = TextMatch.regexPattern("Email.*@")
            let fieldWithError = form.getBy(.label(emailPattern))
            #expect(fieldWithError.resolvedView === emailField)
            
            // Find phone fields using NSRegularExpression (works on iOS 13+)
            let nsRegex = try! NSRegularExpression(pattern: #"\(\d{3}\)\s*\d{3}-\d{4}"#)
            let phonePattern = TextMatch.nsRegularExpression(nsRegex)
            let phoneResult = form.getBy(.label(phonePattern))
            #expect(phoneResult.resolvedView === phoneField)
        }
        
        @Test("Regex comparison - demonstrating all approaches")
        func regexComparisonAllApproaches() {
            let form = UIView()
            
            // Create a field with an email address
            let emailField = UITextField()
            emailField.accessibilityLabel = "Contact: john.doe@example.com"
            emailField.isAccessibilityElement = true
            form.addSubview(emailField)
            
            // Approach 1: regexPattern() - automatic fallback between Swift Regex and NSRegularExpression
            let autoPattern = TextMatch.regexPattern(#"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b"#)
            let autoResult = form.getBy(.label(autoPattern))
            #expect(autoResult.resolvedView === emailField)
            
            // Approach 2: Explicit NSRegularExpression (works on iOS 13+)
            let nsRegex = try! NSRegularExpression(pattern: #"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b"#)
            let nsPattern = TextMatch.nsRegularExpression(nsRegex)
            let nsResult = form.getBy(.label(nsPattern))
            #expect(nsResult.resolvedView === emailField)
            
            // All approaches should find the same element
            #expect(autoResult.resolvedView === nsResult.resolvedView)
        }
        
        #if canImport(RegexBuilder)
        @Test("Swift RegexBuilder - for type-safe, readable patterns")
        @available(iOS 16.0, macOS 13.0, macCatalyst 16.0, *)
        func swiftRegexBuilderPatterns() {
            let productList = UIView()
            
            // Products with version numbers in labels
            let betaProduct = UITextField()
            betaProduct.accessibilityLabel = "MyApp v2.1.0-beta.3"
            betaProduct.isAccessibilityElement = true
            
            let stableProduct = UITextField()
            stableProduct.accessibilityLabel = "MyApp v1.0.0"
            stableProduct.isAccessibilityElement = true
            
            productList.addSubview(betaProduct)
            productList.addSubview(stableProduct)
            
            // Using RegexBuilder for readable, type-safe patterns
            let versionRegex = Regex {
                "MyApp v"
                Capture {
                    OneOrMore(.digit)
                    "."
                    OneOrMore(.digit)  
                    "."
                    OneOrMore(.digit)
                }
                Optionally {
                    "-beta."
                    OneOrMore(.digit)
                }
            }
            
            // Find any product with version number using new Swift Regex API
            let versionPattern = TextMatch.regex(versionRegex)
            let productWithVersion = productList.queryAllBy(.label(versionPattern))
            #expect(productWithVersion.count == 2)
            
            // Find only beta versions using Swift regex literal syntax
            let betaRegex = try! Regex(#"MyApp v\d+\.\d+\.\d+-beta\.\d+"#)
            let betaPattern = TextMatch.regex(betaRegex)
            let betaResult = productList.getBy(.label(betaPattern))
            #expect(betaResult.resolvedView === betaProduct)
        }
        #endif
        
        @Test("custom predicates - for business logic in queries")
        func customPredicatesForBusinessLogic() {
            let productList = UIView()
            
            // Products with prices in their labels
            let expensiveItem = createButton(label: "Premium Headphones - $299.99")
            let cheapItem = createButton(label: "Basic Earbuds - $19.99")
            productList.addSubview(expensiveItem)
            productList.addSubview(cheapItem)
            
            // Custom predicate to find expensive items (over $100)
            let expensiveItemMatcher = TextMatch.customPredicate { label in
                guard let label = label,
                      let priceMatch = label.range(of: #"\$(\d+\.?\d*)"#, options: .regularExpression),
                      let price = Double(label[priceMatch].dropFirst()) else {
                    return false
                }
                return price > 100
            }
            
            let premiumProduct = productList.getBy(.label(expensiveItemMatcher))
            #expect(premiumProduct.resolvedView === expensiveItem)
        }
        
        private func createButton(label: String) -> UIButton {
            let button = UIButton()
            button.accessibilityLabel = label
            button.isAccessibilityElement = true
            return button
        }
    }
    
    // MARK: - Chapter 3: Querying in Real-World View Hierarchies
    
    @Suite("View Hierarchies")
    @MainActor
    struct RealWorldViewHierarchies {
        
        @Test("AxQuery searches the entire accessible subtree")
        func searchingNestedHierarchies() {
            // Real iOS apps have deeply nested view hierarchies
            let screen = UIView() // Root view controller's view
            let scrollView = UIScrollView() // For scrollable content
            let contentView = UIView() // Container for scroll content
            let formStack = UIStackView() // Form layout
            let buttonContainer = UIView() // Button alignment wrapper
            let submitButton = UIButton() // The actual button
            
            // Build the hierarchy (5 levels deep!)
            screen.addSubview(scrollView)
            scrollView.addSubview(contentView)
            contentView.addSubview(formStack)
            formStack.addArrangedSubview(buttonContainer)
            buttonContainer.addSubview(submitButton)
            
            submitButton.accessibilityLabel = "Submit"
            submitButton.accessibilityIdentifier = "submit-btn"
            submitButton.isAccessibilityElement = true
            
            // AxQuery finds the button regardless of nesting depth
            let fromRoot = screen.getByTestId("submit-btn")
            #expect(fromRoot.resolvedView === submitButton)
            
            // You can also query from any intermediate view
            let fromContainer = formStack.getByTestId("submit-btn")
            #expect(fromContainer.resolvedView === submitButton)
        }
        
        @Test("Understanding accessibility element hiding")
        func accessibilityElementBehavior() {
            // Important iOS behavior: when a container is marked as an
            // accessibility element, it hides its children from VoiceOver
            
            let card = UIView()
            let cardTitle = UILabel()
            let cardButton = UIButton()
            
            cardTitle.text = "Premium Subscription"
            cardTitle.accessibilityLabel = "Premium Subscription"
            cardTitle.isAccessibilityElement = true
            cardButton.setTitle("Upgrade", for: .normal)
            cardButton.accessibilityLabel = "Upgrade"
            cardButton.isAccessibilityElement = true
            
            card.addSubview(cardTitle)
            card.addSubview(cardButton)
            
            // Initially, both children are accessible
            #expect(card.getBy(.label(.contains("Premium"))).resolvedView === cardTitle)
            #expect(card.getBy(.label(.contains("Upgrade"))).resolvedView === cardButton)
            
            // Make the card itself an accessibility element
            card.isAccessibilityElement = true
            card.accessibilityLabel = "Premium Subscription Card"
            
            // Now the card hides its children - this matches VoiceOver behavior
            #expect(card.getBy(.label(.contains("Premium Subscription Card"))).resolvedView === card)
            #expect(card.getBy(.label(.contains("Upgrade"))).resolvedView == nil)
        }
    }
    
    // MARK: - Chapter 4: Query Methods and Their Purposes
    
    @Suite("Query Methods")
    @MainActor
    struct QueryMethodPurposes {
        
        @Test("getBy - when you expect exactly one element")
        func getByForSingleElements() {
            // Use getBy when there SHOULD be exactly one matching element
            let loginForm = UIView()
            let submitButton = UIButton()
            submitButton.accessibilityIdentifier = "login-submit"
            submitButton.isAccessibilityElement = true
            loginForm.addSubview(submitButton)
            
            // getBy returns Result<UIView, Error>
            let result = loginForm.getByTestId("login-submit")
            
            switch result {
            case .success(let button):
                #expect(button === submitButton)
            case .failure(let error):
                Issue.record("Expected to find login button: \(error)")
            }
            
            // Convenience: use resolvedView for simpler tests
            #expect(result.resolvedView === submitButton)
        }
        
        @Test("queryBy - when element might not exist") 
        func queryByForOptionalElements() {
            // Use queryBy when an element might or might not exist
            let navbar = UIView()
            
            // Back button only exists on non-root screens
            let isRootScreen = Bool.random()
            if !isRootScreen {
                let backButton = UIButton()
                backButton.accessibilityLabel = "Back"
                backButton.isAccessibilityElement = true
                navbar.addSubview(backButton)
            }
            
            // queryBy returns nil instead of error when not found
            let backButtonResult = navbar.queryBy(.label(.exactMatch("Back")))
            if isRootScreen {
                #expect(backButtonResult.resolvedView == nil)
                #expect(backButtonResult.resolvedError == nil) // No error!
            } else {
                #expect(backButtonResult.resolvedView != nil)
            }
        }
        
        @Test("queryAllBy - when you need all matching elements")
        func queryAllByForMultipleElements() {
            // Use queryAllBy to find all elements matching a query
            let todoList = createTodoList()
            
            // Find all checkboxes (using button role with selected state)
            let allCheckboxes = todoList.queryAllBy(.role(.button))
                .filter { view in
                    view.accessibilityTraits.contains(.button)
                }
            #expect(allCheckboxes.count == 3)
            
            // Find only completed items
            let completedItems = todoList.queryAllBy(
                .role(.button).and(.selected(true))
            )
            #expect(completedItems.count == 1)
            
            // queryAllBy returns empty array (not error) when nothing matches
            let nonExistent = todoList.queryAllBy(.role(.adjustable))
            #expect(nonExistent.isEmpty)
        }
        
        @Test("Choosing between getBy, queryBy, and queryAllBy")
        func choosingTheRightMethod() {
            let form = UIView()
            
            // Required field - MUST exist
            let requiredField = UITextField()
            requiredField.accessibilityIdentifier = "email-field"
            requiredField.isAccessibilityElement = true
            form.addSubview(requiredField)
            
            // Optional field - might not exist
            let phoneField = UITextField()
            phoneField.accessibilityIdentifier = "phone-field"
            phoneField.isAccessibilityElement = true
            // Conditionally added based on country
            if Bool.random() { form.addSubview(phoneField) }
            
            // Multiple error messages
            for i in 0..<3 {
                let error = UILabel()
                error.accessibilityLabel = "Error \(i)"
                error.accessibilityTraits = .staticText
                error.accessibilityIdentifier = "error-message"
                error.isAccessibilityElement = true
                if Bool.random() { form.addSubview(error) }
            }
            
            // ✓ Use getBy for required elements
            let emailResult = form.getByTestId("email-field")
            #expect(emailResult.resolvedView != nil)
            
            // ✓ Use queryBy for optional elements
            let phoneResult = form.queryBy(.identifier("phone-field"))
            #expect(phoneResult.resolvedError == nil)
            // No error even if not found
            
            let errorMessages = form.queryAllBy(.identifier("error-message"))
            #expect(errorMessages.count >= 0 && errorMessages.count <= 3)
        }
        
        private func createTodoList() -> UIView {
            let list = UIView()
            
            let item1 = createCheckbox(label: "Buy groceries", checked: false)
            let item2 = createCheckbox(label: "Write tests", checked: true)
            let item3 = createCheckbox(label: "Review PR", checked: false)
            
            list.addSubview(item1)
            list.addSubview(item2)
            list.addSubview(item3)
            
            return list
        }
        
        private func createCheckbox(label: String, checked: Bool) -> UIButton {
            let checkbox = UIButton()
            checkbox.accessibilityLabel = label
            checkbox.accessibilityTraits = checked ? [.button, .selected] : .button
            checkbox.isAccessibilityElement = true
            return checkbox
        }
    }
    
    // MARK: - Chapter 5: Common Patterns and Best Practices
    
    @Suite("Best Practices")
    @MainActor
    struct CommonPatternsAndPractices {

        @Test("Combine queries for disambiguation")
        func combineQueriesForClarity() {
            // Problem: Multiple similar elements
            let toolbar = UIView()
            
            // Three "Delete" buttons with different contexts
            let deleteOne = createButton(label: "Delete", hint: "Delete selected item")
            let deleteAll = createButton(label: "Delete", hint: "Delete all items")
            let deleteAccount = createButton(label: "Delete", hint: "Delete your account")
            
            toolbar.addSubview(deleteOne)
            toolbar.addSubview(deleteAll)
            toolbar.addSubview(deleteAccount)
            
            // ❌ Ambiguous: which delete button?
            let ambiguous = toolbar.queryBy(.label(.exactMatch("Delete")))
            #expect(ambiguous.resolvedError != nil) // Multiple elements!
            
            // ✓ Clear: use hints to distinguish
            let deleteAllButton = toolbar.getBy(
                .label(.exactMatch("Delete"))
                    .and(.hint(.contains("all items")))
            )
            #expect(deleteAllButton.resolvedView === deleteAll)
        }
        
        
        @Test("Accessibility benefits both users and tests")
        func accessibilityBenefits() {
            // Well-designed accessibility helps everyone:
            // - VoiceOver users can navigate your app
            // - Tests can reliably find elements
            // - Developers understand UI structure
            
            let toolbar = UIView()
            
            // Poor accessibility - icon-only button with no label
            let iconButton = UIButton()
            iconButton.setTitle("💾", for: .normal) // Just an emoji
            iconButton.accessibilityLabel = nil // No meaningful label for VoiceOver
            iconButton.accessibilityTraits = .button
            iconButton.isAccessibilityElement = true
            toolbar.addSubview(iconButton)
            
            // Good accessibility - clear, descriptive labels
            let saveButton = UIButton()
            saveButton.setTitle("💾", for: .normal) // Same visual appearance
            saveButton.accessibilityLabel = "Save document"
            saveButton.accessibilityHint = "Double tap to save your changes"  
            saveButton.accessibilityIdentifier = "document.save"
            saveButton.accessibilityTraits = .button
            saveButton.isAccessibilityElement = true
            toolbar.addSubview(saveButton)
            
            // The well-labeled button is easy to find in tests
            let foundButton = toolbar.getBy(.label(.contains("Save")))
            #expect(foundButton.resolvedView === saveButton)
            
            // Both buttons exist, but only the accessible one can be found meaningfully
            let allButtons = toolbar.queryAllBy(.role(.button))
            #expect(allButtons.count == 2) // Both buttons exist
        }
        
        private func createButton(label: String, hint: String) -> UIButton {
            let button = UIButton()
            button.accessibilityLabel = label
            button.accessibilityHint = hint
            button.isAccessibilityElement = true
            return button
        }
    }
    
    // MARK: - Chapter 6: Error Handling and Edge Cases
    
    @Suite("Error Handling")
    @MainActor
    struct ErrorHandlingPatterns {
        
        @Test("AxQuery provides meaningful error messages")
        func meaningfulErrors() {
            let view = UIView()
            
            // Add multiple buttons
            for i in 1...3 {
                let button = UIButton()
                button.accessibilityLabel = "Option \(i)"
                button.accessibilityTraits = .button
                button.isAccessibilityElement = true
                view.addSubview(button)
            }
            
            // Error: No elements found
            let notFoundResult = view.getBy(.role(.adjustable))
            if case .failure(let error) = notFoundResult {
                #expect(error.localizedDescription.contains("No elements found"))
                #expect(error.localizedDescription.contains("role"))
            }
            
            // Error: Multiple elements found
            let multipleResult = view.getBy(.role(.button))
            if case .failure(let error) = multipleResult {
                #expect(error.localizedDescription.contains("Found 3 elements"))
                #expect(error.localizedDescription.contains("expected 1"))
            }
        }
        
        @Test("Elements must be accessible to be found")
        func accessibilityRequirement() {
            let view = UIView()
            
            // This button exists in the view hierarchy...
            let hiddenButton = UIButton()
            hiddenButton.setTitle("Hidden", for: .normal)
            hiddenButton.accessibilityIdentifier = "hidden-button"
            hiddenButton.isAccessibilityElement = false // ...but not accessible!
            view.addSubview(hiddenButton)
            
            // AxQuery won't find non-accessible elements
            // This matches VoiceOver behavior
            let result = view.getByTestId("hidden-button")
            #expect(result.resolvedView == nil)
            #expect(result.resolvedError != nil)
            
            // Make it accessible
            hiddenButton.isAccessibilityElement = true
            
            // Now it can be found
            let visibleResult = view.getByTestId("hidden-button")
            #expect(visibleResult.resolvedView === hiddenButton)
        }
        
        @Test("Empty queries return predictable results")
        func emptyQueryResults() {
            let emptyView = UIView()
            
            // getBy with no matches returns error
            let getResult = emptyView.getBy(.role(.button))
            #expect(getResult.resolvedError != nil)
            
            // queryBy with no matches returns success(nil)
            let queryResult = emptyView.queryBy(.role(.button))
            #expect(queryResult.resolvedView == nil)
            #expect(queryResult.resolvedError == nil) // Important: no error!
            
            // queryAllBy with no matches returns empty array
            let allResults = emptyView.queryAllBy(.role(.button))
            #expect(allResults.isEmpty)
            
            // contains returns false
            #expect(!emptyView.contains(.role(.button)))
        }
    }
}
