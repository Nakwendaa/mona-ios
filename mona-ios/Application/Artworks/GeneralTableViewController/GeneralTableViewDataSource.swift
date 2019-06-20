//
//  NamableTableViewDataSource.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-30.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//


import UIKit
import CoreData

final class GeneralTableViewDataSource<T: ArtworksSettable & TextRepresentable>: NSObject, UITableViewDataSource, TableViewIndexDataSource {
    
    //MARK: - Properties
    var sections = [GeneralSection<T>]()
    //MARK: Strings
    let artworkString = NSLocalizedString("artwork", tableName: "GeneralTableViewDataSource", bundle: .main, value: "", comment: "")
    let artworksString = NSLocalizedString("artworks", tableName: "GeneralTableViewDataSource", bundle: .main, value: "", comment: "")
    
    //MARK: - Initializers
    init(items: [T]) {
        sections = [GeneralSection(name: "", items: items)].sortText()
        super.init()
    }
    
    //MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Dequeue reusable cell
        let reuseId = GeneralTableViewCell.reuseIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as! GeneralTableViewCell
        
        // Find the appropriate item with sections properties
        let item = sections[indexPath.section].items[indexPath.row]
        
        // Setup cell with this item
        cell.titleLabel.text = item.text
        cell.subtitleLabel.text = String(item.artworks.count) + " " + (item.artworks.count == 1 ? artworkString : artworksString)
        cell.artworks = Array(item.artworks)
        
        
        return cell
    }
    
    //MARK: - TableViewIndexDataSource
    func indexItems(for tableViewIndex: TableViewIndex) -> [UIView] {
        tableViewIndex.tintColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        let sectionIndexViews = sections.map({
            section -> UILabel in
            let label = UILabel()
            label.font = UIFont.boldSystemFont(ofSize: 12)
            label.textColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
            label.text = section.name
            return label
        })
        return sectionIndexViews
    }
    
}
