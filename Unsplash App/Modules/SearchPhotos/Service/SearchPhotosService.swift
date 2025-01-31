import Foundation

public protocol SearchPhotosServiceProtocol {
    func searchPhotos(by query: String, page: Int, limit: Int, complete: @escaping (Result<SearchPhotosResponse>) -> Void)
}

public final class SearchPhotosService: SearchPhotosServiceProtocol {
    private let dataProvider: DataProviderProtocol
    private var lastRequestId: String?
    
    init(dataProvider: DataProviderProtocol) {
        self.dataProvider = dataProvider
    }
    
    
    public func searchPhotos(by query: String, page: Int, limit: Int, complete: @escaping (Result<SearchPhotosResponse>) -> Void) {
        if let lastRequestId = lastRequestId {
            dataProvider.cancelTask(id: lastRequestId)
        }
        
        let requestId = UUID().uuidString
        self.lastRequestId = requestId
        
        dataProvider.searchPhoto(by: query, page: page, limit: limit, requestId: requestId) { result in
            self.lastRequestId = nil
            complete(result)
        }
    }
}
