//
//  TableViewController.swift
//  MovingColorsApp
//
//  Created by Imanou on 03/11/2017.
//  Copyright © 2017 Imanou. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var colors: [UIColor] = [.red, .blue, .green, .orange, .brown, .magenta, .purple, .yellow, .cyan, .gray]
    
    override func viewDidLoad() {
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.rowHeight = 80
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = colors[indexPath.row]
        return cell
    }
    
}

extension TableViewController: UITableViewDragDelegate {
    
    // only non-optional stub
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let itemProvider = NSItemProvider(object: colors[indexPath.row])
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }

    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIColor.self)
    }

    // Usefull if you want to test if session is local or not and to proceed with a copy or a move
    // Other cells don't move under a dragging cell if not implemented
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        let dropOperation = session.localDragSession == nil ? UIDropOperation.copy : .move
        return UITableViewDropProposal(operation: dropOperation, intent: .insertAtDestinationIndexPath)
    }
    
}

extension TableViewController: UITableViewDropDelegate {
    
    // only non-optional stub
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
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
                    let updates: () -> Void = {
                        let color = self.colors.remove(at: sourceIndexPath.row)
                        self.colors.insert(color, at: destinationIndexPath.row)
                        self.colors.replace
                        self.tableView.deleteRows(at: [sourceIndexPath], with: .automatic)
                        self.tableView.insertRows(at: [destinationIndexPath], with: .automatic)
                    }
                    tableView.performBatchUpdates(updates, completion: nil)
                    
                    
                    // Animate the drag item to the newly inserted item in the collection view.
                    coordinator.drop(item.dragItem, toRowAt: destinationIndexPath)
                }
            } else {
                // Moving items from somewhere else in this app.
                //moveItems(to: destinationIndexPath, with: coordinator)
            }
        default:
            break
        }
    }
    
}
