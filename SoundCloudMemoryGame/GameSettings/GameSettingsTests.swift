
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
                    (collums: 2, rows: 2),
                    (collums: 2, rows: 3)
                ]
            }
            
            it("should return correct games based on supported grids") {
                let correctGames: Games = [
                    4: (collums: 2, rows: 2),
                    6: (collums: 2, rows: 3)
                ]
                
                expect(TestSettings().availableGames == correctGames).to(beTrue())
            }
        }
    }
}
