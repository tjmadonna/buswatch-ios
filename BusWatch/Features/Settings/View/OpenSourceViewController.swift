//
//  OpenSourceViewController.swift
//  BusWatch
//
//  Created by Tyler Madonna on 12/31/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import SafariServices
import UIKit

final class OpenSourceViewController: UITableViewController {

    // MARK: - Items
    private let libraries = [
        (title: "DifferenceKit", license: "Apache License 2.0", url: "https://github.com/ra1028/DifferenceKit"),
        (title: "GRDB", license: "MIT License", url: "https://github.com/groue/GRDB.swift")
    ]

    // MARK: - Initialization

    init() {
        super.init(style: .grouped)
    }

    required init?(coder: NSCoder) {
        fatalError("View Controller cannot be initialized with init(coder:)")
    }

    // MARK: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupTableView()
    }

}

extension OpenSourceViewController {

    private func setupViewController() {
        navigationItem.title = "Open Source Libraries"
    }

    private func setupTableView() {
        tableView.separatorStyle = .singleLine
    }

}

// MARK: - UITableViewDelegate
extension OpenSourceViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = libraries[indexPath.row]
        if let url = URL(string: item.url) {
            let safariViewController = SFSafariViewController(url: url)
            navigationController?.present(safariViewController, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 96
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = SectionHeaderView()
        header.configureWithTitle("Thank You To These Projects")
        return header
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return SectionFooterView()
    }

}

// MARK: - UITableViewDataSource
extension OpenSourceViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return libraries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let item = libraries[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = item.title
        content.secondaryText = item.license
        content.textProperties.color = .label
        content.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

}

