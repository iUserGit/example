import Foundation

public struct ResultError {
    public let error: String?
    public let code: Int
    public let userData: [String: Any]?
    
    public init(error: String?, code: Int, userData: [String: Any]? = nil) {
        self.error = error
        self.code = code
        self.userData = userData
    }
}

public enum Result<T> {
    case success(result: T)
    case failure(ResultError)
}
