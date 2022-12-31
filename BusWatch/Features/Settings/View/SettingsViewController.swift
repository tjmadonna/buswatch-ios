//
//  SettingsViewController.swift
//  BusWatch
//
//  Created by Tyler Madonna on 12/31/22.
//  Copyright © 2022 Tyler Madonna. All rights reserved.
//

import Foundation
import SafariServices
import UIKit

final class SettingsViewController: UITableViewController {

    private struct Section {
        let title: String
        let items: [Item]
    }

    private struct Item {
        let indexPath: IndexPath
        let text: String
        let action: (() -> Void)?
    }

    private lazy var sections = [
        Section(title: "Feedback", items: [
            Item(indexPath: IndexPath(row: 0, section: 0),
                 text: "Send Feedback",
                 action: { [weak self] in
                     self?.sendEmail()
                 }),
            Item(indexPath: IndexPath(row: 0, section: 1),
                 text: "Leave A Review",
                 action: { [weak self] in
                     self?.openAppReviewPage()
                 })
        ]),
        Section(title: "About", items: [
            Item(indexPath: IndexPath(row: 1, section: 0),
                 text: "Privacy Policy",
                 action: { [weak self] in
                     self?.openPrivacyPolicyPage()
                 }),
            Item(indexPath: IndexPath(row: 1, section: 1),
                 text: "Open Source Libaries",
                 action: { [weak self] in
                     self?.openOpenSourceViewController()
                 }),
            Item(indexPath: IndexPath(row: 1, section: 2),
                 text: "Source Code",
                 action: { [weak self] in
                     self?.openSourceCodePage()
                 }),
            Item(indexPath: IndexPath(row: 1, section: 3),
                 text: "Version \(Bundle.main.appVersion!) Build \(Bundle.main.buildVersion!)",
                 action: nil)
        ])
    ]

    // MARK: - Initialization

    init() {
        super.init(style: .grouped)
    }

    required init?(coder: NSCoder) {
        fatalError("View Controller cannot be initialized with init(coder:)")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        setupTableView()
        setupObservers()
    }

}

extension SettingsViewController {

    private func setupViewController() {
        navigationItem.title = "Settings"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(handleDoneBarButtonItemTouch(sender:)))
    }

    private func setupTableView() {
        tableView.separatorStyle = .singleLine
    }

    private func setupObservers() {
        // Deselect the cell when application is brought into the foreground. Fix for when cells stay selected when
        // user comes back to the app.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(deselectSelectedCells),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }

}

// MARK: - UITableViewDelegate
extension SettingsViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = sections[indexPath.section].items[indexPath.row]
        item.action?()
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let item = sections[indexPath.section].items[indexPath.row]
        return item.action != nil ? indexPath : nil
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let item = sections[indexPath.section].items[indexPath.row]
        return item.action != nil
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 96
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = SectionHeaderView()
        header.configureWithTitle(sections[section].title)
        return header
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return SectionFooterView()
    }

}

// MARK: - UITableViewDataSource
extension SettingsViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let item = sections[indexPath.section].items[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = item.text
        content.textProperties.color = .label
        cell.contentConfiguration = content
        cell.accessoryType = item.action != nil ? .disclosureIndicator : .none
        return cell
    }

}

// MARK: - Selectors
extension SettingsViewController {

    @objc private func handleDoneBarButtonItemTouch(sender: Any) {
        navigationController?.dismiss(animated: true)
    }

}

extension SettingsViewController {

    @objc private func deselectSelectedCells() {
        if let indexes = self.tableView.indexPathsForSelectedRows {
            for index in indexes {
                self.tableView.deselectRow(at: index, animated: true)
            }
        }
    }

    private func sendEmail() {

        let mailToString = """
        mailto:dev@tylermadonna.com
        ?subject=Pittsburgh Bus Watch Feedback
        &body=\n\nApp Information:\nVersion \(Bundle.main.appVersion!) Build \(Bundle.main.buildVersion!)
        """.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        let mailToUrl = URL(string: mailToString)!
        if UIApplication.shared.canOpenURL(mailToUrl) {
                UIApplication.shared.open(mailToUrl, options: [:])
        } else {
            let alertController = UIAlertController(title: "Error Sending Feedback",
                                                    message: "Please contact us directly at dev@tylermadonna.com",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.deselectSelectedCells()
            })
            navigationController?.present(alertController, animated: true)
        }
    }

    private func openAppReviewPage() {
        let appId = Secrets.appStoreId
        let url = URL(string: "https://itunes.apple.com/app/id\(appId)?action=write-review")!
        let safariViewController = SFSafariViewController(url: url)
        navigationController?.present(safariViewController, animated: true)
    }

    private func openPrivacyPolicyPage() {
        let url = URL(string: "https://pghbuswatch.com/privacy.html")!
        let safariViewController = SFSafariViewController(url: url)
        navigationController?.present(safariViewController, animated: true)
    }

    private func openOpenSourceViewController() {
        let openSourceViewController = OpenSourceViewController()
        navigationController?.pushViewController(openSourceViewController, animated: true)
    }

    private func openSourceCodePage() {
        let url = URL(string: "https://github.com/tjmadonna/buswatch-ios")!
        let safariViewController = SFSafariViewController(url: url)
        navigationController?.present(safariViewController, animated: true)
    }
}
