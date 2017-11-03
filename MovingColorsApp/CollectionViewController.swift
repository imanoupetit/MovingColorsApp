//
//  CollectionViewController.swift
//  MovingColorsApp
//
//  Created by Imanou on 03/11/2017.
//  Copyright © 2017 Imanou. All rights reserved.
//

import UIKit

class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let idealCellWidth: CGFloat = 100
    let margin: CGFloat = 5
    
    var colors: [UIColor] = [.red, .blue, .green, .orange, .brown, .magenta, .purple, .yellow, .cyan, .gray]
    
    override func viewDidLoad() {
        collectionView?.backgroundColor = .groupTableViewBackground
        collectionView?.contentInsetAdjustmentBehavior = .always
        
        guard let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.minimumLineSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        
        collectionView?.dragDelegate = self
        collectionView?.dropDelegate = self
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = colors[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        let availableWidth = collectionView.frame.width - collectionView.safeAreaInsets.left - collectionView.safeAreaInsets.right - flowLayout.sectionInset.left - flowLayout.sectionInset.right
        let idealNumberOfCells = (availableWidth + flowLayout.minimumInteritemSpacing) / (idealCellWidth + flowLayout.minimumInteritemSpacing)
        let numberOfCells = idealNumberOfCells.rounded(.down)
        let cellWidth = (availableWidth + flowLayout.minimumInteritemSpacing) / numberOfCells - flowLayout.minimumInteritemSpacing
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
        super.viewWillTransition(to: size, with: coordinator)
    }
    
}
extension CollectionViewController: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let itemProvider = NSItemProvider(object: colors[indexPath.row])
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
    
    //Adds the specified items to an existing drag session.
    //Implement this method when you want to allow the user to add items to an active drag session. If you do not implement this method, taps in the collection view trigger the selection of items or other behaviors.
    /*
     func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        let itemProvider = NSItemProvider(object: colors[indexPath.row])
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
     }
     */
    
    /*
     //Use this method to customize the appearance of the item during drags. If you do not implement this method or if you implement it and return nil, the collection view uses the cell's visible bounds to create the preview.
     func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        return ...
     }
     */
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIColor.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let dropOperation = session.localDragSession == nil ? UIDropOperation.copy : .move
        return UICollectionViewDropProposal(operation: dropOperation, intent: .insertAtDestinationIndexPath)
    }
    
}

extension CollectionViewController: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        switch coordinator.proposal.operation {
        case .copy:
            // Receiving items from another app.
            break
        case .move:
            let items = coordinator.items
            if items.contains(where: { $0.sourceIndexPath != nil }) {
                if items.count == 1, let item = items.first {
                    // Reordering a single item from this collection view.
                    guard let sourceIndexPath = item.sourceIndexPath else { return }
                    
                    // Perform batch updates to update the photo library backing store and perform the delete & insert on the collection view.
                    collectionView.performBatchUpdates({
                        let color = colors.remove(at: sourceIndexPath.row)
                        colors.insert(color, at: destinationIndexPath.row)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                    })
                    
                    // Animate the drag item to the newly inserted item in the collection view.
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            } else {
                // Moving items from somewhere else in this app.
                //moveItems(to: destinationIndexPath, with: coordinator)
            }
        default:
            break
        }
    }
    
    /*
     func collectionView(_ collectionView: UICollectionView, dropPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        return ...
     }
     */
    
}
