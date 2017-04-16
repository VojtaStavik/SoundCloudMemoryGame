
@testable import SoundCloudMemoryGame

import Foundation
import ReactiveSwift

class GameVMMock: GameVM {
    
    struct MockGameSettings: GameSettings {
        let supportedGrids: [Grid] = []
    }
    
    convenience init() {
        self.init(imageStore: [:], gameSettings: MockGameSettings())
    }
    
    override var gamePlan: [[Card]] {
        set {}
        get { return mockGamePlan }
    }
    
    var mockGamePlan: [[Card]] = []
    
    var flippedCardCalledWithIndex: (row: Int, collumn: Int)?
    override func flipCard(row: Int, collumn: Int) {
        flippedCardCalledWithIndex = (row, collumn)
    }
}
