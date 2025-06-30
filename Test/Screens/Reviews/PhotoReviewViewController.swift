import UIKit

final class PhotoReviewViewController: UIViewController {
    private let photoURL: String
    private let photoView: PhotoReviewView
    
    init(photoURL: String) {
        self.photoURL = photoURL
        self.photoView = PhotoReviewView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = photoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        loadPhoto()
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(dismissScreen)
        )
    }
    
    @objc private func dismissScreen() {
        dismiss(animated: true)
    }
    
    private func loadPhoto() {
        ImageLoader.shared.loadImage(from: photoURL) { [weak self] image in
            DispatchQueue.main.async {
                self?.photoView.setImage(image ?? UIImage(named: "placeholderPhoto"))
            }
        }
    }
}
