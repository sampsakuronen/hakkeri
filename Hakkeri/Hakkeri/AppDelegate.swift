import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FIRApp.configure()
        FIRAnalytics.logEvent(withName: kFIREventAppOpen, parameters: nil)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = StoryTableViewController()
        self.window?.makeKeyAndVisible()
        self.window?.backgroundColor = .white
        
        return true
    }

}
