
import IGListKit
import RxSwift

enum SearchPhotos {
    enum Model {
        struct Image: Equatable {
            static func == (lhs: SearchPhotos.Model.Image, rhs: SearchPhotos.Model.Image) -> Bool {
                return lhs.id == rhs.id
            }
            
            let domainModel: UnsplashDM.Photo
            
            var id: String {
                domainModel.id
            }
            
            var thumb: URL? {
                URL(string: domainModel.urls?.thumb ?? "")
            }
        }
        
        class State {
            let rxImageSelected: PublishSubject<Model.Image> = .init()
            
            let searchLimit: Int = 20
            var nextPage: Int = 1
            var canNextFetch: Bool = true
            
            var models: [Image] = []
            var searchText: String = ""
        }
    }
    
    enum ViewModel {
        enum Transition {
            case data(model: Model.State)
            case error(message: String?)
        }
        
        class Image: ListDiffable {
            let model: Model.Image
            let rxImageSelected: PublishSubject<Model.Image>
            
            init(model: Model.Image, rxImageSelected: PublishSubject<Model.Image>) {
                self.model = model
                self.rxImageSelected = rxImageSelected
            }
            
            func diffIdentifier() -> NSObjectProtocol {
                return "Image_\(model.id)" as NSString
            }
            
            func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
                guard let object = object as? Image else {
                    return false
                }
                return object.model == model
            }
        }
    }
}

