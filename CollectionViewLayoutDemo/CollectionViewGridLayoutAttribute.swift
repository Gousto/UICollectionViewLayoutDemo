// MARK: CollectionViewGridLayoutAttribute

import UIKit

class CollectionViewGridLayoutAttribute: UICollectionViewLayoutAttributes {
    var column: Int = 0

    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! CollectionViewGridLayoutAttribute
        copy.column = column
        return copy
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let attributes = object as? CollectionViewGridLayoutAttribute else {
            return false
        }

        guard super.isEqual(object) else {
            return false
        }

        return column == attributes.column
    }
}
