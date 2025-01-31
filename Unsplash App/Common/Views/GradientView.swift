import UIKit

public class GradientView: UIView {
    
    public override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    public var gradientLayer: CAGradientLayer {
        return self.layer as! CAGradientLayer
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        self.gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        self.gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
    }
}

public extension GradientView {
    enum Position {
        case topBottom
        case bottomTop
        
        public var startPoint: CGPoint {
            switch self {
            case .bottomTop:
                return CGPoint(x: 0.5, y: 1)
            case .topBottom:
                return CGPoint(x: 0.5, y: 0.0)
            }
        }
        
        public var endPoint: CGPoint {
            switch self {
            case .bottomTop:
                return CGPoint(x: 0.5, y: 0.0)
            case .topBottom:
                return CGPoint(x: 0.5, y: 1)
            }
        }
    }
    
    func applyGradient(position: Position, colors: [CGColor]? = nil) {
        gradientLayer.endPoint = position.endPoint
        gradientLayer.startPoint = position.startPoint
        
        if colors == nil {
            gradientLayer.colors = [UIColor.black.withAlphaComponent(0.8).cgColor, UIColor.black.withAlphaComponent(0).cgColor]
        } else {
            gradientLayer.colors = colors
        }
    }
}
