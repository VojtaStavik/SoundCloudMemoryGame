
import UIKit

extension UIAlertController {
    static func showAlert(`for` error: Error, from viewController: UIViewController) {
        let alert = UIAlertController(title: "Ooops :/", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { [unowned alert] (_) in
            alert.dismiss(animated: true, completion: nil)
        }))
            
        viewController.present(alert, animated: true, completion: nil)
    }
}
