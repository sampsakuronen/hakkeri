import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let articlesViewController = ArticlesViewController()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = articlesViewController
        self.window?.makeKeyAndVisible()
        self.window?.backgroundColor = .white

        FirebaseApp.configure()
        
        return true
    }
}
