import RIBs
import RxSwift

protocol FavoritePhotosRouting: ViewableRouting {
    func go(to route: FavoritePhotosRoute)
}

protocol FavoritePhotosPresentable: Presentable {
    var listener: FavoritePhotosPresentableListener? { get set }
    
    func render(state: FavoritePhotos.ViewModel.Transition)
}

protocol FavoritePhotosListener: AnyObject {
}

final class FavoritePhotosInteractor: PresentableInteractor<FavoritePhotosPresentable>, FavoritePhotosInteractable, FavoritePhotosPresentableListener {

    weak var router: FavoritePhotosRouting?
    weak var listener: FavoritePhotosListener?
    
    private let favoriteModelProvider: FavoriteModelProviderProtocol
    private let model: FavoritePhotos.Model.State = .init()
    
    init(presenter: FavoritePhotosPresentable, component: FavoritePhotosComponent) {
        self.favoriteModelProvider = component.favoriteModelProvider
        
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        setupRx()
    }

    override func willResignActive() {
        super.willResignActive()
    }
    
    private func setupRx() {
        favoriteModelProvider
            .rxFavoriteListChanged
            .observe(on: MainScheduler.instance)
            .bind { [weak self] models in
                guard let self = self else { return }
                self.model.models = models.map { .init(domainModel: $0) }
                self.presenter.render(state: .data(model: self.model))
        }.disposeOnDeactivate(interactor: self)
        
        self.model.rxImageSelected.bind { [weak self] model in
            self?.router?.go(to: .photoDetails(model: model.domainModel))
        }.disposeOnDeactivate(interactor: self)
    }
}
