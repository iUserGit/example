import Foundation

public struct SearchPhotosRequest: DataRequest {
    public var method: HTTPMethod {
        .get
    }
    
    public var url: String {
        let baseURL: String = NetworkLayerData.baseURL
        let path: String = "/search/photos"
        return baseURL + path
    }
    
    public var apiKey: String?
    
    public var queryItems: [String : String] = [:]
    
    public init(query: String, limit: Int, page: Int, apiKey: String) {
        self.apiKey = apiKey
        queryItems["query"] = query
        queryItems["page"] = "\(page)"
        queryItems["per_page"] = "\(limit)"
    }
    
    public func decode(_ data: Data) throws -> SearchPhotosResponse {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let response = try decoder.decode(SearchPhotosResponse.self, from: data)
        return response
    }
}


public struct SearchPhotosResponse: Codable {
    public let total: Int
    public let totalPages: Int
    public let results: [UnsplashDM.Photo]
    
    enum CodingKeys: String, CodingKey {
        case total
        case totalPages = "total_pages"
        case results
    }
}


