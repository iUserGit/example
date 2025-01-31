import UIKit
import Kingfisher
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    private(set) var handlerUrl: UrlHandler?
    private(set) var navigationRIB: NavigationRouting!
    
    var rootVC: UIViewController {
        navigationRIB.viewControllable.uiviewController
    }
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        setupImageCache()
        setupRootViewController()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    // MARK: - Private -
    
    private func setupRootViewController() {
        let dataProvider = DataProvider(network: DefaultNetworkService(), apiKey: NetworkLayerData.apiKey)
        let dependency = NavigationDependencyImpl(dataProvider: dataProvider, favoriteModelProvider: FavoriteModelProvider())
        let result = NavigationBuilder(dependency: dependency).build(withListener: self)
        navigationRIB = result.navigationRouter
        handlerUrl = result.urlHandler
    }

    private func setupImageCache() {
        ImageCache.default.diskStorage.config.expiration = .days(2)
    }
}

// MARK: - NavigationListener -

extension AppDelegate: NavigationListener {
    
}
