import RIBs
import RxSwift

protocol GalleryTabBarRouting: ViewableRouting {
    func attachTabs()
}

protocol GalleryTabBarPresentable: Presentable {
    var listener: GalleryTabBarPresentableListener? { get set }
}

protocol GalleryTabBarListener: AnyObject {
}

final class GalleryTabBarInteractor: PresentableInteractor<GalleryTabBarPresentable>, GalleryTabBarInteractable, GalleryTabBarPresentableListener {

    weak var router: GalleryTabBarRouting?
    weak var listener: GalleryTabBarListener?

    override init(presenter: GalleryTabBarPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        router?.attachTabs()
    }

    override func willResignActive() {
        super.willResignActive()
    }
}
