
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
                    [2, 2],
                    [2, 3]
                ]
            }
            
            it("should return correct games based on supported grids") {
                let correctGames: Games = [
                    4: [2, 2],
                    6: [2, 3],
                ]
                
                expect(TestSettings().availableGames == correctGames).to(beTrue())
            }
        }
    }
}

/// Custom compare function for tests
protocol CardCountKey { }
extension CardCount: CardCountKey { }

protocol GridValue: Equatable { }
extension Grid: GridValue {
    public static func ==(l: Grid, r: Grid) -> Bool {
        return l.columns == r.columns && l.rows == r.rows
    }
}

extension Dictionary where Key: CardCountKey, Value: GridValue {
    
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
