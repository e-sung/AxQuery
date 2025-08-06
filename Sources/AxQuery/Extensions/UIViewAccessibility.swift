import UIKit

extension UIView {
    /// Returns the effective accessibility label for a view.
    /// This includes implicit labels from common UIKit controls.
    var effectiveAccessibilityLabel: String? {
        // If there's an explicit accessibility label, use it
        if let explicitLabel = accessibilityLabel, !explicitLabel.isEmpty {
            return explicitLabel
        }
        
        // Otherwise, check for implicit labels based on view type
        switch self {
        case let label as UILabel:
            return label.text
            
        case let button as UIButton:
            // Check for normal state title first
            if let title = button.title(for: .normal), !title.isEmpty {
                return title
            }
            // Check attributed title
            if let attributedTitle = button.attributedTitle(for: .normal) {
                return attributedTitle.string
            }
            return nil
            
        case let textField as UITextField:
            // For text fields, use placeholder as implicit label
            // (text content is treated as value, not label)
            return textField.placeholder
            
        case let textView as UITextView:
            // For text views, only use short text as implicit label
            if let text = textView.text, !text.isEmpty && text.count <= 50 {
                return text
            }
            return nil
            
        case let activityIndicator as UIActivityIndicatorView:
            // Activity indicators have implicit label based on their state
            if activityIndicator.isAnimating {
                return "In progress"
            }
            return nil
            
        case let searchField as UISearchTextField:
            // Search fields use placeholder as implicit label like regular text fields
            return searchField.placeholder
            
        default:
            return nil
        }
    }
    
    /// Returns the effective accessibility value for a view.
    var effectiveAccessibilityValue: String? {
        // If there's an explicit accessibility value, use it
        if let explicitValue = accessibilityValue, !explicitValue.isEmpty {
            return explicitValue
        }
        
        // Check for implicit values based on view type
        switch self {
        case let textField as UITextField:
            return textField.text
            
        case let textView as UITextView:
            // For long text views, the text is the value
            if let text = textView.text, !text.isEmpty && text.count > 50 {
                return text
            }
            return nil
            
        case let slider as UISlider:
            return String(slider.value)
            
        case let stepper as UIStepper:
            return String(stepper.value)
            
        case let progressView as UIProgressView:
            return String(progressView.progress)
            
        case let datePicker as UIDatePicker:
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: datePicker.date)
            
        case let switchControl as UISwitch:
            // UISwitch has implicit accessibility value based on its state
            // VoiceOver reads this as "on" or "off" (localized)
            return switchControl.isOn ? "1" : "0"
            
        case let searchField as UISearchTextField:
            // Search field text is its value
            return searchField.text
            
        case let activityIndicator as UIActivityIndicatorView:
            // Activity indicator state as value
            return activityIndicator.isAnimating ? "animating" : "stopped"
            
        default:
            return nil
        }
    }
}
