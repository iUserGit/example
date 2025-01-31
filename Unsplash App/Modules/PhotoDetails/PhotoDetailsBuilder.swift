import RIBs

protocol PhotoDetailsDependency: Dependency {
    var model: UnsplashDM.Photo { get }
    var favoriteModelProvider: FavoriteModelProviderProtocol { get }
}

class PhotoDetailsDependencyImpl: PhotoDetailsDependency {
    let model: UnsplashDM.Photo
    let favoriteModelProvider: FavoriteModelProviderProtocol
    
    init(model: UnsplashDM.Photo, favoriteModelProvider: FavoriteModelProviderProtocol) {
        self.model = model
        self.favoriteModelProvider = favoriteModelProvider
    }
}

final class PhotoDetailsComponent: Component<PhotoDetailsDependency> {
    var model: UnsplashDM.Photo {
        dependency.model
    }
    
    var favoriteModelProvider: FavoriteModelProviderProtocol {
        dependency.favoriteModelProvider
    }
}

// MARK: - Builder

protocol PhotoDetailsBuildable: Buildable {
    func build(withListener listener: PhotoDetailsListener) -> PhotoDetailsRouting
}

final class PhotoDetailsBuilder: Builder<PhotoDetailsDependency>, PhotoDetailsBuildable {

    override init(dependency: PhotoDetailsDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: PhotoDetailsListener) -> PhotoDetailsRouting {
        let component = PhotoDetailsComponent(dependency: dependency)
        let viewController = PhotoDetailsViewController()
        let interactor = PhotoDetailsInteractor(presenter: viewController, component: component)
        interactor.listener = listener
        return PhotoDetailsRouter(interactor: interactor, viewController: viewController)
    }
}
