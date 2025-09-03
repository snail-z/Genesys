//
//  CenteringFlowLayout.swift
//  Genesys
//
//  Created by Aholt on 2025/9/3.
//

import UIKit

class DynamicSpacingFlowLayout: UICollectionViewFlowLayout {
    
    var sideInset: CGFloat = 20
    
    override init() {
        super.init()
        scrollDirection = .horizontal
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        
        let pageWidth = collectionView.bounds.width
        guard pageWidth > 0 else { return super.layoutAttributesForElements(in: rect) }

        let itemCount = collectionView.numberOfItems(inSection: 0)
        let index = Int(collectionView.contentOffset.x / pageWidth)

        let left = pageWidth * CGFloat(index)
        let leftNext = pageWidth * CGFloat(index + 1)
        let centerX = pageWidth * (CGFloat(index) + 0.5)
        let centerXNext = pageWidth * (CGFloat(index + 1) + 0.5)
        let right = pageWidth * (CGFloat(index) + 1)
        let rightNext = pageWidth * (CGFloat(index + 1) + 1)

        let percent = (collectionView.contentOffset.x - left) / pageWidth

        var pre: UICollectionViewLayoutAttributes?
        var current: UICollectionViewLayoutAttributes?
        var next: UICollectionViewLayoutAttributes?
        var nextNext: UICollectionViewLayoutAttributes?
        
        if index >= 0 && index < itemCount { current = layoutAttributesForItem(at: IndexPath(row: index, section: 0)) }
        if index > 0 { pre = layoutAttributesForItem(at: IndexPath(row: index - 1, section: 0)) }
        if index < itemCount - 1 { next = layoutAttributesForItem(at: IndexPath(row: index + 1, section: 0)) }
        if index < itemCount - 2 { nextNext = layoutAttributesForItem(at: IndexPath(row: index + 2, section: 0)) }
        
        var attributesArray = [UICollectionViewLayoutAttributes]()
        
        if let pre = pre {
            let preStartX = left + sideInset - pre.frame.width
            let preFinalX = left - pre.frame.width
            pre.frame.origin.x = preStartX + (preFinalX - preStartX) * percent
            pre.isHidden = false
            attributesArray.append(pre)
        }
        
        if let current = current {
            let currentStartX = centerX - current.frame.width / 2.0
            let currentFinalX = leftNext + sideInset - current.frame.width
            current.frame.origin.x = currentStartX + (currentFinalX - currentStartX) * percent
            current.isHidden = false
            attributesArray.append(current)
        }
        
        if let next = next {
            let nextStartX = right - sideInset
            let nextFinalX = centerXNext - next.frame.width / 2.0
            next.frame.origin.x = nextStartX + (nextFinalX - nextStartX) * percent
            next.isHidden = false
            attributesArray.append(next)
        }
        
        if let nextNext = nextNext {
            let nextNextStartX = rightNext
            let nextNextFinalX = rightNext - sideInset
            nextNext.frame.origin.x = nextNextStartX + (nextNextFinalX - nextNextStartX) * percent
            nextNext.isHidden = false
            attributesArray.append(nextNext)
        }
        
        for item in attributesArray {
            item.center.y = collectionView.frame.height / 2.0
        }
        
        return attributesArray
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        let itemCount = collectionView.numberOfItems(inSection: 0)
        return CGSize(width: CGFloat(itemCount) * collectionView.frame.width, height: collectionView.frame.height)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return collectionView?.bounds.size != newBounds.size || collectionView?.bounds.origin != newBounds.origin
    }
}
