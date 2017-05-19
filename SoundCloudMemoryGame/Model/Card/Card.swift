
import UIKit.UIImage
import RxSwift

/// The Card class represents a card in the game plan.
class Card {
    
    // MARK: --=== Public ==---
    
    var state: Variable<State> = Variable(.regular)
    
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
        guard isFlipped == false else { return }
        state.value = .flipped
    }
    
    func reset() {
        guard isFlipped else { return }
        state.value = .regular
    }
    
    func match() {
        matchAnimationClosure?()
    }
    
    var matchAnimationClosure: (() -> Void)? = nil
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

extension Card: Equatable {
    static func ==(l: Card, r: Card) -> Bool {
        return l.id == r.id && l.image === r.image
    }
}
