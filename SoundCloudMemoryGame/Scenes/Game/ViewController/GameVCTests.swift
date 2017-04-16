
@testable import SoundCloudMemoryGame

import Foundation
import Quick
import Nimble
import SwiftyJSON

class GameVCTests: QuickSpec {
    override func spec() {
        
        describe("GameVC") {
            
            var vm: GameVMMock!
            var vc: GameVC!
            
            describe("with 4 cards") {
                
                beforeEach {
                    vm = GameVMMock()
                    vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GameVC") as! GameVC
                    
                    vm.mockGamePlan = [
                        [Card(id: "1", image: self.mockImage1), Card(id: "1", image: self.mockImage1)],
                        [Card(id: "2", image: self.mockImage2), Card(id: "2", image: self.mockImage2)],
                    ]
                    
                    vc.viewModel = vm
                    vc.prepareForSnapshot()
                }
                
                it("should have valid snapshot") {
                    compareSnapshot(vc.view, recordReferenceSnapshot: false)
                }
                
                context("when 2 card are flipped") {
                    
                    beforeEach {
                        vm.mockGamePlan[0][0].flip()
                        vm.mockGamePlan[1][0].flip()
                    }
                    
                    it("should have valid snapshot") {
                        compareSnapshot(vc.view, recordReferenceSnapshot: false)
                    }
                }

                context("when all cards are flipped") {
                    
                    beforeEach {
                        vm.mockGamePlan[0][0].flip()
                        vm.mockGamePlan[1][0].flip()
                        vm.mockGamePlan[0][1].flip()
                        vm.mockGamePlan[1][1].flip()
                    }
                    
                    it("should have valid snapshot") {
                        compareSnapshot(vc.view, recordReferenceSnapshot: false)
                    }
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
