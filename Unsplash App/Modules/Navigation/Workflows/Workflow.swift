import Foundation
import RIBs
import RxSwift

enum WorkflowPath {
    case photoDetails(model: UnsplashDM.Photo)
    
    case noop
}

public class RoutingWorkflow: Workflow<RoutableActionableItem> {
    public init?(url: URL) {
        super.init()

        let path = parse(from: url)
        switch(path) {
            
        case .photoDetails(let model):
            onStep { (item: RoutableActionableItem) -> Observable<(RoutableActionableItem, ())> in
                item.showPhotoDetails(model: model)
            }
            .commit()
            
        case .noop:
            return nil
        }
    }

    private func parse(from url: URL) -> WorkflowPath {
        typealias Route = InAppURLSchemeHelper.Route
        typealias Keys = InAppURLSchemeHelper.Keys
        
        let components = URLComponents(string: url.absoluteString)
                
        if components?.path == Route.photoDetails.rawValue,
           let modelId = components?.queryItems?.first(where: { $0.name == Keys.modelId.rawValue })?.value,
           let model = InAppURLStorage.removeValue(for: modelId) as? UnsplashDM.Photo {
            return .photoDetails(model: model)
        }
        
        return .noop
    }
}
