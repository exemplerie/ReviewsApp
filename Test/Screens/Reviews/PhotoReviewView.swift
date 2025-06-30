import UIKit

final class PhotoReviewView: UIView {
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isScrollEnabled = false
        scrollView.bounces = false
        scrollView.contentInsetAdjustmentBehavior = .never
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var initialImageFrame: CGRect?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(_ image: UIImage?) {
        imageView.image = image
        updateImageViewFrame()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        updateImageViewFrame()
    }
    
    private func setupView() {
        backgroundColor = .white
        scrollView.delegate = self
        
        addSubview(scrollView)
        scrollView.addSubview(imageView)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapGesture)
    }
    
    private func updateImageViewFrame() {
        guard let image = imageView.image else {
            imageView.frame = bounds
            return
        }
        
        let imageSize = image.size
        let screenSize = bounds.size
        
        let imageAspect = imageSize.width / imageSize.height
        let screenAspect = screenSize.width / screenSize.height
        
        var imageViewSize = screenSize
        
        if imageAspect > screenAspect {
            imageViewSize.height = screenSize.width / imageAspect
        } else {
            imageViewSize.width = screenSize.height * imageAspect
        }
        
        let x = (screenSize.width - imageViewSize.width) / 2
        let y = (screenSize.height - imageViewSize.height) / 2
        
        let newFrame = CGRect(x: x, y: y, width: imageViewSize.width, height: imageViewSize.height)
        imageView.frame = newFrame
        
        if initialImageFrame == nil {
            initialImageFrame = newFrame
        }
        
        scrollView.contentSize = imageViewSize
        
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            scrollView.contentOffset = .zero
        }
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            scrollView.contentOffset = .zero
        } else {
            let locationInView = gesture.location(in: imageView)
            
            if imageView.bounds.contains(locationInView) {
                let zoomRect = calculateZoomRect(for: locationInView, with: scrollView.maximumZoomScale)
                scrollView.zoom(to: zoomRect, animated: true)
            }
        }
    }
    
    private func calculateZoomRect(for location: CGPoint, with scale: CGFloat) -> CGRect {
        let size = CGSize(
            width: imageView.bounds.width / scale,
            height: imageView.bounds.height / scale
        )
        
        let origin = CGPoint(
            x: location.x - (size.width / 2),
            y: location.y - (size.height / 2)
        )
        
        return CGRect(origin: origin, size: size)
    }
}

extension PhotoReviewView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollView.isScrollEnabled = scrollView.zoomScale > scrollView.minimumZoomScale
        
        let boundsSize = scrollView.bounds.size
        var frameToCenter = imageView.frame
        
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }
        
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }
        
        imageView.frame = frameToCenter
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scale == scrollView.minimumZoomScale {
            scrollView.isScrollEnabled = false
            if let initialFrame = initialImageFrame {
                imageView.frame = initialFrame
            }
            scrollView.contentOffset = .zero
        }
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.isScrollEnabled = true
    }
}
