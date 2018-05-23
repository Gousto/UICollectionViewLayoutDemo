import UIKit

class RecipeListCell: UICollectionViewCell {

    @IBOutlet var mainContentView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timeImageView: UIImageView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var shadowView: UIView!

    static func suggestedSize(for sizeCategory: UIContentSizeCategory) -> CGSize {

        switch sizeCategory {
    case .extraSmall, .small, .medium, .large, .extraLarge, .extraExtraLarge, .extraExtraExtraLarge:
            return CGSize(width: 320, height: 340)
        case .accessibilityMedium:
            return CGSize(width: 360, height: 340)
        case .accessibilityLarge:
            return CGSize(width: 400, height: 340)
        case .accessibilityExtraLarge, .accessibilityExtraExtraLarge, .accessibilityExtraExtraExtraLarge:
            return CGSize(width: 450, height: 340)
        default:
            return CGSize(width: 320, height: 340)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        shadowView.layer.cornerRadius = 15
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowColor = UIColor.darkGray.cgColor
        shadowView.layer.shadowOffset = CGSize(width: -0.5, height: 0.5)
        shadowView.layer.shadowOpacity = 0.3
        shadowView.layer.shouldRasterize = true
        shadowView.layer.rasterizationScale = UIScreen.main.scale
        shadowView.layer.shadowRadius = 15

        mainContentView.layer.cornerRadius = 15
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        shadowView.layer.shadowPath = UIBezierPath(rect: mainContentView.bounds).cgPath
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()

        let preferredLayoutAttributes = layoutAttributes

        var fittingSize = UILayoutFittingCompressedSize
        fittingSize.width = preferredLayoutAttributes.size.width
        let size = systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
        var adjustedFrame = preferredLayoutAttributes.frame
        adjustedFrame.size.height = ceil(size.height)
        preferredLayoutAttributes.frame = adjustedFrame

        return preferredLayoutAttributes
    }

    func configure(withTitle title: String) {
        titleLabel.text = title
        titleLabel.font = UIFont.autoScalingFont(named: titleLabel.font.fontName,
                                                 defaultPointSize: 26)

        imageView.image = UIImage(named: "food")

        timeLabel.text = "50 mins"
        timeLabel.font = UIFont.autoScalingFont(named: timeLabel.font.fontName,
                                                defaultPointSize: 22)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = UIImage(named: "image-placeholder")
        titleLabel.text = ""
        timeLabel.text = ""
    }
}
