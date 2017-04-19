
@testable import SoundCloudMemoryGame

import Foundation
import Quick
import Nimble
import SwiftyJSON

class GameVMTests: QuickSpec {
    override func spec() {

        describe("GameVM") {
            
            var vm: GameVM!
            
            var game: GameMock!
            
            beforeEach {
                game = GameMock(imageStore: ["1": self.mockImage1, "2": self.mockImage2], grid: (columns: 2, rows: 2))
                game.mockGamePlan = [
                    [Card(id: "1", image: self.mockImage1), Card(id: "1", image: self.mockImage1)],
                    [Card(id: "2", image: self.mockImage2), Card(id: "2", image: self.mockImage2)],
                ]

                vm = GameVM(game: game)
            }
            
            it("should return correct number of rows") {
                expect(vm.numberOfRows) == 2
            }

            it("should return correct number of columns") {
                expect(vm.numberOfColumns) == 2
            }
            
            describe("flipCard") {
                
                beforeEach {
                    vm.flipCard(row: 1, column: 1)
                }
                
                it("should call Game flipCard with correct index") {
                    expect(game.flippedCardCalledWithIndex?.row) == 1
                    expect(game.flippedCardCalledWithIndex?.column) == 1
                }
            }

            describe("cardView") {
                
                var cardView: CardView!
                
                beforeEach {
                    cardView = vm.cardView(at: 1, column: 1)
                }
                
                it("should have correct image") {
                    expect(cardView.image) == self.mockImage2
                }
                
                context("when its corresponding card is flipped") {
                    
                    beforeEach {
                        game.mockGamePlan[1][1].flip()
                    }
                    
                    it("should flip") {
                        expect(cardView.isFlipped) == true
                    }
                }
            }
            
            context("when the game is finished") {
                
                var finishedWasCalled = false
                
                beforeEach {
                    vm.gameFinishedClosure = {
                        finishedWasCalled = true
                    }
                    
                    game.mockState.value = .finished
                }
                
                it("should call gameFinishedClosure") {
                    expect(finishedWasCalled) == true
                }
                
            }
        }
    }
    
    lazy var mockImage1: UIImage = {
        return UIImage(named: "ringo.jpg", in: Bundle(for: type(of: self)), compatibleWith: nil)!
    }()
    
    lazy var mockImage2: UIImage = {
        return UIImage(named: "paul.jpg", in: Bundle(for: type(of: self)), compatibleWith: nil)!
    }()
}
