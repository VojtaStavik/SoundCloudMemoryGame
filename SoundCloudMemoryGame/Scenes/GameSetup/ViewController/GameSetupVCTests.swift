
@testable import SoundCloudMemoryGame

import Foundation
import Quick
import Nimble
import SwiftyJSON

class GameSetupVCTests: QuickSpec {
    override func spec() {
        
        describe("GameSetupVC") {
            
            struct GameSettingsMock: GameSettings {
                let supportedGrids: [Grid] = [
                    (collumns: 2, rows: 4),
                    (collumns: 2, rows: 2),
                ]
            }
            
            var vm: GameSetupVMMock!
            var vc: GameSetupVC!
            
            beforeEach {
                vm = GameSetupVMMock()
                vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GameSetupVC") as! GameSetupVC
                
                vc.viewModel = vm
                vc.gameSettings = GameSettingsMock()
                
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

        
        describe("GameSetupVC") {
            
            context("when GameSettings has 2 supported games") {

                struct GameSettingsMock: GameSettings {
                    let supportedGrids: [Grid] = [
                        (collumns: 2, rows: 4),
                        (collumns: 2, rows: 2),
                        ]
                }
                
                var vm: GameSetupVMMock!
                var vc: GameSetupVC!
                
                beforeEach {
                    vm = GameSetupVMMock()
                    vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GameSetupVC") as! GameSetupVC
                    
                    vc.viewModel = vm
                    vc.gameSettings = GameSettingsMock()
                    
                    // prepare VC
                    vc.prepareForSnapshot()
                }
                
                it("should have valid snapshot") {
                    compareSnapshot(vc.view, recordReferenceSnapshot: false)
                }
            }

            context("when GameSettings has 4 supported games") {
                
                struct GameSettingsMock: GameSettings {
                    let supportedGrids: [Grid] = [
                        (collumns: 2, rows: 4),
                        (collumns: 2, rows: 2),
                        (collumns: 2, rows: 5),
                        (collumns: 2, rows: 6),
                        ]
                }
                
                var vm: GameSetupVMMock!
                var vc: GameSetupVC!
                
                beforeEach {
                    vm = GameSetupVMMock()
                    vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GameSetupVC") as! GameSetupVC
                    
                    vc.viewModel = vm
                    vc.gameSettings = GameSettingsMock()
                    
                    vc.prepareForSnapshot()
                }
                
                it("should have valid snapshot") {
                    compareSnapshot(vc.view, recordReferenceSnapshot: false)
                }
            }

        }
    }
}
