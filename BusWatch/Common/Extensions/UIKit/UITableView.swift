//
//  UITableView.swift
//  BusWatch
//
//  Created by Tyler Madonna on 5/3/20.
//  Copyright © 2020 Tyler Madonna. All rights reserved.
//

import UIKit

extension UITableView {

    func update<T>(oldData: [T], newData: [T], setNewDataBlock: ([T]) -> Void) where T: Hashable {
        let diff = newData.difference(from: oldData)

        var inserts: [IndexPath] = []
        var deletes: [IndexPath] = []
        var moves: [(from: IndexPath, to: IndexPath)] = []

        for update in diff.inferringMoves() {
            switch update {
            case .remove(let offset, _, let move):
                if let move = move {
                    moves.append((IndexPath(row: offset, section: 0), IndexPath(row: move, section: 0)))
                } else {
                    deletes.append(IndexPath(row: offset, section: 0))
                }
            case .insert(let offset, _, let move):
                // If there's no move, it's a true insertion and not the result of a move.
                if move == nil {
                    inserts.append(IndexPath(row: offset, section: 0))
                }
            }
        }

        performBatchUpdates({
            setNewDataBlock(newData)

            deleteRows(at: deletes, with: .automatic)
            insertRows(at: inserts, with: .automatic)
            moves.forEach { move in
                moveRow(at: move.from, to: move.to)
            }
        }, completion: nil)
    }
}
