//
//  RecipeListCollectionViewController.swift
//  CollectionViewLayoutDemo
//
//  Created by Kiera O'Reilly on 24/06/2018.
//  Copyright © 2018 Kiera. All rights reserved.
//

import UIKit

class RecipeListViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!

    fileprivate var isTargetContentOffsetAdjusted: Bool = false
    fileprivate var indexPathForViewSizeTransition: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        (collectionView.collectionViewLayout as! CollectionViewGridLayout).delegate = self

        collectionView.register(UINib(nibName: "RecipeListCell", bundle: nil), forCellWithReuseIdentifier: "RecipeListCell")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        reloadWithNewData()
    }
    
    // MARK: - Rotation
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // To adjust the scroll view we need to get first recipe that is being displayed.
        indexPathForViewSizeTransition = collectionView.indexPathForItem(at: CGPoint(x: 0, y: collectionView.contentOffset.y))
        
        super.viewWillTransition(to: size, with: coordinator)
        
        self.isTargetContentOffsetAdjusted = false
        
        coordinator.animate(alongsideTransition: { (_) in
            // The target offset isn't called when coming in and out of split view on iPad, so we manually do it here.
            guard self.isTargetContentOffsetAdjusted == false else {
                return
            }
            
            guard let indexPathForViewSizeTransition = self.indexPathForViewSizeTransition,
                let layoutAttributes = self.collectionView.layoutAttributesForItem(at: indexPathForViewSizeTransition) else {
                    return
            }
            
            self.collectionView.contentOffset = CGPoint(x: 0, y: layoutAttributes.frame.origin.y)
            
        }, completion: { (_) in
            self.isTargetContentOffsetAdjusted = false
            self.indexPathForViewSizeTransition = nil
            let context = CollectionViewGridLayoutInvalidationContext()
            context.invalidatedBecauseOfBoundsChange = true
            self.collectionView.collectionViewLayout.invalidateLayout(with: context)
        })
    }
    
    @objc func reloadWithNewData() {
        DispatchQueue.main.async(execute: {
            self.collectionView.reloadData()
        })
    }
}

// MARK: - CollectionViewGridLayoutDelegate

extension RecipeListViewController: CollectionViewGridLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, gridLayout: UICollectionViewLayout, estimatedHeightForItemAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension RecipeListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    @objc internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 21
    }
    
    @objc internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell: RecipeListCell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipeListCell", for: indexPath) as? RecipeListCell else {
            return UICollectionViewCell()
        }
        
        if indexPath.row % 2 == 0 {
            cell.configure(withTitle: "Mac and cheese")
        } else if indexPath.row % 3 == 0 {
            cell.configure(withTitle: "Baked Beef Meatballs With Tomato Sauce & Linguine")
        } else {
            cell.configure(withTitle: "Duck Breast, Sweet Potato Purée, Pomegranate Sauce & Roast Tenderstem")
        }
        
        return cell
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        guard let indexPathForViewSizeTransition = indexPathForViewSizeTransition,
            let layoutAttributes = collectionView.layoutAttributesForItem(at: indexPathForViewSizeTransition) else {
                return proposedContentOffset
        }
        
        // We have adjusted the target offset so don't do it else where.
        isTargetContentOffsetAdjusted = true
        
        return CGPoint(x: 0, y: layoutAttributes.frame.origin.y)
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Tapped")
    }
}
