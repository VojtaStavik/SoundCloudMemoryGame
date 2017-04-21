
@testable import SoundCloudMemoryGame

import Foundation
import Quick
import Nimble
import SwiftyJSON

class GameSetupVMTests: QuickSpec {
    override func spec() {
        
        describe("GameSetupVM") {
            
            var vm: GameSetupVM!
            var api: APIMock!
            
            beforeEach {
                api = APIMock()
                vm = GameSetupVM(api: api)
            }
            
            it("should have default state when created") {
                expect(vm.state.value).to(equal(GameSetupVM.State.default))
            }
            
            
            describe("prepareGame") {
                
                context("when called with 4 cards") {
                    
                    beforeEach {
                        vm.prepareGame(with: 4)
                    }
                    
                    it("should change state to loadingImages") {
                        expect(vm.state.value).to(equal(GameSetupVM.State.loadingImages))
                    }
                    
                    it("should call API's fetchImageURLsAndPrepareImageStore with 2") {
                        expect(api.getImagesURLsCount).toEventually(equal(2))
                    }
                    
                    context("and called again before the first called is finished") {
                        beforeEach {
                            vm.prepareGame(with: 12)
                        }
                        
                        it("should ignore the second call") {
                            expect(api.getImagesURLsCount).toNotEventually(equal(12))
                        }
                    }
                    
                    context("with successfull response") {
                        beforeEach {
                            // Simulate successfull responses
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                api.getImagesURLObserver?.onNext([URL(string: "first://")!])
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                api.downloadImagesObserver?.onNext(["first://": self.mockImage1])
                            }
                        }
                        
                        it("should change state to imagesReady with the correct ImageStore") {
                            expect(vm.state.value).toEventually(equal(GameSetupVM.State.imagesReady(["first://": self.mockImage1])))
                        }
                    }

                    context("with fail response") {
                        beforeEach {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                // First response is OK
                                api.getImagesURLObserver?.onNext([URL(string: "first://")!])
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                // Second response fails
                                api.downloadImagesObserver?.onError(SoundCloudMemoryGame.Error.api(.cantDownloadImages))
                            }
                        }
                        
                        it("should change state to error with the correct Error value") {
                            expect(vm.state.value).toEventually(equal(GameSetupVM.State.error(.api(.cantDownloadImages))))
                        }
                    }

                }
                
            }
        }
    }

    lazy var mockImage1: UIImage = {
        return UIImage(named: "ringo.jpg", in: Bundle(for: type(of: self)), compatibleWith: nil)!
    }()
}
