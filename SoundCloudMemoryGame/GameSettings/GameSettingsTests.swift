
@testable import SoundCloudMemoryGame

import Foundation
import Quick
import Nimble
import SwiftyJSON

class GameSettingsTests: QuickSpec {
    override func spec() {
        describe("GameSettings") {

            struct TestSettings: GameSettings {
                let supportedGrids: [Grid] = [
                    (columns: 2, rows: 2),
                    (columns: 2, rows: 3)
                ]
            }
            
            it("should return correct games based on supported grids") {
                let correctGames: Games = [
                    4: (columns: 2, rows: 2),
                    6: (columns: 2, rows: 3)
                ]
                
                expect(TestSettings().availableGames == correctGames).to(beTrue())
            }
        }
    }
}

/// Custom compare function for tests
extension Dictionary where Key == CardCount, Value == Grid {
    
    static func == (l: Dictionary<Key,Value>, r: Dictionary<Key,Value>) -> Bool {
        if l.count != r.count {
            return false
        }
        return l.keys.reduce(true) { result, key -> Bool in
            guard
                let lValue = l[key],
                let rValue = r[key]
                else {
                    return false
            }
            
            return result && (lValue == rValue)
        }
    }
}
