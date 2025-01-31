import UIKit
import RxSwift

final class PhotoDetailsNavBarView: UIView {
    private var gradientView: GradientView!
    private var contentView: UIView!
    private var backButton: UIButton!
    
    let rxBackSelected: PublishSubject<Void> = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateHeight()
    }
    
    deinit {
        updateColorUnsubscribe()
    }
    
    // MARK: - Private -
    
    private func setupUI() {
        gradientView = .init()
        addSubview(gradientView)
        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView = .init()
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(44)
        }
        
        backButton = .init()
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.imageEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        contentView.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.left.equalTo(contentView.snp.leftMargin).offset(5)
            make.height.width.equalTo(44)
            make.centerY.equalToSuperview()
        }
        backButton.addTarget(self, action: #selector(didSelectBack), for: .touchUpInside)
        updateColor()
        updateColorSubscribe()
    }
    
    private func updateHeight() {
        snp.updateConstraints { make in
            make.height.equalTo(44 + safeAreaInsets.top)
        }
    }
    
    override func updateColor() {
        
        backButton.tintColor = ColorScheme.current.active
        gradientView.applyGradient(position: .topBottom, colors: [ColorScheme.current.background.cgColor, ColorScheme.current.background.withAlphaComponent(0).cgColor])
    }
    
    @objc private func didSelectBack() {
        rxBackSelected.onNext(())
    }
}
