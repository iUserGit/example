import RIBs

protocol PhotoDetailsInteractable: Interactable {
    var router: PhotoDetailsRouting? { get set }
    var listener: PhotoDetailsListener? { get set }
}

protocol PhotoDetailsViewControllable: ViewControllable {
}

final class PhotoDetailsRouter: ViewableRouter<PhotoDetailsInteractable, PhotoDetailsViewControllable>, PhotoDetailsRouting {

    override init(interactor: PhotoDetailsInteractable, viewController: PhotoDetailsViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
