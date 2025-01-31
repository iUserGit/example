import IGListKit

class SearchPhotosPhotoController: ListSectionController {
    var viewModel: SearchPhotos.ViewModel.Image?
    
    override init() {
        super.init()
        inset = .init(top: 0, left: 0, bottom: 10, right: 0)
        minimumInteritemSpacing = 10
    }
    
    override func didUpdate(to object: Any) {
        viewModel = object as? SearchPhotos.ViewModel.Image
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext!.dequeueReusableCell(of: SearchPhotosPhotoCell.self, withReuseIdentifier: "SearchPhotosPhotoCell", for: self, at: index) as! SearchPhotosPhotoCell
        cell.viewModel = viewModel
        return cell
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        guard let context = collectionContext else { return .zero }
            
        let maxCellWidth: CGFloat = 150
        var column = Int(context.containerSize.width / maxCellWidth)
        if column < 2 {
            column = 2
        }
        
        let width = (context.containerSize.width - CGFloat(column - 1) * minimumInteritemSpacing) / CGFloat(column)
        return CGSize(width: width, height: width)
    }
    
    override func didSelectItem(at index: Int) {
        guard let model = viewModel?.model else {
            return
        }
        viewModel?.rxImageSelected.onNext(model)
    }
}
