import RIBs
import RxSwift
import Foundation

protocol SearchPhotosRouting: ViewableRouting {
    func go(to route: SearchPhotosRoute)
}

protocol SearchPhotosPresentable: Presentable {
    var listener: SearchPhotoPresentableListener? { get set }
    
    func render(state: SearchPhotos.ViewModel.Transition)
}

protocol SearchPhotosListener: AnyObject {
}

final class SearchPhotosInteractor: PresentableInteractor<SearchPhotosPresentable>, SearchImageInteractable {

    weak var router: SearchPhotosRouting?
    weak var listener: SearchPhotosListener?
    
    private let model: SearchPhotos.Model.State = .init()
    private let searchService: SearchPhotosServiceProtocol

    init(presenter: SearchPhotosPresentable, component: SearchPhotosComponent) {
        self.searchService = component.searchService
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        self.setupRx()
    }

    override func willResignActive() {
        super.willResignActive()
    }
    
    // MARK: - Private -
    
    private func setupRx() {
        model.rxImageSelected.bind { [weak self] model in
            self?.didSelect(model: model)
        }.disposeOnDeactivate(interactor: self)
    }
    
    private func didSelect(model: SearchPhotos.Model.Image) {
        router?.go(to: .photoDetails(model: model.domainModel))
    }
}

extension SearchPhotosInteractor: SearchPhotoPresentableListener {
    func didReachEndOfList() {
        guard false == self.model.searchText.isEmpty, self.model.canNextFetch else {
            return
        }
        
        self.model.canNextFetch = false
        searchImage(by: self.model.searchText, page: self.model.nextPage, limit: model.searchLimit)
    }
    
    func didSelectRefreshData() {
        guard false == self.model.searchText.isEmpty else {
            presenter.render(state: .data(model: model))
            return
        }
        searchImage(by: self.model.searchText, page: 1, limit: model.searchLimit)
    }
    
    func didChangeSearchText(_ text: String) {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        self.model.searchText = query
        guard false == query.isEmpty else {
            return
        }
        
        searchImage(by: query, page: 1, limit: model.searchLimit)
    }
    
    private func searchImage(by query: String, page: Int, limit: Int) {
        searchService.searchPhotos(by: query, page: page, limit: limit) { [weak self] result in
            switch result {
            case .success(result: let result):
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    let forceUpdate: Bool = page == 1
                    
                    if forceUpdate {
                        self.model.models = result.results.map { .init(domainModel: $0) }
                    } else {
                        let diff = diff4(self.model.models, result.results) {
                            return $0.id == $1.id
                        }
                        self.model.models = self.model.models + diff.inserted.map { .init(domainModel: $0) }
                    }
                                        
                    self.model.nextPage = page + 1
                    self.model.canNextFetch = result.totalPages >= self.model.nextPage
                    self.presenter.render(state: .data(model: self.model))
                }

            case .failure(let error):
                if error.code == ErrorHandler.ErrorCode.cancelled.code { return }
                DispatchQueue.main.async { [weak self] in
                    self?.presenter.render(state: .error(message: error.error))
                }
            }
        }
    }
}
