
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    lazy var api = SCAPI(gateway: SCGateway(session: URLSession(configuration: .default)))
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let a = api
            .getImagesURLs(count: 10)
            .flatMap(.concat, transform: api.downloadImages)
            .startWithResult { (result) in
                if case let .success(images) = result {
                    print(images)
                }
            }
        
        return true
    }
}
