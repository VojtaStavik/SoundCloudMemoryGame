
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var mainAppFlow: MainAppFlow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        mainAppFlow = MainAppFlow(window: window)
        self.window = window
        
        window.makeKeyAndVisible()
        
        return true
    }
}
