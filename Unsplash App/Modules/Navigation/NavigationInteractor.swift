import RIBs
import RxSwift
import UIKit

protocol NavigationRouting: ViewableRouting {
    var navigationDependency: NavigationDependency { get }

    func showLaunch()
    
    func go(to route: NavigationRoute)
}

protocol NavigationPresentable: Presentable {
    var listener: NavigationPresentableListener? { get set }
}

protocol NavigationListener: AnyObject {
}

final class NavigationInteractor: PresentableInteractor<NavigationPresentable>, NavigationInteractable, NavigationPresentableListener {

    weak var router: NavigationRouting?
    weak var listener: NavigationListener?

    
    init(presenter: NavigationPresentable, component: NavigationComponent) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        router?.showLaunch()
    }

    override func willResignActive() {
        super.willResignActive()
    }
    
    // MARK: - Private -

}

// MARK: - UrlHandler -

extension NavigationInteractor: UrlHandler {
    func handle(_ url: URL) -> Bool {
        if nil != RoutingWorkflow(url: url)?
            .subscribe(self)
            .disposeOnDeactivate(interactor: self) {
            return true
        }
        return false
    }
    
    func handle(url: URL, options: UIScene.OpenURLOptions?, completion: DeeplinkHandlerCompletion?) -> Bool {
        if url.scheme?.lowercased() == InAppURLSchemeHelper.Route.scheme.lowercased() {
            if handle(url) {
                return true
            }
        }
        return false
    }
}

// MARK: - ProductActionableItem -

extension NavigationInteractor: RoutableActionableItem {
    func showPhotoDetails(model: UnsplashDM.Photo) -> Observable<(RoutableActionableItem, ())> {
        router?.go(to: .photoDetails(model: model))
        return Observable.just((self, ()))
    }
    
}
