import RIBs

protocol FavoritePhotosDependency: Dependency {
    var favoriteModelProvider: FavoriteModelProviderProtocol { get }
}

class FavoritePhotosDependencyImpl: FavoritePhotosDependency {
    var favoriteModelProvider: any FavoriteModelProviderProtocol
    
    init(favoriteModelProvider: any FavoriteModelProviderProtocol) {
        self.favoriteModelProvider = favoriteModelProvider
    }
}

final class FavoritePhotosComponent: Component<FavoritePhotosDependency> {
    var favoriteModelProvider: FavoriteModelProviderProtocol {
        dependency.favoriteModelProvider
    }
}

// MARK: - Builder

protocol FavoritePhotosBuildable: Buildable {
    func build(withListener listener: FavoritePhotosListener) -> FavoritePhotosRouting
}

final class FavoritePhotosBuilder: Builder<FavoritePhotosDependency>, FavoritePhotosBuildable {

    override init(dependency: FavoritePhotosDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: FavoritePhotosListener) -> FavoritePhotosRouting {
        let component = FavoritePhotosComponent(dependency: dependency)
        let viewController = FavoritePhotosViewController()
        let interactor = FavoritePhotosInteractor(presenter: viewController, component: component)
        interactor.listener = listener
        return FavoritePhotosRouter(interactor: interactor, viewController: viewController)
    }
}
