
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    lazy var api = SCAPI(gateway: SCGateway(session: URLSession(configuration: .default)))
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let navVC: UINavigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        
        let vc: GameSetupVC = navVC.viewControllers.first as! GameSetupVC
        vc.gameSettings = SCGameSettings.self
        vc.viewModel = GameSetupVM(api: api)
        
        self.window?.rootViewController = navVC
        self.window?.makeKeyAndVisible()
        
        return true
    }
}
