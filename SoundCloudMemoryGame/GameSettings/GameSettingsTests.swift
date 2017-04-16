
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
                    (collumns: 2, rows: 2),
                    (collumns: 2, rows: 3)
                ]
            }
            
            it("should return correct games based on supported grids") {
                let correctGames: Games = [
                    4: (collumns: 2, rows: 2),
                    6: (collumns: 2, rows: 3)
                ]
                
                expect(TestSettings().availableGames == correctGames).to(beTrue())
            }
        }
    }
}
