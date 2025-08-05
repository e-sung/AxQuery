# AxQuery

**Find UI elements the way users actually experience them**

AxQuery is a Swift library for querying iOS view hierarchies using accessibility properties. 
Inspired by [React Testing Library](https://testing-library.com/), it helps you write tests that work the way real users (including assistive technology users) interact with your app.

## Quick Start

```swift
import AxQuery

// Find a button by its accessible name
let submitButton = view.getBy(.label(.exactMatch("Submit")))

// Find a text field by its test ID
let emailField = view.getByTestId("email-input")

// Find an element by combining properties
let enabledSaveButton = view.getBy(
    .role(.button)
    .and(.label(.contains("Save")))
    .and(.enabled(true))
)

// Check if an element exists
if view.contains(.label(.contains("Welcome"))) {
    print("User is logged in")
}
```

## Core Query Methods

### `getBy()` - When you expect exactly one element
```swift
// Throws error if 0 or multiple elements found
let result = view.getBy(.role(.button))
switch result {
case .success(let button):
    // Found exactly one button
case .failure(let error):
    // Handle error: none found or multiple found
}
```

### `queryBy()` - When an element might not exist
```swift
// Returns nil if not found, no error
let backButton = view.queryBy(.label(.exactMatch("Back")))
if let button = backButton.resolvedView {
    // Back button exists (not on root screen)
}
```

### `queryAllBy()` - When you need all matching elements
```swift
// Returns array of all matching elements
let allButtons = view.queryAllBy(.role(.button))
print("Found \(allButtons.count) buttons")
```

## Query Building

### By Role (What it is)
```swift
.role(.button)          // Any button
.role(.textField)       // Text input fields
.role(.staticText)      // Labels and static text
```

### By Label (What users hear in VoiceOver)
```swift
.label(.exactMatch("Login"))              // Exact text match
.label(.contains("Cart"))                 // Contains text
.label(.contains("cart", caseSensitive: false))  // Case insensitive
```

### By Value (Current state/content)
```swift
.value(.contains("john@"))    // Text field current value
```

### By State
```swift
.enabled(true)        // Element is enabled
.selected(true)       // Element is selected (checkboxes, tabs)
```

## Combining Queries

Use `.and()` to make queries more specific:
```swift
// Find the enabled save button (not the disabled one)
let activeSaveButton = view.getBy(
    .role(.button)
    .and(.label(.contains("Save")))
    .and(.enabled(true))
)
```

Use `.or()` for alternative matching:
```swift
// Find submit action whether it's a button or link
let submitQuery = AxQuery
    .role(.button).and(.label(.contains("Submit")))
    .or(.role(.link).and(.label(.contains("Submit"))))
```

## Advanced Text Matching

### Flexible text patterns
```swift
// Dynamic content - cart shows item count
.label(.contains("Shopping Cart"))  // Matches "Shopping Cart (3 items)"

// Case insensitive matching
.label(.contains("username", caseSensitive: false))
```

### Regular expressions
```swift
// Using regex patterns (backwards compatible)
let emailPattern = TextMatch.regexPattern(#"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b"#)
let emailField = view.getBy(.label(emailPattern))

// Using NSRegularExpression directly
let regex = try! NSRegularExpression(pattern: #"\(\d{3}\)\s*\d{3}-\d{4}"#)
let phoneField = view.getBy(.label(.nsRegularExpression(regex)))
```

### Custom logic
```swift
// Find expensive items (price > $100)
let expensiveItemMatcher = TextMatch.customPredicate { label in
    guard let label = label,
          let priceMatch = label.range(of: #"\$(\d+\.?\d*)"#, options: .regularExpression),
          let price = Double(label[priceMatch].dropFirst()) else {
        return false
    }
    return price > 100
}
```

## Installation

### Swift Package Manager
```swift
dependencies: [
    .package(url: "https://github.com/yourusername/AxQuery.git", from: "1.0.0")
]
```

### Requirements
- iOS 13.0+ / macOS 10.15+ / macCatalyst 13.0+
- Swift 5.9+


## License

MIT License - see LICENSE file for details.
