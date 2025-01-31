import UIKit
import Kingfisher

public extension UIImageView {
    func update(with url: URL?, placeholderImage: String, complete: ((UIImage?) -> Void)? = nil) {
        kf.cancelDownloadTask()
      
        let placeholder: UIImage? = UIImage(systemName: placeholderImage) ?? UIImage(named: placeholderImage)
        kf.indicatorType = .custom(indicator: ActivityIndicator())
        kf.setImage(with: url,
                    placeholder: placeholder,
                    progressBlock: nil) { result in
            switch result {
            case .success(let imageResult):
                complete?(imageResult.image)
                
            case .failure(_):
                complete?(nil)
            }
        }
    }
}

class ActivityIndicator: Indicator {

    #if os(macOS)
    private var activityIndicatorView: NSProgressIndicator
    #else
    private var activityIndicatorView: UIActivityIndicatorView?
    #endif
    private var animatingCount = 0

    var view: IndicatorView {
        return activityIndicatorView ?? UIView()
    }

    func startAnimatingView() {
        if animatingCount == 0 {
            #if os(macOS)
            activityIndicatorView.startAnimation(nil)
            #else
            activityIndicatorView?.startAnimating()
            #endif
            activityIndicatorView?.isHidden = false
        }
        animatingCount += 1
    }

    func stopAnimatingView() {
        animatingCount = max(animatingCount - 1, 0)
        if animatingCount == 0 {
            #if os(macOS)
                activityIndicatorView?.stopAnimation(nil)
            #else
                activityIndicatorView?.stopAnimating()
            #endif
            activityIndicatorView?.isHidden = true
        }
    }

    func sizeStrategy(in imageView: KFCrossPlatformImageView) -> IndicatorSizeStrategy {
        return .intrinsicSize
    }

    init() {
        #if os(macOS)
            activityIndicatorView = NSProgressIndicator(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
            activityIndicatorView?.controlSize = .small
            activityIndicatorView?.style = .spinning
        #else
            let indicatorStyle: UIActivityIndicatorView.Style

            #if os(tvOS)
            if #available(tvOS 13.0, *) {
                indicatorStyle = UIActivityIndicatorView.Style.large
            } else {
                indicatorStyle = UIActivityIndicatorView.Style.white
            }
            #else
            if #available(iOS 13.0, * ) {
                indicatorStyle = UIActivityIndicatorView.Style.medium
            } else {
                indicatorStyle = UIActivityIndicatorView.Style.gray
            }
            #endif

            activityIndicatorView = UIActivityIndicatorView(style: indicatorStyle)
            activityIndicatorView?.color = UIColor.white.withAlphaComponent(0.8)
        #endif
    }
}
