
@testable import SoundCloudMemoryGame

import Foundation
import ReactiveSwift

class GameSetupVMMock: GameSetupVM {
    
    convenience init() {
        self.init(api: APIMock())
    }
    
    override var state: Property<GameSetupVM.State> {
        get { return Property(self.mockState) }
    }
    
    let mockState: MutableProperty<State> = MutableProperty(.default)
    
    var prepareGameCalledWithNumber: Int?
    
    override func prepareGame(with numberOfCards: Int) {
        prepareGameCalledWithNumber = numberOfCards
    }
}
