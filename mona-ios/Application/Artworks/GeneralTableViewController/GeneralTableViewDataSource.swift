//
//  NamableTableViewDataSource.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-30.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//


import UIKit
import CoreData

class GeneralTableViewDataSource: NSObject, UITableViewDataSource, TableViewIndexDataSource {
    
    //MARK: - Types
    struct Section {
        var name : String?
        var items : [ArtworksNamable]
    }
    
    struct Strings {
        private static let tableName = "GeneralTableViewDataSource"
        static let artwork = NSLocalizedString("artwork", tableName: tableName, bundle: .main, value: "", comment: "")
        static let artworks = NSLocalizedString("artworks", tableName: tableName, bundle: .main, value: "", comment: "")
    }
    
    var sections : [Section]
    
    init(namables: [ArtworksNamable]) {
        self.sections = [Section]()
        let nam = namables.sorted(by: {
            $0.nameNamable < $1.nameNamable
        })
        var sectionsNamables = [String: [ArtworksNamable]]()
        var lastSectionUsed = ""
        // Build the sections that we're gonna use for the alphabetical sort
        for namable in nam {
            // Extract the first letter of the current Nameable. Ignore accent and uppercase this firstLetter
            var firstLetter = namable.nameNamable[0...0].folding(options: .diacriticInsensitive, locale: .current).uppercased()
            
            if Int(firstLetter) != nil {
                firstLetter = "#"
            }
            
            // If this firstLetter is different of the last section used, so append a new section and append this Nameable into it
            if firstLetter != lastSectionUsed {
                sectionsNamables.updateValue([namable], forKey: firstLetter)
                lastSectionUsed = firstLetter
            }
                // Else just append the Nameable into the last section
            else if sectionsNamables[lastSectionUsed] != nil {
                sectionsNamables[lastSectionUsed]!.append(namable)
                sectionsNamables.updateValue(sectionsNamables[lastSectionUsed]!, forKey: lastSectionUsed)
            }
        }
        var sections = sectionsNamables.map({Section(name: $0.key, items: $0.value)}).sorted(by: { $0.name ?? "" < $1.name ?? "" })
        if sections.contains(where: {
            return $0.name == "#"
        }) {
            sections.append(sections.remove(at: 0))
        }
        self.sections = sections
        super.init()
    }
    
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
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GeneralTableViewCell.reuseIdentifier, for: indexPath) as? GeneralTableViewCell  else {
            fatalError("The dequeued cell is not an instance of GeneralTableViewCell.")
        }
        
        // Fetches the appropriate artwork for the data source layout.
        let namable = self.sections[indexPath.section].items[indexPath.row]
        cell.titleLabel.text = namable.nameNamable
        if namable.artworks.count == 1 {
            cell.subtitleLabel.text = String(namable.artworks.count) + " " + Strings.artwork
        }
        else {
            cell.subtitleLabel.text = String(namable.artworks.count) + " " + Strings.artworks
        }
        cell.artworks = Array(namable.artworks)
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
