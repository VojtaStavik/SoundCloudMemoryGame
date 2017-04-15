
@testable import SoundCloudMemoryGame

import Foundation
import Quick
import Nimble
import SwiftyJSON

class GameVMTests: QuickSpec {
    override func spec() {
        
        // MARK: --=== GameVM ==---

        describe("GameVM") {
            
            var vm: GameVM!
            
            let imageStore: ImageStore = [
                "1": UIImage(),
                "2": UIImage(),
                "3": UIImage(),
            ]
            
            struct TestGameSettings: GameSettings {
                let supportedGrids: [Grid] = [(collums: 2, rows: 3)]
            }
            
            beforeEach {
                vm = GameVM(imageStore: imageStore, gameSettings: TestGameSettings())
            }
            
            it("should prepare gamePlan according to game settings") {
                expect(vm.gamePlan.count) == 3
                expect(vm.gamePlan[0].count) == 2
                expect(vm.gamePlan[1].count) == 2
                expect(vm.gamePlan[2].count) == 2
            }
            
            it("should have all cards in the regular state") {
                vm.gamePlan.forEach { (row) in
                    row.forEach { card in
                        expect(card.state.value) == Card.State.regular
                    }
                }
            }
            
            describe("flipCard") {
                beforeEach {
                    vm.flipCard(row: 2, collum: 1)
                }
                
                it("should flip the proper card") {
                    expect(vm.gamePlan[2][1].isFlipped) == true
                }
            }
        }

        
        // MARK: --=== Game logic ==---

        describe("GameVM (game logic)") {
            
            var vm: GameVM!
            
            let imageStore: ImageStore = [:]
            
            struct TestGameSettings: GameSettings {
                let supportedGrids: [Grid] = [(collums: 0, rows: 0)]
            }
            
            beforeEach {
                vm = GameVM(imageStore: imageStore, gameSettings: TestGameSettings())
                
                // We inject artificial gamePlan to VM so we have full control
                vm.gamePlan = [
                    [Card(id: "X", image: UIImage()), Card(id: "X", image: UIImage())],
                    [Card(id: "Y", image: UIImage()), Card(id: "Y", image: UIImage())]
                ]
            }
            
            it("should have gameState regular") {
                expect(vm.state) == GameVM.GameState.regular
            }

            
            
            // Not match
            
            context("when first card is selected") {
                beforeEach {
                    vm.flipCard(row: 0, collum: 0)
                }
                
                it("should update game state to moveInProgress") {
                    expect(vm.state) == GameVM.GameState.moveInProgress(previous: vm.gamePlan[0][0])
                }
                
                context("and not matching card is selected") {
                    beforeEach {
                        vm.flipCard(row: 1, collum: 0)
                    }
                    
                    it("should update game state to resolving") {
                        expect(vm.state).toEventually(equal(GameVM.GameState.resolving))
                    }

                    it("should eventually update game state to regular") {
                        expect(vm.state).toEventually(equal(GameVM.GameState.regular))
                    }
                    
                    it("should eventually reset both card to regular state") {
                        expect(vm.gamePlan[0][0].isFlipped).toEventually(beFalse())
                        expect(vm.gamePlan[1][0].isFlipped).toEventually(beFalse())
                    }
                }
            }

        
            // Match (1.round)
            
            context("when first card is selected") {
                
                // Gameplan:
                //  X   X
                //  Y   Y
                
                beforeEach {
                    vm.flipCard(row: 0, collum: 0)
                }
                
                context("and matching card is selected") {
                    
                    var card1AnimationDuration: TimeInterval?
                    var card2AnimationDuration: TimeInterval?
                    
                    beforeEach {
                        // Setup animation closures
                        vm.gamePlan[0][0].animateMatch = { card1AnimationDuration = $0 }
                        vm.gamePlan[0][1].animateMatch = { card2AnimationDuration = $0 }
                        
                        // Flip the card
                        vm.flipCard(row: 0, collum: 1)
                    }
                    
                    it("should update game state to resolving") {
                        expect(vm.state).toEventually(equal(GameVM.GameState.resolving))
                    }
                    
                    it("shoud call matchAnimation closure on both cards with correct duration") {
                        expect(card1AnimationDuration).toEventually(equal(vm.matchDelay))
                        expect(card2AnimationDuration).toEventually(equal(vm.matchDelay))
                    }
                    
                    it("should eventually update game state to regular") {
                        expect(vm.state).toEventually(equal(GameVM.GameState.regular))
                    }
                    
                    it("should keep both card in flipped state") {
                        expect(vm.gamePlan[0][0].isFlipped).toNotEventually(beFalse())
                        expect(vm.gamePlan[0][1].isFlipped).toNotEventually(beFalse())
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
                    vm.gamePlan[0][0].flip()
                    vm.gamePlan[0][1].flip()
                    
                    // Flip first card
                    vm.flipCard(row: 1, collum: 0)
                }
                
                context("and matching card is selected") {
                    beforeEach {
                        vm.flipCard(row: 1, collum: 1)
                    }
                    
                    it("should update game state to resolving") {
                        expect(vm.state).toEventually(equal(GameVM.GameState.resolving))
                    }
                    
                    it("should eventually update game state to finished") {
                        expect(vm.state).toEventually(equal(GameVM.GameState.finished))
                    }
                    
                    it("should keep both card in flipped state") {
                        expect(vm.gamePlan[1][0].isFlipped).toNotEventually(beFalse())
                        expect(vm.gamePlan[1][1].isFlipped).toNotEventually(beFalse())
                    }
                }
            }

        }

    }
}
