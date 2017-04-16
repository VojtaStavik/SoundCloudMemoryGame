
import UIKit

class CardView: UIView {
    
    convenience init(image: UIImage) {
        self.init(frame: .zero)
        self.image = image
        
        addSubview(faceImageView)
        faceImageView.pinToSuperview()
        faceImageView.isHidden = true
        
        addSubview(backImageView)
        backImageView.pinToSuperview()
        backImageView.isHidden = false
        
        backgroundColor = Color.background
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func transitionToLogo() {
        guard backImageView.isHidden else {
            return
        }
        
        UIView.transition(from: faceImageView,
                          to: backImageView,
                          duration: AnimationTime.unflip,
                          options: [.transitionFlipFromLeft, .showHideTransitionViews],
                          completion: nil)
    }
    
    func transitionToImage() {
        guard faceImageView.isHidden else {
            return
        }

        UIView.transition(from: backImageView,
                          to: faceImageView,
                          duration: AnimationTime.flip,
                          options: [.transitionFlipFromRight, .showHideTransitionViews],
                          completion: nil)
    }
    
    private var image: UIImage!
    
    private lazy var faceImageView: UIImageView = {
        let imageView = UIImageView(image: self.image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        return imageView
    }()

    
    private lazy var backImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "logo"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        return imageView
    }()
}
