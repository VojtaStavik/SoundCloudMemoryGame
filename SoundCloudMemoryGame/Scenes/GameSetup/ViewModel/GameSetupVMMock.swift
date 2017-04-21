
@testable import SoundCloudMemoryGame

import Foundation
import RxSwift

class GameSetupVMMock: GameSetupVM {
    
    convenience init() {
        self.init(api: APIMock())
    }
    
    override var state: Variable<GameSetupVM.State> {
        get { return mockState }
    }
    
    let mockState: Variable<State> = Variable(.default)
    
    var prepareGameCalledWithNumber: Int?
    
    override func prepareGame(with numberOfCards: Int) {
        prepareGameCalledWithNumber = numberOfCards
    }
}
