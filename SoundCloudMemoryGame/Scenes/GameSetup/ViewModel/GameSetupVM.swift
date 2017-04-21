
import Foundation
import RxSwift
import UIKit.UIImage

class GameSetupVM {
    
    // MARK: --=== Public ==---
    
    public enum State {
        case `default`
        case loadingImages
        case error(Error)
        case imagesReady(ImageStore)
    }
    
    /// Indicates the state of the VM
    private(set) lazy var state: Variable<State> = Variable(.default)

    func prepareGame(with numberOfCards: Int) {
        if numberOfCards % 2 != 0 {
            fatalError("Number of cards has to be an even number. Got \(numberOfCards).")
        }
        
        guard state.value != .loadingImages else {
            return
        }
        
        state.value = .loadingImages
        
        api.fetchImageURLsAndPrepareImageStore(count: numberOfCards / 2)
            .asObservable()
            .subscribe(onNext: { [weak self] (imageStore) in
                self?.state.value = .imagesReady(imageStore)
                
            }, onError: { [weak self] (rawError) in
                guard let error = rawError as? Error else {
                    print("Unhandled error: \(rawError)")
                    return
                }
                self?.state.value = .error(error)
                
            }).disposed(by: disposeBag)
    }

    /// Call this function to reset the state of the VM to the intial value
    func reset() {
        state.value = .default
        disposeBag = nil
    }
    
    init(api: API) {
        self.api = api
    }
    
    // MARK: --=== Private ==---

    fileprivate let api: API
    
    fileprivate lazy var disposeBag: DisposeBag! = DisposeBag()
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
