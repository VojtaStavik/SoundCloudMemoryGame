
import UIKit

struct InfoPListKey {
    static let scApiClientID = "SCAPIClientID"
}

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var mainAppFlow: MainAppFlow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // SoundCloudAPI client ID
        guard let clientID = Bundle.main.infoDictionary?[InfoPListKey.scApiClientID] as? ClientID else {
            fatalError("Missing string value for \(InfoPListKey.scApiClientID) in the info.plist file.")
        }
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        mainAppFlow = MainAppFlow(window: window, apiClientID: clientID)
        self.window = window
        
        window.makeKeyAndVisible()
        
        return true
    }
}
