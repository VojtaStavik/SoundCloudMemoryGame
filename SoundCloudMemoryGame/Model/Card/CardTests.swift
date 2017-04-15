
@testable import SoundCloudMemoryGame

import Foundation
import Quick
import Nimble
import SwiftyJSON

class CardTests: QuickSpec {
    override func spec() {
        
        describe("Card") {
            
            var card: Card!
            
            beforeEach {
                card = Card(id: "first", image: self.mockImage1)
            }
            
            it("should have regular state") {
                expect(card.state.value) == Card.State.regular
            }
            
            describe("flip") {
                
                beforeEach {
                    card.flip()
                }
                
                it("should flip the card") {
                    expect(card.isFlipped) == true
                }
                
                
                describe("reset") {
                    
                    beforeEach {
                        card.reset()
                    }
                    
                    it("should reset the card to regular") {
                        expect(card.isFlipped) == false
                    }
                }
                
            }
        }
    }
    
    lazy var mockImage1: UIImage = {
        return UIImage(named: "ringo.jpg", in: Bundle(for: type(of: self)), compatibleWith: nil)!
    }()
}
