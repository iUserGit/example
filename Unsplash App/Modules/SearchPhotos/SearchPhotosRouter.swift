import RIBs
import UIKit

protocol SearchImageInteractable: Interactable {
    var router: SearchPhotosRouting? { get set }
    var listener: SearchPhotosListener? { get set }
}

protocol SearchImageViewControllable: ViewControllable {
}

enum SearchPhotosRoute {
    case photoDetails(model: UnsplashDM.Photo)
}

final class SearchPhotosRouter: ViewableRouter<SearchImageInteractable, SearchImageViewControllable>, SearchPhotosRouting {
    override init(interactor: SearchImageInteractable, viewController: SearchImageViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    func go(to route: SearchPhotosRoute) {
        switch route {
        case .photoDetails(let model):
            let url = InAppURLSchemeHelper.urlPhotoDetails(model: model)
            UIApplication.shared.open(url)
        }
    }
}
