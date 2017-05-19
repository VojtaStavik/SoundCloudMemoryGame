
@testable import SoundCloudMemoryGame

import Foundation
import Quick
import Nimble
import SwiftyJSON

class GameTests: QuickSpec {
    override func spec() {
        
        // MARK: --=== Game (basic functionality) ==---
        
        fdescribe("Game for 2 cards") {
            
            var game: Game!
            
            let imageStore: ImageStore = [
                "1": UIImage(),
                "2": UIImage(),
                "3": UIImage(),
                ]
            
            let grid: Grid = [2, 3]
            
            beforeEach {
                game = Game(imageStore: imageStore, grid: grid, numberOfMatches: 2)
            }
            
            it("should prepare gamePlan according to game settings") {
                expect(game.gamePlan.count) == 3
                expect(game.gamePlan[0].count) == 2
                expect(game.gamePlan[1].count) == 2
                expect(game.gamePlan[2].count) == 2
            }
            
            it("should have all cards in the regular state") {
                game.gamePlan.forEach { (row) in
                    row.forEach { card in
                        expect(card.state.value) == Card.State.regular
                    }
                }
            }
            
            describe("flipCard") {
                
                beforeEach {
                    game.flipCard(row: 2, column: 1)
                }
                
                it("should flip the proper card") {
                    expect(game.gamePlan[2][1].isFlipped) == true
                }
            }
        }
        
        
        // MARK: --=== Game logic ==---
        
        fdescribe("Game (game logic)") {
            
            var game: Game!
            
            let imageStore: ImageStore = [:]
            
            let grid: Grid = [0, 0]
            
            beforeEach {
                game = Game(imageStore: imageStore, grid: grid, numberOfMatches: 2)

                // We inject artificial gamePlan so we have full control
                game.gamePlan = [
                    [Card(id: "X", image: UIImage()), Card(id: "X", image: UIImage())],
                    [Card(id: "Y", image: UIImage()), Card(id: "Y", image: UIImage())]
                ]
            }
            
            it("should have State regular") {
                expect(game.state.value) == Game.State.regular
            }
            
            
            
            // Not match
            
            context("when first card is selected") {
                
                beforeEach {
                    game.flipCard(row: 0, column: 0)
                }
                
                it("should update game state to moveInProgress") {
                    expect(game.state.value) == Game.State.moveInProgress(previous: [game.gamePlan[0][0]])
                }
                
                context("and not matching card is selected") {
                    
                    beforeEach {
                        game.flipCard(row: 1, column: 0)
                    }
                    
                    it("should eventually update game state to regular") {
                        expect(game.state.value).toEventually(equal(Game.State.regular))
                    }
                    
                    it("should eventually reset both card to regular state") {
                        expect(game.gamePlan[0][0].isFlipped).toEventually(beFalse())
                        expect(game.gamePlan[1][0].isFlipped).toEventually(beFalse())
                    }
                }
            }
            
            
            // Match (1.round)
            
            context("when first card is selected") {
                
                // Gameplan:
                //  X   X
                //  Y   Y
                
                beforeEach {
                    game.flipCard(row: 0, column: 0)
                }
                
                context("and matching card is selected") {
                    
                    beforeEach {
                        // Flip the card
                        game.flipCard(row: 0, column: 1)
                    }
                    
                    it("should eventually update game state to regular") {
                        expect(game.state.value).toEventually(equal(Game.State.regular))
                    }
                    
                    it("should keep both card in flipped state") {
                        expect(game.gamePlan[0][0].isFlipped).toNotEventually(beFalse())
                        expect(game.gamePlan[0][1].isFlipped).toNotEventually(beFalse())
                    }
                }
            }
            
            
            // Match (2.round)
            
            context("when card is selected") {
                
                // Gameplan:
                //  X(f)   X(f)
                //  Y      Y
                
                beforeEach {
                    // Simulate flipped cards
                    game.gamePlan[0][0].flip()
                    game.gamePlan[0][1].flip()
                    
                    // Flip first card
                    game.flipCard(row: 1, column: 0)
                }
                
                context("and matching card is selected") {
                    
                    beforeEach {
                        game.flipCard(row: 1, column: 1)
                    }
                    
                    it("should eventually update game state to finished") {
                        expect(game.state.value).toEventually(equal(Game.State.finished))
                    }
                    
                    it("should keep both card in flipped state") {
                        expect(game.gamePlan[1][0].isFlipped).toNotEventually(beFalse())
                        expect(game.gamePlan[1][1].isFlipped).toNotEventually(beFalse())
                    }
                }
            }
            
        }
    }
}
