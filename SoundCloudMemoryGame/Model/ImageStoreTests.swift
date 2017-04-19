
@testable import SoundCloudMemoryGame

import Foundation
import Quick
import Nimble
import SwiftyJSON

class ImageStoreTests: QuickSpec {
    override func spec() {
        
        describe("ImageStore") {
            
            var store: ImageStore!
            
            beforeEach {
                store = ["1": self.mockImage1]
            }
            
            describe("merge") {
                
                let anotherStore: ImageStore = ["2": self.mockImage2]
                
                beforeEach {
                    store = ImageStore.merge(left: store, right: anotherStore)
                }
                
                it("should merge both stores") {
                    expect(store.count) == 2
                    expect(store["1"]) == self.mockImage1
                    expect(store["2"]) == self.mockImage2
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
