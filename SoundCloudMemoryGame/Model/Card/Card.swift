
import UIKit.UIImage
import ReactiveSwift

/// The Card class represents a card in the game plan.
class Card {
    
    // MARK: --=== Public ==---
    
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
    
    deinit {
//        var mutableSelf = self
        print("Card deinit \(String(format: "%p", unsafeBitCast(self, to: Int.self)))")
    }
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
    func matches(_ otherCard: Card) -> Bool {
        return self.id == otherCard.id
    }
}
