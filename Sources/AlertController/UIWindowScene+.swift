import UIKit

extension UIWindowScene {
    
    static var focused: UIWindowScene? {
        UIApplication.shared.connectedScenes
            .filter { $0 is UIWindowScene }
            .first {
                switch $0.activationState {
                case .foregroundActive, .foregroundInactive:
                    return true
                    
                default:
                    return false
                }
            } as? UIWindowScene
    }
    
}
