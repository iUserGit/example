import Foundation
import UIKit

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

public protocol DataRequest {
    associatedtype Response
    
    var url: String { get }
    var apiKey: String? { get }
    var method: HTTPMethod { get }
    var headers: [String : String] { get }
    var queryItems: [String : String] { get }
    var queryItemsArray: [String: [String]] { get }
    var body: [String: Any] { get }
    var bodyData: Data? { get }
    var timeout: TimeInterval { get }
        
    func decode(_ data: Data) throws -> Response
}

public extension DataRequest where Response: Decodable {
    func decode(_ data: Data) throws -> Response {
        let decoder = JSONDecoder()
        return try decoder.decode(Response.self, from: data)
    }
}

public extension DataRequest {
    var apiKey: String? {
        nil
    }
    
    var timeout: TimeInterval {
        return 30
    }
    var headers: [String : String] {
        if let apiKey = apiKey {
            return ["accept": "*/*",
                    "Accept-Version": "v1",
                    "Content-Type": "application/json",
                    "Authorization": "Client-ID \(apiKey)"]
        } else {
            return ["accept": "*/*",
                    "Accept-Version": "v1",
                    "Content-Type": "application/json"]
        }
    }
    
    var queryItems: [String : String] {
        [:]
    }
    
    var queryItemsArray: [String: [String]] {
        [:]
    }
    
    var body: [String: Any] {
        [:]
    }
    
    var bodyData: Data? {
        if body.isEmpty {
            return nil
        }
        return try? JSONSerialization.data(withJSONObject: body)
    }
}

public protocol NetworkService: AnyObject {
    func request<Request: DataRequest>(_ request: Request, requestId: String, completion: @escaping (Result<Request.Response>) -> Void)
    
    func cancelTask(id: String)
    func cancelAllExistingTask()    
}

public final class DefaultNetworkService: NetworkService {
    
    private var tasks: [String: URLSessionTask] = [:]
    private var tasksQueue = DispatchQueue.init(label: "DefaultNetworkService_tasksQueue")
    
    public init() {}
    
    public func request<Request: DataRequest>(_ request: Request, requestId: String, completion: @escaping (Result<Request.Response>) -> Void) {
        guard var urlComponent = URLComponents(string: request.url) else {
            return completion(.failure(.init(error: "Invalid Endpoint", code: 403)))
        }
        var queryItems: [URLQueryItem] = []
        
        request.queryItems.forEach {
            let urlQueryItem = URLQueryItem(name: $0.key, value: $0.value)
            queryItems.append(urlQueryItem)
        }
        
        request.queryItemsArray.forEach { dict in
            dict.value.forEach {
                let urlQueryItem = URLQueryItem(name: dict.key, value: $0)
                queryItems.append(urlQueryItem)
            }
        }
        
        urlComponent.queryItems = queryItems
        var cs = CharacterSet.urlQueryAllowed
        cs.remove("+")

        urlComponent.percentEncodedQuery = queryItems.compactMap {
            guard let value = $0.value else {
                return nil
            }
            return $0.name.addingPercentEncoding(withAllowedCharacters: cs)!
            + "=" + value.addingPercentEncoding(withAllowedCharacters: cs)!
        }.joined(separator: "&")
        
        
        guard let url = urlComponent.url else {
            return completion(.failure(.init(error: "Invalid Endpoint", code: 403)))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers
        urlRequest.httpBody = request.bodyData
        urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
        urlRequest.timeoutInterval = request.timeout
        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            self.removeTask(id: requestId)
            if let error = error {
                return completion(.failure(.init(error: ErrorHandler.string(for: (error as NSError).code) ?? error.localizedDescription, code: (error as NSError).code)))
            }
            
            guard let response = response as? HTTPURLResponse, 200..<300 ~= response.statusCode else {
                if let response = response as? HTTPURLResponse, let errorStr = ErrorHandler.string(for: response.statusCode) {
                    return completion(.failure(.init(error: errorStr, code: response.statusCode)))
                }
                
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let response = try? decoder.decode(ErrorResponse.self, from: data)
                    var userData: [String: Any]?
                    
                    return completion(.failure(.init(error: response?.message ??  "Bad response", code: response?.statusCode ?? 0, userData: userData)))
                }
                return completion(.failure(.init(error: "Bad response", code: 400)))
            }
            
            guard let data = data else {
                return completion(.failure(.init(error: "Bad response", code: 400)))
            }
            
            do {
                let result = try request.decode(data)
                completion(.success(result: result))

            } catch let error as NSError {
                completion(.failure(.init(error: error.localizedDescription, code: error.code)))
            }
        }
        tasksQueue.sync {
            self.tasks[requestId] = task
        }
        task.resume()
    }

    public func cancelTask(id: String) {
        tasksQueue.sync {
            self.tasks[id]?.cancel()
            self.tasks.removeValue(forKey: id)
        }
    }
    
    public func cancelAllExistingTask() {
        tasksQueue.sync { [weak self] in
            guard let self = self else { return }
            self.tasks.keys.forEach { id in
                self.tasks[id]?.cancel()
                self.tasks.removeValue(forKey: id)
            }
            
        }
    }
    
    private func removeTask(id: String) {
        _ = tasksQueue.sync {
            self.tasks.removeValue(forKey: id)
        }
    }
}

private class ErrorResponse: Codable {
    enum CodingKeys:  String, CodingKey {
        case statusCode
        case message
    }
    
    let statusCode: Int
    let message: String
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        statusCode = try values.decode(Int.self, forKey: .statusCode)
        
        if let message = (try? values.decode(String.self, forKey: .message)) {
            self.message = message
        } else if let messages = (try? values.decode([String].self, forKey: .message)) {
            message = messages.reduce("", { partialResult, value in
                if !partialResult.isEmpty {
                    return "\(partialResult)\n\(value)"
                }
                return value
            })
        } else {
            message = "Bad response"
        }
    }
}


public class ErrorHandler {
    public enum ErrorCode: Int {
        case tooManyRequest = 429
        case forbiddenResource = 403
        case cancelled = -999
        case timeOut = -1001
        case cannotConnectToHost = -1004
        case connectionLost = -1005
        case notConnectedToInternet = -1009
        case noInternetConnection = -1020
        
        public var code: Int {
            rawValue
        }
        
        public var description: String {
            switch self {
            case .noInternetConnection:
                return "No Internet Connection"
            case .tooManyRequest:
                return "Too many requests. Please try again later."
            case .cancelled:
                return "cancelled"
            case .connectionLost:
                return "Network connection was lost"
            case .notConnectedToInternet:
                return "No Internet Connection"
            case .forbiddenResource:
                return "Forbidden Resource"
            case .cannotConnectToHost:
                return "Could not connect to the server"
            case .timeOut:
                return "The request timed out"
            }
        }
        
        public static func isInternetConnectionError(code: Int) -> Bool {
            guard let error = ErrorCode(rawValue: code) else {
                return false
            }
            
            switch error {
            case .noInternetConnection,
                    .connectionLost,
                    .notConnectedToInternet,
                    .cannotConnectToHost,
                    .timeOut:
                return true
            default:
                return false
            }
        }
    }
    
    static func string(for code: Int) -> String? {
        if code == ErrorCode.forbiddenResource.code {
            return nil
        }
        if let errorCode = ErrorCode(rawValue: code) {
            return errorCode.description
        }
        return nil
    }
}
