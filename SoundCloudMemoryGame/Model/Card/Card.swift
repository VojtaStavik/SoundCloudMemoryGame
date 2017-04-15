
import UIKit
import ReactiveSwift

class Card {
    
    lazy var state: Property<State> = Property(self._state)
    
    enum State {
        case regular
        case flipped(id: ImageID, image: UIImage)
    }
    
    init(id: ImageID, image: UIImage) {
        self.image = image
        self.id = id
    }
    
    func flip() {
        if case .regular = state.value {
            _state.value = .flipped(id: self.id, image: self.image)
        }
    }
    
    func reset() {
        if case .flipped = state.value {
            _state.value = .regular
        }
    }
    
    var animateMatch: ((_ maxDuration: TimeInterval) -> Void)? = nil
    
    // MARK: --=== Private ==---
    
    fileprivate let _state: MutableProperty<State> = MutableProperty(.regular)
    
    fileprivate let image: UIImage
    fileprivate let id: ImageID
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

extension Card: Equatable {
    static func == (l: Card, r: Card) -> Bool {
        return l.id == r.id
    }
}

extension Card.State: Equatable {
    
    static func == (l: Card.State, r: Card.State) -> Bool {
        switch (l, r) {
        case (.regular, .regular):
            return true
            
        case let (.flipped(lImage), .flipped(rImage)):
            return lImage == rImage
            
        default:
            return false
        }
    }
}
