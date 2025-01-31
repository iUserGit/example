import RIBs
import RxSwift
import UIKit

protocol GalleryTabBarPresentableListener: AnyObject {
}

final class GalleryTabBarViewController: UITabBarController, GalleryTabBarPresentable, GalleryTabBarViewControllable {

    weak var listener: GalleryTabBarPresentableListener?
    private var disposeBag: DisposeBag?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupRx()
    }
    
    deinit {
        updateColorUnsubscribe()
    }
    
    func setViewControllers(_ viewControllers: [UIViewController]) {
        self.setViewControllers(viewControllers, animated: false)
    }
    
    // MARK: - Private -
    
    private func setupUI() {
        updateColor()
        updateColorSubscribe()
    }
    
    private func setupRx() {
        disposeBag = .init()        
    }
    
    override func updateColor() {
        view.backgroundColor = ColorScheme.current.background
        
        let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        self.tabBar.standardAppearance = tabBarAppearance
        self.tabBar.overrideUserInterfaceStyle = ColorScheme.current.alertStyle

        if #available(iOS 15.0, *) {
            self.tabBar.scrollEdgeAppearance = tabBarAppearance
        }
    }
}
