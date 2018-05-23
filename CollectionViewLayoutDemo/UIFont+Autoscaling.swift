import UIKit

extension UIFont {
    class func autoScalingFont(named fontFamily: String, defaultPointSize pointSize: CGFloat) -> UIFont {
        let font = UIFont(name: fontFamily, size: pointSize)
        return UIFontMetrics.default.scaledFont(for: font!)
    }
}
