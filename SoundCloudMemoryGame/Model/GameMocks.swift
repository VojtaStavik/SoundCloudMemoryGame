
@testable import SoundCloudMemoryGame

import Foundation
import RxSwift

class GameMock: Game {
    
    convenience init() {
        self.init(imageStore: [:], grid: [0, 0])
    }
    
    override var gamePlan: [[Card]] {
        set {}
        get { return mockGamePlan }
    }
    
    var mockGamePlan: [[Card]] = []
    
    var flippedCardCalledWithIndex: (row: Int, column: Int)?
    override func flipCard(row: Int, column: Int) {
        flippedCardCalledWithIndex = (row, column)
    }
    
    override var state: Variable<State> {
        return mockState
    }
    
    var mockState: Variable<State> = Variable(.regular)
}
