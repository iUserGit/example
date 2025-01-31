import RIBs

protocol SearchPhotosDependency: Dependency {
    var dataProvider: any DataProviderProtocol { get }
    var searchService: any SearchPhotosServiceProtocol { get }
}

class SearchPhotosDependencyImpl: SearchPhotosDependency {
    let dataProvider: any DataProviderProtocol
    let searchService: any SearchPhotosServiceProtocol
    
    init(dataProvider: any DataProviderProtocol) {
        self.dataProvider = dataProvider
        self.searchService = SearchPhotosService(dataProvider: dataProvider)
    }
}

final class SearchPhotosComponent: Component<SearchPhotosDependency> {
    var dataProvider: DataProviderProtocol {
        dependency.dataProvider
    }
    
    var searchService: any SearchPhotosServiceProtocol {
        dependency.searchService
    }
}

// MARK: - Builder

protocol SearchPhotosBuildable: Buildable {
    func build(withListener listener: SearchPhotosListener) -> SearchPhotosRouting
}

final class SearchPhotosBuilder: Builder<SearchPhotosDependency>, SearchPhotosBuildable {

    override init(dependency: SearchPhotosDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: SearchPhotosListener) -> SearchPhotosRouting {
        let component = SearchPhotosComponent(dependency: dependency)
        let viewController = SearchPhotosViewController()
        let interactor = SearchPhotosInteractor(presenter: viewController, component: component)
        interactor.listener = listener
        return SearchPhotosRouter(interactor: interactor, viewController: viewController)
    }
}
