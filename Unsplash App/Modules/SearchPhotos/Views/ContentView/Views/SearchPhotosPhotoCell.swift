import UIKit
import Kingfisher

class SearchPhotosPhotoCell: UICollectionViewCell {
    private var imageView: UIImageView!
    
    var viewModel: SearchPhotos.ViewModel.Image? {
        didSet {
            imageView.update(with: viewModel?.model.thumb, placeholderImage: "photo.artframe")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    deinit {
        updateColorUnsubscribe()
    }
    
    // MARK: - Private -
    
    private func setupUI() {
        imageView = .init()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        updateColor()
        updateColorSubscribe()
    }
    
    override func updateColor() {
        
    }
}
