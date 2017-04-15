
import UIKit

extension UIButton {
    static func createChooseCountButton(`for` count: Int) -> UIButton {
        let button = UIButton(type: .system)
        
        button.setTitle("\(count)", for: .normal)
        button.backgroundColor = Color.brand
        button.setTitleColor(Color.darkForeground, for: .normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }
}
