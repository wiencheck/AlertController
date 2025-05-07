import UIKit

@available(iOS 13.0, *)
extension UIWindowScene {
    
    static var focused: UIWindowScene? {
        UIApplication.shared.connectedScenes
            .first { $0.activationState == .foregroundActive && $0 is UIWindowScene } as? UIWindowScene
    }
    
}
