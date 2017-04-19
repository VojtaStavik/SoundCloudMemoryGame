
@testable import SoundCloudMemoryGame

import Foundation
import ReactiveSwift

class GameMock: Game {
    
    convenience init() {
        self.init(imageStore: [:], grid: (0, 0))
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
    
    override var state: Property<State> {
        return mockStateWrapper
    }
    
    private lazy var mockStateWrapper: Property<State> = Property(self.mockState)
    
    var mockState: MutableProperty<State> = MutableProperty(.regular)
}
