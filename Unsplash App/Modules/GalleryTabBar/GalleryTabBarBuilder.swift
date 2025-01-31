import RIBs
import UIKit

protocol GalleryTabBarDependency: Dependency {
    var dataProvider: any DataProviderProtocol { get }
    var favoriteModelProvider: any FavoriteModelProviderProtocol { get }
}

class GalleryTabBarDependencyImpl: GalleryTabBarDependency {
    let dataProvider: any DataProviderProtocol
    let favoriteModelProvider: any FavoriteModelProviderProtocol
    
    init(dataProvider: any DataProviderProtocol, favoriteModelProvider: any FavoriteModelProviderProtocol) {
        self.dataProvider = dataProvider
        self.favoriteModelProvider = favoriteModelProvider
    }
}

final class GalleryTabBarComponent: Component<GalleryTabBarDependency> {
}

// MARK: - Builder

protocol GalleryTabBarBuildable: Buildable {
    func build(withListener listener: GalleryTabBarListener) -> GalleryTabBarRouting
}

final class GalleryTabBarBuilder: Builder<GalleryTabBarDependency>, GalleryTabBarBuildable {

    override init(dependency: GalleryTabBarDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: GalleryTabBarListener) -> GalleryTabBarRouting {
        let viewController = GalleryTabBarViewController()
        let interactor = GalleryTabBarInteractor(presenter: viewController)
        interactor.listener = listener
        
        let searchPhotosDependency = SearchPhotosDependencyImpl(dataProvider: dependency.dataProvider)
        let favoritePhotosDependency = FavoritePhotosDependencyImpl(favoriteModelProvider: dependency.favoriteModelProvider)
        return GalleryTabBarRouter(interactor: interactor,
                                   viewController: viewController,
                                   searchPhotosBuilder: SearchPhotosBuilder(dependency: searchPhotosDependency),
                                   favoritePhotosBuilder: FavoritePhotosBuilder(dependency: favoritePhotosDependency))
    }
}
