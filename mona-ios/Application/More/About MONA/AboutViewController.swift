//
//  AboutViewController.swift
//  mona
//
//  Created by Paul Chaffanet on 2019-05-05.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

final class AboutViewController: UIViewController {
    
    //MARK: - Types
    struct Strings {
        private static let tableName = "AboutViewController"
        static let title = NSLocalizedString("title", tableName: tableName, bundle: .main, value: "Translation not found", comment: "")
        static let preamble = NSLocalizedString("preamble", tableName: tableName, bundle: .main, value: "Translation not found", comment: "")
        static let licenseTitle = NSLocalizedString("license title", tableName: tableName, bundle: .main, value: "Translation not found", comment: "")
        static let licenseBody = NSLocalizedString("license body", tableName: tableName, bundle: .main, value: "Translation not found", comment: "")
        static let contributorsTitle = NSLocalizedString("contributors title", tableName: tableName, bundle: .main, value: "Translation not found", comment: "")
        static let contributorsBody = NSLocalizedString("contributors body", tableName: tableName, bundle: .main, value: "Translation not found", comment: "")
    }
    
    //MARK: - UI Properties
    @IBOutlet weak var preambleLabel: UILabel!
    @IBOutlet weak var licenseTitleLabel: UILabel!
    @IBOutlet weak var licenseBodyLabel: UILabel!
    @IBOutlet weak var contributorsTitleLabel: UILabel!
    @IBOutlet weak var contributorsBodyLabel: UILabel!
    
    //MARK: - Overriden methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupLabels()
    }
    
    //MARK: - Private methods
    private func setupNavigationItem() {
        title = Strings.title
    }
    private func setupLabels() {
        preambleLabel.text = Strings.preamble
        licenseTitleLabel.text = Strings.licenseTitle
        licenseBodyLabel.text = Strings.licenseBody
        contributorsTitleLabel.text = Strings.contributorsTitle
        contributorsBodyLabel.text = Strings.contributorsBody
    }
    
}
