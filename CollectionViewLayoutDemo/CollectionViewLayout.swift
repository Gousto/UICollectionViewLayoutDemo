import UIKit

// MARK: CollectionViewGridLayoutInvalidationContext

class CollectionViewGridLayoutInvalidationContext: UICollectionViewLayoutInvalidationContext {
    var invalidatedBecauseOfBoundsChange: Bool = false
}

// MARK: CollectionViewGridLayoutDelegate

@objc protocol CollectionViewGridLayoutDelegate: class {
    @objc func collectionView(_ collectionView: UICollectionView, gridLayout: UICollectionViewLayout, estimatedHeightForItemAt indexPath: IndexPath) -> CGFloat
}

// MARK: CollectionViewGridLayout

class CollectionViewGridLayout: UICollectionViewLayout {

    // MARK: Delegate

    weak var delegate: CollectionViewGridLayoutDelegate?

    // MARK: Variables

    @IBInspectable var estimatedRowHeight: CGFloat = 500

    private var layoutAttributesForItems: [CollectionViewGridLayoutAttribute] = []

    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }

        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }

    private var numberOfColumns: Int {
        guard let collectionView = collectionView else {
            return 0
        }

        let preferredContentSizeCategory = UIApplication.shared.preferredContentSizeCategory
        let suggestedColumns = Int(collectionView.frame.width / RecipeListCell.suggestedSize(for: preferredContentSizeCategory).width)

        if suggestedColumns == 0 && collectionView.frame.width > 0 {
            return 1
        } else {
            return suggestedColumns
        }
    }

    private var cellWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }

        return floor((collectionView.frame.width - CGFloat(numberOfColumns - 1)) / CGFloat(numberOfColumns) - 1)
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override class var invalidationContextClass: AnyClass {
        return CollectionViewGridLayoutInvalidationContext.self
    }

    // MARK: Methods

    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        let invalidationContext = context as! CollectionViewGridLayoutInvalidationContext

        super.invalidateLayout(with: invalidationContext)

        if invalidationContext.invalidatedBecauseOfBoundsChange || invalidationContext.invalidateEverything {
            layoutAttributesForItems = []
        }
    }

    override func prepare() {
        guard layoutAttributesForItems.isEmpty else {
            return
        }

        initalLayout()
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []

        for attributes in layoutAttributesForItems {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else {
            return false
        }

        guard newBounds.size != collectionView.frame.size else {
            return false
        }

        return true
    }

    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! CollectionViewGridLayoutInvalidationContext

        context.invalidatedBecauseOfBoundsChange = true

        return context
    }

    override func shouldInvalidateLayout(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> Bool {

        if preferredAttributes.frame.size.height == originalAttributes.frame.size.height && originalAttributes.frame.size.width == cellWidth {
            return false
        }

        return true
    }

    override func invalidationContext(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forPreferredLayoutAttributes: preferredAttributes, withOriginalAttributes: originalAttributes) as! CollectionViewGridLayoutInvalidationContext

        let contentHeightAdjustment: CGFloat = preferredAttributes.frame.size.height - originalAttributes.frame.size.height

        let attributes = layoutAttributesForItems[originalAttributes.indexPath.row]
        attributes.frame.size.height += contentHeightAdjustment
        attributes.frame.size.width = cellWidth

        context.invalidateItems(at: [attributes.indexPath])

        layoutAttributesForItems[originalAttributes.indexPath.row] = attributes

        for (index, layoutAttributesForItem) in layoutAttributesForItems.enumerated() {
            if index <= originalAttributes.indexPath.row {
                continue
            }

            let currentColumn = layoutAttributesForItem.column

            if currentColumn == attributes.column {
                layoutAttributesForItem.frame.origin.y += contentHeightAdjustment
                context.invalidateItems(at: [layoutAttributesForItem.indexPath])
            }
        }

        let count = layoutAttributesForItems.count - 1

        if count < numberOfColumns {
            let attributesSlice = layoutAttributesForItems[count...layoutAttributesForItems.count - 1]
            let attributes = Array(attributesSlice)
            collectionViewHeight(from: attributes, context: context)
        } else {
            let attributesSlice = layoutAttributesForItems[(count - numberOfColumns + 1)...count]
            let attributes = Array(attributesSlice)
            collectionViewHeight(from: attributes, context: context)
        }

        return context
    }

    private func collectionViewHeight(from lastRowCellAttributes: [UICollectionViewLayoutAttributes], context: CollectionViewGridLayoutInvalidationContext) {
        let maxColumn = lastRowCellAttributes.max { (attribute1, attribute2) -> Bool in
            attribute1.frame.maxY < attribute2.frame.maxY
        }

        let diff = contentHeight - maxColumn!.frame.maxY

        context.contentSizeAdjustment = CGSize(width: 0, height: diff)
        contentHeight = maxColumn!.frame.maxY
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesForItems[indexPath.item]
    }

    func initalLayout() {
        layoutAttributesForItems = []

        guard let collectionView = collectionView,
            let dataSource = collectionView.dataSource else {
                return
        }

        contentHeight = collectionView.contentInset.top

        let numberOfSections = dataSource.numberOfSections?(in: collectionView) ?? 1
        let columnWidth = contentWidth / CGFloat(numberOfColumns)

        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        var xOffset = [CGFloat]()
        for column in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }

        for section in (0..<numberOfSections) {

            for row in (0..<dataSource.collectionView(collectionView, numberOfItemsInSection: section)) {
                let indexPath = IndexPath(row: row, section: section)

                let estimatedHeightForItem: CGFloat
                if let height = delegate?.collectionView(collectionView, gridLayout: self, estimatedHeightForItemAt: indexPath) {
                    estimatedHeightForItem = height
                } else {
                    estimatedHeightForItem = estimatedRowHeight
                }

                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: cellWidth, height: estimatedHeightForItem)
                let insetFrame = frame.insetBy(dx: collectionView.contentInset.left, dy: collectionView.contentInset.right)

                let attributes = CollectionViewGridLayoutAttribute(forCellWith: indexPath)
                attributes.frame = insetFrame
                attributes.column = column
                layoutAttributesForItems.append(attributes)

                contentHeight = max(contentHeight, frame.maxY)
                yOffset[column] = yOffset[column] + estimatedHeightForItem

                column = column < (numberOfColumns - 1) ? (column + 1) : 0
            }
        }

        contentHeight += collectionView.contentInset.bottom
    }
}
