import RxSwift
import RxCocoa
import UIKit

extension Reactive where Base == UIScreen {
    @available(iOS 13.0, *)
    func userInterfaceStyle() -> Observable<UIUserInterfaceStyle> {
        let currentUserInterfaceStyle = UITraitCollection.current.userInterfaceStyle
        let initial = Observable.just(currentUserInterfaceStyle)
        let selector = #selector(UIScreen.traitCollectionDidChange(_:))
        let following = self.base
            .rx
            .methodInvoked(selector)
            .flatMap { (args) -> Observable<UIUserInterfaceStyle> in
                return Observable.just(UITraitCollection.current.userInterfaceStyle)
        }
        return Observable.concat(initial, following)
    }
}
