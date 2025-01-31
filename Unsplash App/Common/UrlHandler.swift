import UIKit

public typealias DeeplinkHandlerCompletion = (_ success: Bool) -> Void

public protocol UrlHandler: AnyObject {
    func handle(_ url: URL) -> Bool
    func handle(url: URL, options: UIScene.OpenURLOptions?, completion: DeeplinkHandlerCompletion?) -> Bool
}
