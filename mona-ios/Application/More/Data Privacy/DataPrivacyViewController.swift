//
//  DataPrivacyViewController.swift
//  mona
//
//  Created by Paul Chaffanet on 2019-05-05.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

final class DataPrivacyViewController: UIViewController {
    
    //MARK: - Types
    struct Strings {
        private static let tableName = "DataPrivacyViewController"
        static let title = NSLocalizedString("title", tableName: tableName, bundle: .main, value: "Translation not found", comment: "")
        static let preamble = NSLocalizedString("preamble", tableName: tableName, bundle: .main, value: "Translation not found", comment: "")
        static let firstSubtitle = NSLocalizedString("first subtitle", tableName: tableName, bundle: .main, value: "Translation not found", comment: "")
        static let firstBodyText = NSLocalizedString("first body text", tableName: tableName, bundle: .main, value: "Translation not found", comment: "")
        static let secondSubtitle = NSLocalizedString("second subtitle", tableName: tableName, bundle: .main, value: "Translation not found", comment: "")
        static let secondBodyText = NSLocalizedString("second body text", tableName: tableName, bundle: .main, value: "Translation not found", comment: "")
        static let thirdSubtitle = NSLocalizedString("third subtitle", tableName: tableName, bundle: .main, value: "Translation not found", comment: "")
        static let thirdBodyText = NSLocalizedString("third body text", tableName: tableName, bundle: .main, value: "Translation not found", comment: "")
    }
    
    //MARK: - UI Properties
    @IBOutlet weak var preambleLabel: UILabel!
    @IBOutlet weak var firstSubtitleLabel: UILabel!
    @IBOutlet weak var firstBodyTextLabel: UILabel!
    @IBOutlet weak var secondSubtitleLabel: UILabel!
    @IBOutlet weak var secondBodyTextLabel: UILabel!
    @IBOutlet weak var thirdSubtitleLabel: UILabel!
    @IBOutlet weak var thirdBodyTextLabel: UILabel!
    
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
        firstSubtitleLabel.text = Strings.firstSubtitle
        firstBodyTextLabel.text = Strings.firstBodyText
        secondSubtitleLabel.text = Strings.secondSubtitle
        secondBodyTextLabel.text = Strings.secondBodyText
        thirdSubtitleLabel.text = Strings.thirdSubtitle
        thirdBodyTextLabel.text = Strings.thirdBodyText
    }
    
}
