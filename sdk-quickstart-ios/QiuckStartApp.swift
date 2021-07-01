import SwiftUI

@main
struct QuickStartApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
