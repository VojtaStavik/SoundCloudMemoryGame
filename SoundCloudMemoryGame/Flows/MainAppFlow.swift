
import UIKit
import ReactiveSwift

class MainAppFlow {
    
    private let window: UIWindow
    private let navigationController: UINavigationController
    
    private let gameSettings = SCGameSettings()
    
    init(window: UIWindow) {
        self.window = window
        navigationController = UINavigationController()
        
        window.rootViewController = navigationController
        
        let gameSetupVC = createGameSetupVC()
        navigationController.viewControllers = [gameSetupVC]
        setup(gameSetupVC: gameSetupVC)
        
        gameSetupVC.viewModel.state.producer
            .observe(on: UIScheduler())
            .startWithValues { [unowned self, unowned gameSetupVC] (state) in
                if case let .imagesReady(imageStore) = state {
                    self.showGameVC(imageStore: imageStore)
                }
            }
    }
    
    // Step 1 - GameSetupVC
    private func setup(gameSetupVC vc: GameSetupVC) {
        vc.viewModel = GameSetupVM(api: api)
        vc.gameSettings = gameSettings
    }
    
    // Step 2 - GameVC
    private func showGameVC(imageStore: ImageStore) {
        // Set cutom text for the back button
        let backItem = UIBarButtonItem()
        backItem.title = NSLocalizedString("Quit game", comment: "GameVC back button title")
        navigationController.viewControllers.first?.navigationItem.backBarButtonItem = backItem
        
        let vc = createGameVC()
        vc.viewModel = GameVM(imageStore: imageStore, gameSettings: gameSettings)
        navigationController.pushViewController(vc, animated: true)
    }

    private lazy var api: API = SCAPI(gateway: self.gateway)
    private lazy var gateway: Gateway = SCGateway(session: URLSession(configuration: .default))
}

extension MainAppFlow {
    func createGameSetupVC() -> GameSetupVC {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GameSetupVC") as! GameSetupVC
    }

    func createGameVC() -> GameVC {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GameVC") as! GameVC
    }
}
