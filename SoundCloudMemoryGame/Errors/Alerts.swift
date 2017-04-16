
import UIKit

// Helper extensions for more convenient work with alerts
extension UIAlertController {
    
    static func showAlert(with title: String, message: String, from vc: UIViewController, completion: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
            completion?()
        }))
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func showAlert(`for` error: Error, from vc: UIViewController) {
        showAlert(with: "Oooops :/", message: error.localizedDescription, from: vc, completion: nil)
    }
}
