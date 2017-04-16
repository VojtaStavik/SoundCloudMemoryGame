
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
    
    var flippedCardCalledWithIndex: (row: Int, collum: Int)?
    override func flipCard(row: Int, collum: Int) {
        flippedCardCalledWithIndex = (row, collum)
    }
}
