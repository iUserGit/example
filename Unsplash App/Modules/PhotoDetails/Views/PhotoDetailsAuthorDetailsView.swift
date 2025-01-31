import RxSwift
import UIKit

final class PhotoDetailsAuthorDetailsView: UIView {
    private var gradientView: GradientView!
    private var detailsLabel: UILabel!
    private var likeButton: UIButton!
    
    let rxFavoriteSelected: PublishSubject<Void> = .init()
    
    var viewModel: PhotoDetails.Model.Image? {
        didSet {
            self.update(model: viewModel)
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
    
    func update(isFavorite: Bool) {
        self.likeButton.isSelected = isFavorite
    }
    
    // MARK: - Private -
    
    private func setupUI() {
        gradientView = .init()
        addSubview(gradientView)
        
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        likeButton = .init()
        likeButton.addTarget(self, action: #selector(didSelectFavorite), for: .touchUpInside)
        likeButton.layer.cornerRadius = 22
        addSubview(likeButton)
        likeButton.snp.makeConstraints { make in
            make.bottom.equalTo(snp.bottomMargin)
            make.right.equalTo(snp.rightMargin).offset(-16)
            make.height.width.equalTo(44)
        }
        
        detailsLabel = .init()
        detailsLabel.numberOfLines = 5
        addSubview(detailsLabel)
        detailsLabel.snp.makeConstraints { make in
            make.left.equalTo(snp.leftMargin).offset(16)
            make.right.equalTo(likeButton.snp.left).offset(-5)
            make.bottom.equalTo(snp.bottomMargin)
        }
        
        updateColor()
        updateColorSubscribe()
    }
    
    override func updateColor() {
        likeButton.setImage(UIImage(systemName: "star")?.withTintColor(ColorScheme.current.active), for: .normal)
        likeButton.setImage(UIImage(systemName: "star.fill")?.withTintColor(ColorScheme.current.active), for: .selected)
        
        likeButton.tintColor = ColorScheme.current.active
        
        update(model: viewModel)
        gradientView.applyGradient(position: .bottomTop, colors: [ColorScheme.current.background.cgColor, ColorScheme.current.background.withAlphaComponent(0).cgColor])
    }
    
    private func update(model: PhotoDetails.Model.Image?) {
        
        let boldAttributes: [NSAttributedString.Key : Any] = [.foregroundColor: ColorScheme.current.text, .font: UIFont.boldSystemFont(ofSize: 14)]
        let regularAttributes: [NSAttributedString.Key : Any] = [.foregroundColor: ColorScheme.current.text, .font: UIFont.systemFont(ofSize: 12)]
        
        let attStr = NSMutableAttributedString()
        if let createdAt = viewModel?.domainModel.createdAt {
            attStr.append(.init(string: "Created: ", attributes: boldAttributes))
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            attStr.append(.init(string: df.string(from: createdAt), attributes: regularAttributes))
        }
        
        if let username = viewModel?.domainModel.user?.username {
            attStr.append(.init(string: "\n"))
            attStr.append(.init(string: "Username: ", attributes: boldAttributes))
            attStr.append(.init(string: username, attributes: regularAttributes))
        }
        
        if let location = viewModel?.domainModel.user?.location {
            attStr.append(.init(string: "\n"))
            attStr.append(.init(string: "Location: ", attributes: boldAttributes))
            attStr.append(.init(string: location, attributes: regularAttributes))
        }
        
        self.detailsLabel.attributedText = attStr
    }
    
    @objc private func didSelectFavorite() {
        rxFavoriteSelected.onNext(())
    }
}
