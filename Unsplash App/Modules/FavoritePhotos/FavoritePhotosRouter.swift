import RIBs
import UIKit

protocol FavoritePhotosInteractable: Interactable {
    var router: FavoritePhotosRouting? { get set }
    var listener: FavoritePhotosListener? { get set }
}

protocol FavoritePhotosViewControllable: ViewControllable {
}

enum FavoritePhotosRoute {
    case photoDetails(model: UnsplashDM.Photo)
}

final class FavoritePhotosRouter: ViewableRouter<FavoritePhotosInteractable, FavoritePhotosViewControllable>, FavoritePhotosRouting {

    override init(interactor: FavoritePhotosInteractable, viewController: FavoritePhotosViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    func go(to route: FavoritePhotosRoute) {
        switch route {
        case .photoDetails(let model):
            let url = InAppURLSchemeHelper.urlPhotoDetails(model: model)
            UIApplication.shared.open(url)
        }
    }
}
