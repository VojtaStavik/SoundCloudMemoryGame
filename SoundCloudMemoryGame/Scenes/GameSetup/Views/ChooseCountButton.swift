
import UIKit

class ChooseCountButton: UIButton {
    
    let count: Int
    
    init(with count: Int) {
        self.count = count
        
        super.init(frame: CGRect.zero)
        
        setTitle("\(count)", for: .normal)
        backgroundColor = Color.brand
        setTitleColor(Color.darkForeground, for: .normal)
        setTitleColor(Color.darkForeground.withAlphaComponent(0.3), for: .highlighted)
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
