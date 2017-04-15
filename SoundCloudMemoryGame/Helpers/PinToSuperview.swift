
import UIKit

extension UIView {
    func pinToSuperview() {
        guard let superview = superview else {
            fatalError("View has no superview")
        }
        
        superview.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        superview.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        superview.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        superview.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
}
