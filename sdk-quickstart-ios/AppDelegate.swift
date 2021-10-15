import Foundation
import UIKit
import NotarizeSigner

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let configuration = NotarizeSignerConfiguration(environment: .development)
        NotarizeSignerSDK.configure(config: configuration)
        return true
    }
}
