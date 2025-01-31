import UIKit
import UniformTypeIdentifiers

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    var window: UIWindow?
    var appDelegate: AppDelegate? {
        (UIApplication.shared.delegate as? AppDelegate)
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.overrideUserInterfaceStyle = .light
            let rootVC = appDelegate?.rootVC
            window.rootViewController = rootVC
            window.backgroundColor = ColorScheme.current.background
            self.window = window
            window.makeKeyAndVisible()
        }
        
        appDelegate?.navigationRIB.interactable.activate()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        URLContexts.forEach {
            let url = $0.url
            if (UIApplication.shared.delegate as? AppDelegate)?.handlerUrl?.handle(url: url, options: $0.options, completion: { success in
            }) ?? false {
                return
            }

            // if url was not handled need to call activate
            if appDelegate?.navigationRIB.interactable.isActive == false {
                appDelegate?.navigationRIB.interactable.activate()
            }
        }
    }


    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if appDelegate?.navigationRIB.interactable.isActive == false {
            appDelegate?.navigationRIB.interactable.activate()
        }
    }
}
