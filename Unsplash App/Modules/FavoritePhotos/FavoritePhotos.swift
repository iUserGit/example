import IGListKit
import RxSwift

enum FavoritePhotos {
    enum Model {
        class State {
            let rxImageSelected: PublishSubject<SearchPhotos.Model.Image> = .init()
            
            var models: [SearchPhotos.Model.Image] = []
        }
    }
    
    enum ViewModel {
        enum Transition {
            case data(model: Model.State)
            case error(message: String?)
        }
    }
}

