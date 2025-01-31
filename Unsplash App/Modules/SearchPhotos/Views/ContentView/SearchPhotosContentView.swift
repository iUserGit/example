import Foundation
import IGListKit
import RxSwift

class SearchPhotosContentView: UIView {
    private lazy var adapter: ListAdapter = {
        let adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: nil)
        adapter.dataSource = self
        adapter.scrollViewDelegate = self
        return adapter
    }()
    
    private var collectionView: UICollectionView!
    private var refreshControl: UIRefreshControl?
   
    let rxRefreshDataSelected: PublishSubject<Void> = .init()
    let rxDidReachEndOfList: PublishSubject<Void> = .init()
    
    var viewModels: [ListDiffable] = [] {
        didSet {
            if self.refreshControl?.isRefreshing == true {
                self.refreshControl?.endRefreshing()
            }
            adapter.performUpdates(animated: true)
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.adapter.performUpdates(animated: false)
    }
    
    func update(inset: UIEdgeInsets) {
        collectionView.contentInset = inset
    }
    
    deinit {
        updateColorUnsubscribe()
    }
    
    // MARK: - Private -
    
    private func setupUI() {
        let layoutFlow = ListCollectionViewLayout.init(stickyHeaders: false, topContentInset: 0, stretchToEdge: false)
        collectionView = .init(frame: .zero, collectionViewLayout: layoutFlow)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = .init(top: 20, left: 0, bottom: 100, right: 0)
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        collectionView.backgroundColor = .clear
        adapter.collectionView = collectionView
        
        
        updateColor()
        updateColorSubscribe()
    }
    
    func setupRefresh() {
        guard nil == self.refreshControl else {
            return
        }
        
        refreshControl = .init()
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl

    }
    
    @objc private func refreshData() {
        rxRefreshDataSelected.onNext(())
    }
    
    override func updateColor() {
        backgroundColor = ColorScheme.current.background
        
    }
}

extension SearchPhotosContentView: ListAdapterDataSource, UIScrollViewDelegate {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return viewModels
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case is SearchPhotos.ViewModel.Image:
            return SearchPhotosPhotoController()
        default:
            return ListSectionController()
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                          withVelocity _: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let distance = scrollView.contentSize.height - (targetContentOffset.pointee.y + scrollView.bounds.height)
        if  distance <= 50 {
            rxDidReachEndOfList.onNext(())
        }
    }
}
