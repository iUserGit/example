import UIKit

final class PhotoDetailsImageView: UIView {
    private var imageView: UIImageView!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    func updateImage(with model: PhotoDetails.Model.Image) {
        imageView.update(with: model.url, placeholderImage: "")
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
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        updateColor()
        updateColorSubscribe()
    }
    
    override func updateColor() {
        backgroundColor = ColorScheme.current.background
    }
}
