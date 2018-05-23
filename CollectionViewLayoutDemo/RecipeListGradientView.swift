import UIKit

class RecipeListGradientView: UIView {

    override public class var layerClass: Swift.AnyClass {
        return CAGradientLayer.self
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        guard let gradientLayer = layer as? CAGradientLayer else {
            return
        }

        gradientLayer.colors = [UIColor(red: 1, green: 1, blue: 1, alpha: 0).cgColor,
                                UIColor(red: 1, green: 1, blue: 1, alpha: 0.75).cgColor,
                                UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor,
                                UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor]
        gradientLayer.locations = [0, 0.3, 0.9, 1]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.1)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.95)
    }
}
