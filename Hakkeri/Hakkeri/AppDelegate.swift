import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func setDefaultSettings() {
        let appDefaults = [
            "reader_mode": true,
            "dark_mode": false,
            "dank_mode": false
        ]
        UserDefaults.standard.register(defaults: appDefaults)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let articlesViewController = ArticlesViewController()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = articlesViewController
        self.window?.makeKeyAndVisible()
        self.window?.backgroundColor = Colors.current.background

        setDefaultSettings()
        FirebaseApp.configure()
        
        return true
    }
}
