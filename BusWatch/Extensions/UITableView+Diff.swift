//
//  UITableView+Diff.swift
//  BusWatch
//
//  Created by Tyler Madonna on 11/4/21.
//  Copyright © 2021 Tyler Madonna. All rights reserved.
//

import DifferenceKit
import UIKit

extension UITableView {

    func reload<C>(
        using stagedChangeset: StagedChangeset<C>,
        with animation: @autoclosure () -> RowAnimation,
        interrupt: ((Changeset<C>) -> Bool)? = nil,
        setData: (C) -> Void,
        reloadRow: (IndexPath) -> Void
    ) {
        if case .none = window, let data = stagedChangeset.last?.data {
            setData(data)
            return reloadData()
        }

        for changeset in stagedChangeset {
            if let interrupt = interrupt, interrupt(changeset), let data = stagedChangeset.last?.data {
                setData(data)
                return reloadData()
            }

            performBatchUpdates {
                setData(changeset.data)
                updateSections(using: changeset, with: animation)
                updateRows(using: changeset, with: animation, reloadRow: reloadRow)
            }
        }
    }

    fileprivate func updateSections<C>(using changeset: Changeset<C>, with animation: () -> RowAnimation) {

        if !changeset.sectionUpdated.isEmpty {
            reloadSections(IndexSet(changeset.sectionUpdated), with: animation())
        }

        for (source, target) in changeset.sectionMoved {
            moveSection(source, toSection: target)
        }

        if !changeset.sectionDeleted.isEmpty {
            deleteSections(IndexSet(changeset.sectionDeleted), with: animation())
        }

        if !changeset.sectionInserted.isEmpty {
            insertSections(IndexSet(changeset.sectionInserted), with: animation())
        }
    }

    fileprivate func updateRows<C>(using changeset: Changeset<C>,
                                   with animation: () -> RowAnimation,
                                   reloadRow: (IndexPath) -> Void) {

        if !changeset.elementDeleted.isEmpty {
            deleteRows(at: changeset.elementDeleted.map { IndexPath(row: $0.element, section: $0.section) },
                       with: animation())
        }

        if !changeset.elementInserted.isEmpty {
            insertRows(at: changeset.elementInserted.map { IndexPath(row: $0.element, section: $0.section) },
                       with: animation())
        }

        if !changeset.elementUpdated.isEmpty {
            changeset.elementUpdated.forEach {
                reloadRow(IndexPath(row: $0.element, section: $0.section))
            }
        }

        if !changeset.elementMoved.isEmpty {
            let updatedElements = Set(changeset.elementUpdated)
            for (source, target) in changeset.elementMoved {
                if !updatedElements.contains(source) {
                    reloadRow(IndexPath(row: source.element, section: target.section))
                }
                moveRow(at: IndexPath(row: source.element, section: source.section),
                        to: IndexPath(row: target.element, section: target.section))
            }
        }
    }

}
