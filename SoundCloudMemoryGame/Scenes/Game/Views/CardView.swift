
import UIKit

class CardView: UIView {
    
    // MARK: --=== Public ==---

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
    
    private(set) var image: UIImage!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    func animateMatch() {
        UIView.animate(withDuration: AnimationTime.match/2.0,
                       delay: 0,
                       options: [.beginFromCurrentState],
                       animations:
            {
                self.transform = CGAffineTransform(scaleX: Animation.matchAnimationScale,
                                                       y: Animation.matchAnimationScale)
        }) { _ in
            
            UIView.animate(withDuration: AnimationTime.match/2.0,
                           delay: 0,
                           options: [.beginFromCurrentState],
                           animations:
                {
                    self.transform = CGAffineTransform.identity
            })
        }
    }

    var isFlipped: Bool {
        return backImageView.isHidden
    }
    
    // MARK: --=== Private ==---

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
