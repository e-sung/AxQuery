import UIKit

// MARK: - Result Extensions for AxQueryError
extension Result where Failure == AxQueryError {
    /// Returns the resolved error if the result is a failure, nil otherwise
    public var resolvedError: AxQueryError? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}

extension Result where Success == UIView {
    /// Returns the resolved view if the result is successful, nil otherwise
    public var resolvedView: UIView? {
        switch self {
        case .success(let view):
            return view
        case .failure:
            return nil
        }
    }
}

extension Result where Success == UIView? {
    /// Returns the resolved view if the result is successful, nil otherwise
    public var resolvedView: UIView? {
        switch self {
        case .success(let view):
            return view
        case .failure:
            return nil
        }
    }
}

extension Result where Success == [UIView] {
    /// Returns the resolved views if the result is successful, nil otherwise
    public var resolvedViews: [UIView]? {
        switch self {
        case .success(let views):
            return views
        case .failure:
            return nil
        }
    }
}
