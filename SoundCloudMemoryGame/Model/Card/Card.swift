
import UIKit
import ReactiveSwift

// Card is in fact more a view model for CardView then a model itself.

class Card {
    
    lazy var state: Property<State> = Property(self._state)
    
    enum State {
        case regular
        case flipped
    }
    
    init(id: ImageID, image: UIImage) {
        self.image = image
        self.id = id
    }
    
    let image: UIImage
    let id: ImageID
    
    func flip() {
        if case .regular = state.value {
            _state.value = .flipped
        }
    }
    
    func reset() {
        if case .flipped = state.value {
            _state.value = .regular
        }
    }
    
    func match() {
        matchAnimationClosure?()
    }
    
    var matchAnimationClosure: (() -> Void)? = nil
    
    // MARK: --=== Private ==---
    
    fileprivate let _state: MutableProperty<State> = MutableProperty(.regular)
}

extension Card {
    var isFlipped: Bool {
        if case .flipped = state.value {
            return true
        } else {
            return false
        }
    }
}

extension Card {
    func  matches(_ otherCard: Card) -> Bool {
        return self.id == otherCard.id
    }
}
