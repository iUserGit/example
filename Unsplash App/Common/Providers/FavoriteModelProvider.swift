import RxCocoa
import Foundation
import RxSwift

public protocol FavoriteModelProviderProtocol {
    var rxFavoriteListChanged: BehaviorRelay<[UnsplashDM.Photo]> { get }
    
    func addToFavorite(model: UnsplashDM.Photo)
    func removeFromFavorite(id: String)
    func getFavorites() -> [UnsplashDM.Photo]
    func isFavorite(id: String) -> Bool
    
    
}

public final class FavoriteModelProvider: FavoriteModelProviderProtocol {
    
    private enum Keys {
        static let favoriteListKey = "favoriteListKey"
    }
    
    private var disposeBag: DisposeBag?
    
    public init() {
        rxFavoriteListChanged = .init(value: [])
        rxFavoriteListChanged.accept(extractFromCache())
        setupRx()
    }
    
    public let rxFavoriteListChanged: BehaviorRelay<[UnsplashDM.Photo]>
    
    public func addToFavorite(model: UnsplashDM.Photo) {
        var favoriteList = rxFavoriteListChanged.value
        guard false == favoriteList.contains(where: { $0.id == model.id }) else {
            return
        }
        favoriteList.append(model)
        rxFavoriteListChanged.accept(favoriteList)
    }
    
    public func removeFromFavorite(id: String) {
        var favoriteList = rxFavoriteListChanged.value
        if let index = favoriteList.firstIndex(where: { $0.id == id }) {
            favoriteList.remove(at: index)
            rxFavoriteListChanged.accept(favoriteList)
        }
    }
    
    public func getFavorites() -> [UnsplashDM.Photo] {
        rxFavoriteListChanged.value
    }
    
    public func isFavorite(id: String) -> Bool {
        rxFavoriteListChanged.value.contains(where: { $0.id == id })
    }
    
    // MARK: - Private -
    
    private func setupRx() {
        disposeBag = .init()
        rxFavoriteListChanged.bind { [weak self] models in
            self?.cacheFavoriteList(models: models)
        }.disposed(by: disposeBag!)
    }
    
    private func cacheFavoriteList(models: [UnsplashDM.Photo]) {
        guard false == models.isEmpty else {
            UserDefaults.standard.removeObject(forKey: Keys.favoriteListKey)
            return
        }
        
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(models)
            UserDefaults.standard.set(encodedData, forKey: Keys.favoriteListKey)
        } catch {
            print(error)
        }
    }
    
    private func extractFromCache() -> [UnsplashDM.Photo] {
        let decoder = JSONDecoder()
        guard let data = UserDefaults.standard.data(forKey: Keys.favoriteListKey) else {
            return []
        }
        
        do {
            return try decoder.decode([UnsplashDM.Photo].self, from: data)
        } catch {
            return []
        }
    }
}
