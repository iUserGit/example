import RIBs

protocol NavigationDependency: Dependency {
    var dataProvider: any DataProviderProtocol { get }
    var favoriteModelProvider: any FavoriteModelProviderProtocol { get }
}

class NavigationDependencyImpl: NavigationDependency {
    let dataProvider: any DataProviderProtocol
    let favoriteModelProvider: any FavoriteModelProviderProtocol
    
    init(dataProvider: any DataProviderProtocol, favoriteModelProvider: any FavoriteModelProviderProtocol) {
        self.dataProvider = dataProvider
        self.favoriteModelProvider = favoriteModelProvider
    }
}

final class NavigationComponent: Component<NavigationDependency> {
}

// MARK: - Builder

protocol NavigationBuildable: Buildable {
    func build(withListener listener: NavigationListener) -> (navigationRouter: NavigationRouting, urlHandler: UrlHandler)
}

final class NavigationBuilder: Builder<NavigationDependency>, NavigationBuildable {

    override init(dependency: NavigationDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: NavigationListener) -> (navigationRouter: NavigationRouting, urlHandler: UrlHandler) {
        let component = NavigationComponent(dependency: dependency)
       
        let viewController = NavigationViewController()
        let interactor = NavigationInteractor(presenter: viewController, component: component)
        interactor.listener = listener
        
        let router = NavigationRouter(interactor: interactor, viewController: viewController, dependency: dependency)
        
        return (router, interactor)
    }
}
