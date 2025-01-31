import RIBs
import RxSwift
import UIKit

protocol FavoritePhotosPresentableListener: AnyObject {

}

final class FavoritePhotosViewController: UIViewController, FavoritePhotosViewControllable {

    weak var listener: FavoritePhotosPresentableListener?
    private var contentView: SearchPhotosContentView!
    private var disposeBag: DisposeBag?
    
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
            make.top.equalTo(view.snp.topMargin)
            make.left.equalTo(view.snp.leftMargin)
            make.right.equalTo(view.snp.rightMargin)
            make.bottom.equalToSuperview()
        }
        
        updateColor()
        updateColorSubscribe()
    }
    
    private func setupRx() {
        disposeBag = .init()
       
    }
    
    override func updateColor() {
        view.backgroundColor = ColorScheme.current.background
    }
}

extension FavoritePhotosViewController: FavoritePhotosPresentable {
    func render(state: FavoritePhotos.ViewModel.Transition) {
        loadViewIfNeeded()
        switch state {
        case .data(model: let model):
            reloadData(with: model)
        case .error(let message):
            if let message = message {
                hideAllMessages()
                displayError(title: "", message: message)
            }
        }
    }
    
    private func reloadData(with model: FavoritePhotos.Model.State) {
        contentView.viewModels = model.models.compactMap { SearchPhotos.ViewModel.Image(model: $0, rxImageSelected: model.rxImageSelected)}
    }
}
