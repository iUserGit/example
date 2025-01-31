import UIKit
import RxSwift
import SnapKit

class SearchPhotosSearchBarView: UIView {
    private var searchTextField: UITextField!
    private var cancelButton: UIButton!
   
    private var searchButton: UIButton!
    private var clearButton: UIButton!
    
    let rxSearchTextChanged: PublishSubject<String> = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    deinit {
        updateColorUnsubscribe()
    }
    
    // MARK: - Private -
    
    private func setupUI() {
        cancelButton = .init()
        cancelButton.setTitle("Cancel", for: .normal)
       
        cancelButton.addTarget(self, action: #selector(didSelectCancel), for: .touchUpInside)
        cancelButton.alpha = 0
        addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.right.equalTo(snp.rightMargin).offset(-16)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(60)
        }
        
        searchTextField = .init()
        searchTextField.borderStyle = .none
        searchTextField.layer.cornerRadius = 8
        searchTextField.returnKeyType = .search
      
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(didChangeText(sender: )), for: .editingChanged)
        addSubview(searchTextField)
        searchTextField.snp.makeConstraints { make in
            make.left.equalTo(snp.leftMargin).offset(16)
            make.height.equalTo(34)
            make.centerY.equalToSuperview()
            make.right.equalTo(snp.rightMargin).offset(-16)
        }
        
        searchButton = UIButton(frame: .init(origin: .zero, size: .init(width: 34, height: 34)))
        
        searchButton.imageView?.contentMode = .scaleAspectFit
        searchButton.imageEdgeInsets = .init(top: 0, left: 2, bottom: 0, right: 2)
        let leftView = UIView(frame: .init(origin: .zero, size: .init(width: 34, height: 34)))
        leftView.addSubview(searchButton)

        searchTextField.leftView = leftView
        searchTextField.leftViewMode = .always
        
        clearButton = UIButton(frame: .init(origin: .zero, size: .init(width: 34, height: 34)))
       
        clearButton.imageEdgeInsets = .init(top: 0, left: 2, bottom: 0, right: 2)
        clearButton.imageView?.contentMode = .scaleAspectFit
        clearButton.addTarget(self, action: #selector(didSelectClear), for: .touchUpInside)
         
        let rightView = UIView(frame: .init(origin: .zero, size: .init(width: 34, height: 34)))
        rightView.addSubview(clearButton)
        
        searchTextField.rightView = rightView
        searchTextField.rightViewMode = .whileEditing
        
        updateColor()
        updateColorSubscribe()
    }
    
    override func updateColor() {
        searchTextField.backgroundColor = ColorScheme.current.border.withAlphaComponent(0.6)
        cancelButton.setTitleColor(ColorScheme.current.text, for: .normal)
        searchTextField.keyboardAppearance = ColorScheme.current.keyboardAppearance
        searchTextField.textColor = ColorScheme.current.text
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Search by...", attributes: [.foregroundColor: UIColor.lightGray])
        searchTextField.tintColor = ColorScheme.current.active
        searchButton.setImage(UIImage(systemName: "magnifyingglass")?.withTintColor(ColorScheme.current.active), for: .normal)
        clearButton.setImage(UIImage(systemName: "xmark")?.withTintColor(ColorScheme.current.active), for: .normal)
    }
    
    @objc private func didSelectCancel() {
        searchTextField.resignFirstResponder()
        clearText()
    }
    
    @objc private func didSelectClear() {
        clearText()
    }
    
    func clearText() {
        self.searchTextField.text = ""
        self.rxSearchTextChanged.onNext("")
        
    }
    
    @objc private func didChangeText(sender: UITextField) {
        if let text = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines), false == text.isEmpty {
            self.rxSearchTextChanged.onNext(text)
        } else {
            self.rxSearchTextChanged.onNext("")
        }
    }
}

extension SearchPhotosSearchBarView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.searchTextField.snp.updateConstraints { make in
            make.right.equalTo(snp.rightMargin).offset(-16 - 70)
        }
        
        UIView.animate(withDuration: 0.2) {
            self.cancelButton.alpha = 1
            self.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.searchTextField.snp.updateConstraints { make in
            make.right.equalTo(snp.rightMargin).offset(-16)
        }
        
        UIView.animate(withDuration: 0.2) {
            self.cancelButton.alpha = 0
            self.layoutIfNeeded()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
