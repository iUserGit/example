import Foundation

public enum InAppURLSchemeHelper {
    public enum Keys: String {
        case modelId
    }
    
    public enum Route: String {
        public static let scheme = "unsplashtestapp"
        public static let host = "unsplash.app"
        
        case photoDetails = "/photo/details/"
        
        public var path: String {
            let index = rawValue.index(before: rawValue.endIndex)
            return  String(rawValue[rawValue.startIndex..<index])
        }
        
        func components() -> URLComponents {
            var components = URLComponents()
            components.scheme = Route.scheme
            components.host = Route.host
            components.path = rawValue
            return components
        }
    }
    
    public static func urlPhotoDetails(model: UnsplashDM.Photo) -> URL {
        var component = Route.photoDetails.components()
        let modelId = UUID().uuidString
        InAppURLStorage.add(value: model, key: modelId)
        component.queryItems = [
            URLQueryItem(name: Keys.modelId.rawValue, value: modelId)
        ]
        return component.url!
    }
}

public class InAppURLStorage {
    private static var storage: [String: Any] = [:]
    
    public static func add(value: Any, key: String) {
        storage[key] = value
    }
    
    public static func value(for key: String) -> Any? {
        return storage[key]
    }
    
    @discardableResult
    public static func removeValue(for key: String) -> Any? {
        return storage.removeValue(forKey: key)
    }
}
