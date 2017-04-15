
import Foundation
import ReactiveSwift

class GameSetupVM {
    
    // MARK: --=== Public ==---
    
    public enum State {
        case `default`
        case loadingImages
        case error(Error)
        case imagesReady(ImageStore)
    }
    
    /// Indicates the state of the VM
    public lazy var state: Property<State> = Property(capturing: self._state)

    func prepareGame(with numberOfCards: Int) {
        guard state.value != .loadingImages else {
            return
        }
        
        _state.value = .loadingImages
        
        api.fetchImageURLsAndPrepareImageStore(count: numberOfCards)
            .startWithResult { [weak self] (result) in
                switch result {
                case let .success(imageStore):
                    self?._state.value = .imagesReady(imageStore)
                    
                case let .failure(error):
                    self?._state.value = .error(error)
                }
            }
    }

    init(api: API) {
        self.api = api
    }
    
    // MARK: --=== Private ==---

    fileprivate let api: API

    /// Private mutable version of the state property
    fileprivate let _state = MutableProperty(State.default)
    

    
}

// Enums with associated values are not yet equatable by default.
// see https://github.com/apple/swift-evolution/blob/master/proposals/0143-conditional-conformances.md
extension GameSetupVM.State: Equatable {
    static func == (l: GameSetupVM.State, r: GameSetupVM.State) -> Bool {
        switch (l, r) {
        case (.`default`, .`default`),
             (.loadingImages, .loadingImages):
            return true
            
        case let (.error(lError), .error(rError)):
            return lError == rError
            
        case let (.imagesReady(lStore), .imagesReady(rStore)):
            return lStore == rStore
            
        default:
            return false
        }
    }
}
