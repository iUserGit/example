import RIBs
import UIKit

protocol GalleryTabBarInteractable: Interactable {
    var router: GalleryTabBarRouting? { get set }
    var listener: GalleryTabBarListener? { get set }
}

protocol GalleryTabBarViewControllable: ViewControllable {
    func setViewControllers(_ viewControllers: [UIViewController])
}

final class GalleryTabBarRouter: ViewableRouter<GalleryTabBarInteractable, GalleryTabBarViewControllable>, GalleryTabBarRouting {
    private var searchPhotosBuilder: SearchPhotosBuildable
    private var favoritePhotosBuilder: FavoritePhotosBuildable
    
    init(interactor: GalleryTabBarInteractable, viewController: GalleryTabBarViewControllable, searchPhotosBuilder: SearchPhotosBuildable, favoritePhotosBuilder: FavoritePhotosBuildable) {
        self.searchPhotosBuilder = searchPhotosBuilder
        self.favoritePhotosBuilder = favoritePhotosBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    func attachTabs() {
        let searchPhotosRib = searchPhotosBuilder.build(withListener: self)
        let searchPhotosVC = searchPhotosRib.viewControllable.uiviewController
        searchPhotosVC.tabBarItem = .init(tabBarSystemItem: .search, tag: 0)
       
        let favoritePhotosRib = favoritePhotosBuilder.build(withListener: self)
        let favoritePhotosVC = favoritePhotosRib.viewControllable.uiviewController
        favoritePhotosVC.tabBarItem = .init(tabBarSystemItem: .favorites, tag: 1)
    
        viewController.setViewControllers([searchPhotosVC, favoritePhotosVC])
        attachChild(searchPhotosRib)
        attachChild(favoritePhotosRib)
    }
}

extension GalleryTabBarRouter: SearchPhotosListener, FavoritePhotosListener {
    
}
