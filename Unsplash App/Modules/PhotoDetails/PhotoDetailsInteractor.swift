import RIBs
import RxSwift

protocol PhotoDetailsRouting: ViewableRouting {
}

protocol PhotoDetailsPresentable: Presentable {
    var listener: PhotoDetailsPresentableListener? { get set }
    
    func render(state: PhotoDetails.ViewModel.Transition)
}

protocol PhotoDetailsListener: AnyObject {
    func didSelectBakc(sender: PhotoDetailsRouting)
}

final class PhotoDetailsInteractor: PresentableInteractor<PhotoDetailsPresentable>, PhotoDetailsInteractable {

    weak var router: PhotoDetailsRouting?
    weak var listener: PhotoDetailsListener?
    
    private let favoriteModelProvider: FavoriteModelProviderProtocol
    private let model: PhotoDetails.Model.State
    
    init(presenter: PhotoDetailsPresentable, component: PhotoDetailsComponent) {
        self.favoriteModelProvider = component.favoriteModelProvider
        self.model = .init(model: .init(domainModel: component.model), isFavorite: favoriteModelProvider.isFavorite(id: component.model.id))
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        presenter.render(state: .data(model: model))
    }

    override func willResignActive() {
        super.willResignActive()
    }
}

extension PhotoDetailsInteractor: PhotoDetailsPresentableListener {
    func didSelecteFavorite() {
        let photoModel = model.image.domainModel
        if favoriteModelProvider.isFavorite(id: photoModel.id) {
            favoriteModelProvider.removeFromFavorite(id: photoModel.id)
            self.model.rxIsFavorite.accept(false)
        } else {
            favoriteModelProvider.addToFavorite(model: photoModel)
            self.model.rxIsFavorite.accept(true)
        }
    }
    
    func didSelectBack() {
        guard let router = router else { return }
        listener?.didSelectBakc(sender: router)
    }
}
