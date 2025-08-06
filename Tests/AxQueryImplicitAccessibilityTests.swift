import Testing
import UIKit
@testable import AxQuery

@Suite("Implicit Accessibility Labels")
@MainActor
struct AxQueryImplicitAccessibilityTests {
    
    @Test("UILabel.text becomes implicit accessibilityLabel when no explicit label is set")
    func uiLabelImplicitAccessibilityLabel() {
        let container = UIView()
        
        let label1 = UILabel()
        label1.text = "Hello World"
        label1.isAccessibilityElement = true
        container.addSubview(label1)
        
        let label2 = UILabel()
        label2.text = "Welcome to the app"
        label2.isAccessibilityElement = true
        container.addSubview(label2)
        
        let label3 = UILabel()
        label3.text = "Settings"
        label3.accessibilityLabel = "Application Settings"
        label3.isAccessibilityElement = true
        container.addSubview(label3)
        
        let helloResult = container.getByLabelText(.exactMatch("Hello World"))
        #expect(helloResult.resolvedView === label1, "Should find label by its text content")
        
        let welcomeResult = container.getByLabelText(.contains("Welcome"))
        #expect(welcomeResult.resolvedView === label2, "Should find label by partial text match")
        
        let settingsResult = container.getByLabelText(.exactMatch("Application Settings"))
        #expect(settingsResult.resolvedView === label3, "Explicit accessibilityLabel should override text")
        
        let textSettingsResult = container.queryBy(.label(.exactMatch("Settings")))
        #expect(textSettingsResult.resolvedView == nil, "Should not find by text when explicit label is set")
    }
    
    @Test("UIButton.setTitle becomes implicit accessibilityLabel")
    func uiButtonImplicitAccessibilityLabel() {
        let container = UIView()
        
        let button1 = UIButton(type: .system)
        button1.setTitle("Save", for: .normal)
        button1.isAccessibilityElement = true
        container.addSubview(button1)
        
        let button2 = UIButton(type: .system)
        button2.setTitle("Cancel", for: .normal)
        button2.isAccessibilityElement = true
        container.addSubview(button2)
        
        let button3 = UIButton(type: .system)
        button3.setTitle("Delete", for: .normal)
        button3.accessibilityLabel = "Delete all items"
        button3.isAccessibilityElement = true
        container.addSubview(button3)
        
        let saveResult = container.getByLabelText(.exactMatch("Save"))
        #expect(saveResult.resolvedView === button1, "Should find button by its title")
        
        let cancelResult = container.getByLabelText(.exactMatch("Cancel"))
        #expect(cancelResult.resolvedView === button2, "Should find button by its title")
        
        let deleteResult = container.getByLabelText(.exactMatch("Delete all items"))
        #expect(deleteResult.resolvedView === button3, "Explicit accessibilityLabel should override title")
        
        let titleDeleteResult = container.queryBy(.label(.exactMatch("Delete")))
        #expect(titleDeleteResult.resolvedView == nil, "Should not find by title when explicit label is set")
    }
    
    @Test("UIButton with attributed title uses implicit accessibilityLabel")
    func uiButtonAttributedTitleAccessibility() {
        let container = UIView()
        
        let button = UIButton(type: .custom)
        let attributedString = NSAttributedString(
            string: "Styled Button",
            attributes: [
                .foregroundColor: UIColor.blue,
                .font: UIFont.boldSystemFont(ofSize: 16)
            ]
        )
        button.setAttributedTitle(attributedString, for: .normal)
        button.isAccessibilityElement = true
        container.addSubview(button)
        
        let result = container.getByLabelText(.exactMatch("Styled Button"))
        #expect(result.resolvedView === button, "Should find button by attributed title text")
    }
    
    @Test("UITextField placeholder becomes implicit accessibilityLabel")
    func uiTextFieldImplicitAccessibilityLabel() {
        let container = UIView()
        
        let textField1 = UITextField()
        textField1.placeholder = "Enter your email"
        textField1.isAccessibilityElement = true
        container.addSubview(textField1)
        
        let textField2 = UITextField()
        textField2.placeholder = "Password"
        textField2.text = "mysecretpass"
        textField2.isAccessibilityElement = true
        container.addSubview(textField2)
        
        let textField3 = UITextField()
        textField3.placeholder = "Phone"
        textField3.accessibilityLabel = "Phone number input"
        textField3.isAccessibilityElement = true
        container.addSubview(textField3)
        
        let emailResult = container.getByLabelText(.contains("email"))
        #expect(emailResult.resolvedView === textField1, "Should find text field by placeholder")
        
        let phoneResult = container.getByLabelText(.exactMatch("Phone number input"))
        #expect(phoneResult.resolvedView === textField3, "Explicit label should override placeholder")
    }
    
    @Test("UITextView text becomes implicit accessibilityLabel for short text")
    func uiTextViewImplicitAccessibilityLabel() {
        let container = UIView()
        
        let textView1 = UITextView()
        textView1.text = "Short description"
        textView1.isAccessibilityElement = true
        container.addSubview(textView1)
        
        let textView2 = UITextView()
        textView2.text = "This is a much longer text that would typically not be used as an accessibility label because it would be too verbose for VoiceOver users. In practice, long text content should have a separate, concise accessibility label."
        textView2.accessibilityLabel = "Long text view"
        textView2.isAccessibilityElement = true
        container.addSubview(textView2)
        
        let shortResult = container.getByLabelText(.exactMatch("Short description"))
        #expect(shortResult.resolvedView === textView1, "Should find text view by its short text content")
        
        let longResult = container.getByLabelText(.exactMatch("Long text view"))
        #expect(longResult.resolvedView === textView2, "Should use explicit label for long text")
    }

    @Test("UISwitch implicit accessibility behavior")
    func uiSwitchImplicitAccessibility() {
        let container = UIView()
        
        let label = UILabel()
        label.text = "Enable Notifications"
        label.isAccessibilityElement = true
        container.addSubview(label)
        
        let switch1 = UISwitch()
        switch1.isOn = true
        switch1.isAccessibilityElement = true
        container.addSubview(switch1)
        
        let switch2 = UISwitch()
        switch2.isOn = false
        switch2.accessibilityLabel = "Dark Mode"
        switch2.isAccessibilityElement = true
        container.addSubview(switch2)
        
        let darkModeResult = container.getByLabelText(.exactMatch("Dark Mode"))
        #expect(darkModeResult.resolvedView === switch2, "Should find switch by explicit label")
        
        // Note: Switches are accessible elements but may not have button trait
        let allAccessible = container.exposedAccessibleViews()
        let allSwitches = allAccessible.filter { $0 is UISwitch }
        #expect(allSwitches.count == 2, "Should find both switches")
    }
    
    @Test("Complex view with mixed implicit and explicit labels")
    func mixedImplicitExplicitLabels() {
        let container = UIView()
        
        let headerLabel = UILabel()
        headerLabel.text = "User Profile"
        headerLabel.accessibilityTraits = .header
        headerLabel.isAccessibilityElement = true
        container.addSubview(headerLabel)
        
        let nameLabel = UILabel()
        nameLabel.text = "Name:"
        nameLabel.isAccessibilityElement = true
        container.addSubview(nameLabel)
        
        let nameField = UITextField()
        nameField.placeholder = "Enter your name"
        nameField.text = "John Doe"
        nameField.isAccessibilityElement = true
        container.addSubview(nameField)
        
        let emailLabel = UILabel()
        emailLabel.text = "Email:"
        emailLabel.isAccessibilityElement = true
        container.addSubview(emailLabel)
        
        let emailField = UITextField()
        emailField.placeholder = "Enter your email"
        emailField.text = "john@example.com"
        emailField.accessibilityLabel = "Email address input"
        emailField.isAccessibilityElement = true
        container.addSubview(emailField)
        
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("Save Profile", for: .normal)
        saveButton.isAccessibilityElement = true
        container.addSubview(saveButton)
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.accessibilityLabel = "Cancel and go back"
        cancelButton.isAccessibilityElement = true
        container.addSubview(cancelButton)
        
        #expect(container.getByLabelText(.exactMatch("User Profile")).resolvedView === headerLabel)
        #expect(container.getByLabelText(.exactMatch("Name:")).resolvedView === nameLabel)
        #expect(container.getByLabelText(.contains("Enter your name")).resolvedView === nameField)
        #expect(container.getByLabelText(.exactMatch("Email address input")).resolvedView === emailField)
        #expect(container.getByLabelText(.exactMatch("Save Profile")).resolvedView === saveButton)
        #expect(container.getByLabelText(.exactMatch("Cancel and go back")).resolvedView === cancelButton)
        
        let cancelByTitle = container.queryBy(.label(.exactMatch("Cancel")))
        #expect(cancelByTitle.resolvedView == nil, "Should not find by title when explicit label exists")
    }

    @Test("UIActivityIndicatorView implicit accessibility")
    func activityIndicatorAccessibility() {
        let container = UIView()

        // Animating indicator
        let spinner1 = UIActivityIndicatorView(style: .medium)
        spinner1.startAnimating()
        spinner1.isAccessibilityElement = true
        container.addSubview(spinner1)

        // Stopped indicator
        let spinner2 = UIActivityIndicatorView(style: .large)
        spinner2.stopAnimating()
        spinner2.isAccessibilityElement = true
        container.addSubview(spinner2)

        // Find animating spinner by implicit label
        let animatingResult = container.queryBy(.label(.exactMatch("In progress")))
        #expect(animatingResult.resolvedView === spinner1, "Should find animating spinner by implicit label")

        // Find by value
        let animatingByValue = container.queryBy(.value(.exactMatch("animating")))
        #expect(animatingByValue.resolvedView === spinner1, "Should find animating spinner by value")

        // Stopped spinner shouldn't have implicit label
        let stoppedResult = container.queryBy(.label(.exactMatch("In progress")))
        #expect(stoppedResult.resolvedView !== spinner2, "Stopped spinner shouldn't have 'In progress' label")

        // With explicit label
        let spinner3 = UIActivityIndicatorView(style: .medium)
        spinner3.startAnimating()
        spinner3.accessibilityLabel = "Loading data"
        spinner3.isAccessibilityElement = true
        container.addSubview(spinner3)

        let explicitResult = container.queryBy(.label(.exactMatch("Loading data")))
        #expect(explicitResult.resolvedView === spinner3, "Explicit label should override implicit")
    }

    @Test("UISearchTextField implicit accessibility")
    func searchTextFieldAccessibility() {
        let container = UIView()

        // Search field with placeholder
        let searchField1 = UISearchTextField()
        searchField1.placeholder = "Search products"
        searchField1.isAccessibilityElement = true
        container.addSubview(searchField1)

        // Find by implicit label (placeholder)
        let placeholderResult = container.queryBy(.label(.contains("Search products")))
        #expect(placeholderResult.resolvedView === searchField1, "Should find search field by placeholder")

        // Search field with text
        let searchField2 = UISearchTextField()
        searchField2.placeholder = "Search users"
        searchField2.text = "John"
        searchField2.isAccessibilityElement = true
        container.addSubview(searchField2)

        // Should still find by placeholder as label
        let labelResult = container.queryBy(.label(.contains("Search users")))
        #expect(labelResult.resolvedView === searchField2, "Should find by placeholder even with text")

        // Should find by text as value
        let valueResult = container.queryBy(.value(.exactMatch("John")))
        #expect(valueResult.resolvedView === searchField2, "Should find by text as value")

        // With explicit label
        let searchField3 = UISearchTextField()
        searchField3.placeholder = "Type here"
        searchField3.accessibilityLabel = "Main search"
        searchField3.isAccessibilityElement = true
        container.addSubview(searchField3)

        let explicitResult = container.queryBy(.label(.exactMatch("Main search")))
        #expect(explicitResult.resolvedView === searchField3, "Explicit label should override placeholder")
    }

    @Test("UISlider accessibility is already supported")
    func sliderAccessibilityVerification() {
        let container = UIView()

        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 10
        slider.value = 7.5
        slider.accessibilityLabel = "Rating"
        slider.isAccessibilityElement = true
        container.addSubview(slider)

        // Find by label and value
        let result = container.queryBy(.label(.exactMatch("Rating")).and(.value(.exactMatch("7.5"))))
        #expect(result.resolvedView === slider, "Should find slider by label and value")
    }

    @Test("UIStepper accessibility is already supported")
    func stepperAccessibilityVerification() {
        let container = UIView()

        let stepper = UIStepper()
        stepper.minimumValue = 1
        stepper.maximumValue = 99
        stepper.value = 42
        stepper.accessibilityLabel = "Quantity selector"
        stepper.isAccessibilityElement = true
        container.addSubview(stepper)

        // Find by label and value
        let result = container.queryBy(.label(.exactMatch("Quantity selector")).and(.value(.exactMatch("42.0"))))
        #expect(result.resolvedView === stepper, "Should find stepper by label and value")
    }

    @Test("Mixed controls with various implicit values")
    func mixedControlsAccessibility() {
        let container = UIView()

        // Activity indicator
        let spinner = UIActivityIndicatorView()
        spinner.startAnimating()
        spinner.accessibilityLabel = "Processing"
        spinner.isAccessibilityElement = true
        container.addSubview(spinner)

        // Search field
        let searchField = UISearchTextField()
        searchField.placeholder = "Search here"
        searchField.text = "query text"
        searchField.isAccessibilityElement = true
        container.addSubview(searchField)

        // Slider
        let slider = UISlider()
        slider.value = 0.5
        slider.accessibilityLabel = "Progress"
        slider.isAccessibilityElement = true
        container.addSubview(slider)

        // Find each by their characteristics
        let spinnerResult = container.queryBy(.label(.exactMatch("Processing")).and(.value(.exactMatch("animating"))))
        #expect(spinnerResult.resolvedView === spinner)

        let searchResult = container.queryBy(.label(.contains("Search")).and(.value(.exactMatch("query text"))))
        #expect(searchResult.resolvedView === searchField)

        let sliderResult = container.queryBy(.label(.exactMatch("Progress")).and(.value(.exactMatch("0.5"))))
        #expect(sliderResult.resolvedView === slider)
    }
}
