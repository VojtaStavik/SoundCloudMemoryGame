
import UIKit
import ReactiveSwift

class MainAppFlow {
    
    // MARK: --=== Public ==---
    
    init(window: UIWindow, apiClientID: API.ClientID) {
        self.apiClientID = apiClientID
        
        self.window = window
        navigationController = UINavigationController()
        
        window.rootViewController = navigationController
        
        let gameSetupVC = createGameSetupVC()
        navigationController.viewControllers = [gameSetupVC]
        setup(gameSetupVC: gameSetupVC)
        
        gameSetupVC.viewModel.state.producer
            .observe(on: UIScheduler())
            .startWithValues { [weak self] (state) in
                if case let .imagesReady(imageStore) = state {
                    self?.showGameVC(imageStore: imageStore)
                }
            }
    }
    
    // MARK: --=== Private ==---

    private let window: UIWindow
    private let navigationController: UINavigationController
    
    private let gameSettings = SCGameSettings()
    private let apiClientID: API.ClientID
    
    
    // Step 1 - GameSetupVC
    private func setup(gameSetupVC vc: GameSetupVC) {
        vc.viewModel = GameSetupVM(api: api)
        vc.gameSettings = gameSettings
    }
    
    // Step 2 - GameVC
    private func showGameVC(imageStore: ImageStore) {
        guard let grid = gameSettings.availableGames[imageStore.count * 2] else {
            fatalError("Can't find supported grid for \(imageStore.count) images.")
        }

        let vc = createGameVC()
        let game = Game(imageStore: imageStore, grid: grid)
        vc.viewModel = GameVM(game: game)

        navigationController.pushViewController(vc, animated: true)
    }

    private lazy var api: API = SCAPI(gateway: self.gateway, clientID: self.apiClientID)
    private lazy var gateway: Gateway = SCGateway(session: URLSession(configuration: .default))
}


extension MainAppFlow {
    
    fileprivate func createGameSetupVC() -> GameSetupVC {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GameSetupVC") as! GameSetupVC
    }

    fileprivate func createGameVC() -> GameVC {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GameVC") as! GameVC
    }
}
