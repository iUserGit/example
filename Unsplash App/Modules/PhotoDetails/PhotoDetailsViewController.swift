import RIBs
import RxSwift
import UIKit

protocol PhotoDetailsPresentableListener: AnyObject {
    func didSelectBack()
    func didSelecteFavorite()
}

final class PhotoDetailsViewController: UIViewController, PhotoDetailsViewControllable {
    weak var listener: PhotoDetailsPresentableListener?
    private var disposeBag: DisposeBag?
    private var renderDisposeBag: DisposeBag?
    
    private var contentView: PhotoDetailsImageView!
    private var navBarView: PhotoDetailsNavBarView!
    private var detailsView: PhotoDetailsAuthorDetailsView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupRx()
    }
    
    deinit {
        updateColorUnsubscribe()
    }
    
    // MARK: - Private -
    
    private func setupUI() {
        
        contentView = .init()
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        navBarView = .init()
        view.addSubview(navBarView)
        navBarView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(44 + view.safeAreaInsets.top)
        }
        
        detailsView = .init()
        view.addSubview(detailsView)
        detailsView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(140)
        }
        
        updateColor()
        updateColorSubscribe()
    }
    
    private func setupRx() {
        disposeBag = .init()
        navBarView.rxBackSelected.bind { [weak self] in
            self?.listener?.didSelectBack()
        }.disposed(by: disposeBag!)
        
        detailsView.rxFavoriteSelected.bind { [weak self] in
            self?.listener?.didSelecteFavorite()
        }.disposed(by: disposeBag!)
    }
    
    override func updateColor() {
        view.backgroundColor = ColorScheme.current.background
    }
}

extension PhotoDetailsViewController: PhotoDetailsPresentable {
    func render(state: PhotoDetails.ViewModel.Transition) {
        switch state {
        case .data(model: let model):
            self.reloadData(with: model)
        case .error(message: let message):
            if let message = message {
                hideAllMessages()
                displayError(title: "", message: message)
            }
        }
    }
    
    private func reloadData(with model: PhotoDetails.Model.State) {
        self.contentView.updateImage(with: model.image)
        self.detailsView.viewModel = model.image
        
        renderDisposeBag = .init()
        model.rxIsFavorite.observe(on: MainScheduler.instance).bind { [weak self] isFavorite in
            self?.detailsView.update(isFavorite: isFavorite)
        }.disposed(by: renderDisposeBag!)
    }
}
