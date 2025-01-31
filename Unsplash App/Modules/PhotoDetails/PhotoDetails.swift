
import Foundation

import IGListKit
import RxSwift
import RxCocoa

enum PhotoDetails {
    enum Model {
        struct Image {
            let domainModel: UnsplashDM.Photo
            
            var url: URL? {
                URL(string: domainModel.urls?.regular ?? "")
            }
        }
        
        class State {
            let image: Image
           
            let rxIsFavorite: BehaviorRelay<Bool>
            
            init(model: Image, isFavorite: Bool) {
                self.image = model
                self.rxIsFavorite = .init(value: isFavorite)
            }
        }
    }
    
    enum ViewModel {
        enum Transition {
            case data(model: Model.State)
            case error(message: String?)
        }
    }
}

