import RIBs
import UIKit
import RxSwift

protocol NavigationInteractable: Interactable {
    var router: NavigationRouting? { get set }
    var listener: NavigationListener? { get set }
}

protocol NavigationViewControllable: ViewControllable {
    func replaceCurrent(viewController: UIViewController, force: Bool)
}

enum NavigationRoute {
    case open(url: URL)
    case photoDetails(model: UnsplashDM.Photo)
}

final class NavigationRouter: ViewableRouter<NavigationInteractable, NavigationViewControllable>, NavigationRouting {
    var navigationDependency: NavigationDependency
    
    init(interactor: NavigationInteractable, viewController: NavigationViewControllable, dependency: NavigationDependency) {
        self.navigationDependency = dependency
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    func showLaunch() {
        let depencency = GalleryTabBarDependencyImpl(dataProvider: navigationDependency.dataProvider, favoriteModelProvider: navigationDependency.favoriteModelProvider)
        let rib = GalleryTabBarBuilder(dependency: depencency).build(withListener: self)
        let vc = rib.viewControllable.uiviewController
        viewController.replaceCurrent(viewController: vc, force: true)
        attachChild(rib)
    }
    
    func go(to route: NavigationRoute) {
        switch route {
        case .open(let url):
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        case .photoDetails(let model):
            self.showPhotoDetails(model: model)
        }
    }
    
    // MARK: - Private -
    
    private func showPhotoDetails(model: UnsplashDM.Photo) {
        let dependency = PhotoDetailsDependencyImpl(model: model, favoriteModelProvider: navigationDependency.favoriteModelProvider)
        let rib = PhotoDetailsBuilder(dependency: dependency).build(withListener: self)
        showRibAsModal(rib: rib)
    }
        
    private func topPresentedVC(for vc: UIViewController) -> UIViewController {
        if let vc = vc.presentedViewController {
            return topPresentedVC(for: vc)
        }
        return vc
    }
    
    private func showRibAsModal(rib: ViewableRouting, animated: Bool = true) {
        let topVC = topPresentedVC(for: viewControllable.uiviewController)
        let vc = rib.viewControllable.uiviewController
        vc.modalPresentationStyle = .fullScreen
        topVC.present(vc, animated: animated)
        attachChild(rib)
    }

    private func hideRibAsModal(rib: ViewableRouting, animated: Bool = true, complete: (()->())? = nil) {
        let vc = rib.viewControllable.uiviewController
        vc.dismiss(animated: animated, completion: complete)
    }
}

extension NavigationRouter: GalleryTabBarListener {
    
}

extension NavigationRouter: PhotoDetailsListener {
    func didSelectBakc(sender: any PhotoDetailsRouting) {
        self.hideRibAsModal(rib: sender)
    }

}
