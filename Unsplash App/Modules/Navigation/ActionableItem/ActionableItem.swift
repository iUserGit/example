
import RIBs
import RxSwift

public protocol RoutableActionableItem: AnyObject {
    func showPhotoDetails(model: UnsplashDM.Photo) -> Observable<(RoutableActionableItem, ())>
}
