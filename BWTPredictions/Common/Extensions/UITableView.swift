//
//  UITableView.swift
//  Predictions
//
//  Created by Tyler Madonna on 11/4/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import UIKit
import DifferenceKit

extension UITableView {

    func update<D: Differentiable>(
        oldData: [D],
        newData: [D],
        with animation: RowAnimation,
        setData: ([D]) -> Void,
        reloadRow: (IndexPath) -> Void
    ) {
        let stagedChangeset = StagedChangeset(source: oldData, target: newData)

        if case .none = window, let data = stagedChangeset.last?.data {
            setData(data)
            return reloadData()
        }

        for changeset in stagedChangeset {
            performBatchUpdates {
                setData(changeset.data)

                if !changeset.sectionDeleted.isEmpty {
                    deleteSections(IndexSet(changeset.sectionDeleted), with: animation)
                }

                if !changeset.sectionInserted.isEmpty {
                    insertSections(IndexSet(changeset.sectionInserted), with: animation)
                }

                if !changeset.sectionUpdated.isEmpty {
                    reloadSections(IndexSet(changeset.sectionUpdated), with: animation)
                }

                for (source, target) in changeset.sectionMoved {
                    moveSection(source, toSection: target)
                }

                if !changeset.elementDeleted.isEmpty {
                    deleteRows(at: changeset.elementDeleted.map { IndexPath(row: $0.element, section: $0.section) },
                               with: animation)
                }

                if !changeset.elementInserted.isEmpty {
                    insertRows(at: changeset.elementInserted.map { IndexPath(row: $0.element, section: $0.section) },
                               with: animation)
                }

                if !changeset.elementUpdated.isEmpty {
                    changeset.elementUpdated.forEach {
                        let indexPath = IndexPath(row: $0.element, section: $0.section)
                        reloadRow(indexPath)
                    }
                }

                for (source, target) in changeset.elementMoved {
                    moveRow(at: IndexPath(row: source.element, section: source.section),
                            to: IndexPath(row: target.element, section: target.section))
                }
            }
        }
    }
}
