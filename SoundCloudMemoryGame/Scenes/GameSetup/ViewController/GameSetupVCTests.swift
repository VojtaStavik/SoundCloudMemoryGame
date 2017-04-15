
@testable import SoundCloudMemoryGame

import Foundation
import Quick
import Nimble
import SwiftyJSON

class GameSetupVCTests: QuickSpec {
    override func spec() {
        
        describe("GameSetupVC") {
            
            struct GameSettingsMock: GameSettings {
                static let supportedGrids: [Grid] = [
                    (collums: 2, rows: 4),
                    (collums: 2, rows: 2),
                ]
            }
            
            var vm: GameSetupVMMock!
            var vc: GameSetupVC!
            
            beforeEach {
                vm = GameSetupVMMock()
                vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GameSetupVC") as! GameSetupVC
                
                vc.viewModel = vm
                vc.gameSettings = GameSettingsMock.self
                
                // load view
                _ = vc.view
            }
            
            it("should have loading indicator hidden") {
                expect(vc.isLoadingIndicatorVisible) == false
            }
            
            context("when VM state is loadingImages") {
                beforeEach {
                    vm.mockState.value = .loadingImages
                }
                
                it("should have loading indicator visible") {
                    expect(vc.isLoadingIndicatorVisible) == true
                }
                
                context("and then it's changed to something else") {
                    beforeEach {
                        vm.mockState.value = .default
                    }
                    
                    it("should hide the loading indicator") {
                        expect(vc.isLoadingIndicatorVisible) == false
                    }
                }
            }
            
            it("should prepare the choose count buttons based on the game settings") {
                let buttons = vc.buttonBar.arrangedSubviews as! [UIButton]
                
                expect(buttons.count) == 2
                expect(buttons[0].titleLabel!.text) == "4"
                expect(buttons[1].titleLabel!.text) == "8"
            }
            
            context("when a button is pressed") {
                beforeEach {
                    let buttons = vc.buttonBar.arrangedSubviews as! [UIButton]
                    vc.pressButtonAction(buttons[0])
                }
                
                it("should call VM's prepareGame with the correct count") {
                    expect(vm.prepareGameCalledWithNumber) == 4
                }
            }
        }
    }
}
