import Foundation
import UIKit

enum NetworkLayerData {
    static let apiKey: String = ""
    static let baseURL: String = "https://api.unsplash.com"
}

public protocol DataProviderProtocol {
    func searchPhoto(by query: String, page: Int, limit: Int, requestId: String, complete: @escaping (Result<SearchPhotosResponse>) -> Void)
    
    func cancelTask(id: String)
    func cancelAllExistingTask()
}

public class DataProvider: DataProviderProtocol {
    
    private let networkService: NetworkService
    private let apiKey: String
    
    private var appVersion: String {
        return (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "undefined"
    }
    
    public init(network: NetworkService, apiKey: String) {
        self.networkService = network
        self.apiKey = apiKey
    }
    
    public func cancelTask(id: String) {
        networkService.cancelTask(id: id)
    }
    
    public func cancelAllExistingTask() {
        networkService.cancelAllExistingTask()
    }
    
    public func searchPhoto(by query: String, page: Int, limit: Int, requestId: String, complete: @escaping (Result<SearchPhotosResponse>) -> Void) {
        
        guard false == apiKey.isEmpty else {
            complete(.failure(.init(error: "API Key is empty. Please, add your API Key", code: 403)))
            return
        }
        
        networkService.request(SearchPhotosRequest(query: query, limit: limit, page: page, apiKey: self.apiKey), requestId: requestId, completion: complete)
    }
}
