import RIBs
import RxSwift
import UIKit

protocol NavigationPresentableListener: AnyObject {

}

final class NavigationViewController: UINavigationController, NavigationPresentable {
    weak var listener: NavigationPresentableListener?
    private var disposeBag: DisposeBag?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRx()
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return ColorScheme.current.preferredStatusBarStyle
    }
    
    func transitionView(state: Navigation.ViewModel.Transition) {
        switch state {
        case .error(message: let message):
            if let message = message {
                hideAllMessages()
                displayError(title: "", message: message)
            }
        }
    }
    
    override func updateColor() {
        super.updateColor()
        view.backgroundColor = ColorScheme.current.background
        setNeedsStatusBarAppearanceUpdate()
    }

    // MARK: - Private -

    private func setupUI() {
        isNavigationBarHidden = true
        view.backgroundColor = ColorScheme.current.background
    }
    
    private func setupRx() {
        disposeBag = .init()
        UIScreen.main.rx
            .userInterfaceStyle()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { userInterfaceStyle in
                
                switch UIScreen.main.traitCollection.userInterfaceStyle {
                case .dark:
                    ColorScheme.update(colorScheme: .dark)
                default:
                    ColorScheme.update(colorScheme: .light)
                }
            })
            .disposed(by: disposeBag!)
    }
}

// MARK: - NavigationViewControllable -

extension NavigationViewController: NavigationViewControllable {
    func replaceCurrent(viewController: UIViewController, force: Bool) {
        guard viewControllers.first != viewController else {
            return
        }

        if let initial = viewControllers.first, !force {
            viewControllers = [viewController]
            initial.modalPresentationStyle = .fullScreen
            viewController.present(initial, animated: false) {
                viewController.dismiss(animated: true)
            }
        } else {
            viewControllers = [viewController]
        }
    }
}
