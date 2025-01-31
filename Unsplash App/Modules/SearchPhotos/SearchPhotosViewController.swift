import RIBs
import RxSwift
import UIKit
import RxCocoa

protocol SearchPhotoPresentableListener: AnyObject {
    func didChangeSearchText(_ text: String)
    func didSelectRefreshData()
    func didReachEndOfList()
}

final class SearchPhotosViewController: UIViewController, SearchImageViewControllable {
    weak var listener: SearchPhotoPresentableListener?
    private var disposeBag: DisposeBag?
    
    private var searchBarView: SearchPhotosSearchBarView!
    private var contentView: SearchPhotosContentView!
    private var keyboardHelper: KeyboardHelper = .init()
    
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
        
        searchBarView = .init(frame: .init(origin: .zero, size: .init(width: 300, height: 40)))
        view.addSubview(searchBarView)
        searchBarView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view.snp.topMargin)
            make.height.equalTo(44)
        }
        
        contentView = .init()
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(searchBarView.snp.bottom)
            make.left.equalTo(view.snp.leftMargin)
            make.right.equalTo(view.snp.rightMargin)
            make.bottom.equalToSuperview()
        }
        contentView.setupRefresh()
        
        keyboardHelper.willShowKeyboard = { [weak self] (value, duration) in
            guard let self = self else { return }
            self.contentView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().offset(-value)
            }
            
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
        
        keyboardHelper.willHideKeyBoard = { [weak self] (duration) in
            guard let self = self else { return }
            self.contentView.snp.updateConstraints { make in
                make.bottom.equalToSuperview()
            }
            
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
        keyboardHelper.start()
        
        updateColor()
        updateColorSubscribe()
    }
    
    private func setupRx() {
        disposeBag = .init()
        
        searchBarView
            .rxSearchTextChanged
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind { [weak self] text in
                self?.listener?.didChangeSearchText(text)
            }.disposed(by: disposeBag!)
        
        contentView.rxRefreshDataSelected.bind { [weak self] in
            self?.listener?.didSelectRefreshData()
        }.disposed(by: disposeBag!)
        
        contentView.rxDidReachEndOfList.bind { [weak self] in
            self?.listener?.didReachEndOfList()
        }.disposed(by: disposeBag!)
    }
    
    override func updateColor() {
        view.backgroundColor = ColorScheme.current.background
    }
}

extension SearchPhotosViewController: SearchPhotosPresentable {
    func render(state: SearchPhotos.ViewModel.Transition) {
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
    
    private func reloadData(with model: SearchPhotos.Model.State) {
        contentView.viewModels = model.models.compactMap { SearchPhotos.ViewModel.Image(model: $0, rxImageSelected: model.rxImageSelected)}
    }
}
