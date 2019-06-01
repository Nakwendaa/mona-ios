//
//  TechniquesTableViewDataSource.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-19.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit
import CoreData

class TechniquesTableViewDataSource : NSObject, UITableViewDataSource {
    
    struct Section {
        var name : String?
        var items : [Technique]
    }
    
    static let artwork = NSLocalizedString("artwork", tableName: "GeneralTableViewController", bundle: .main, value: "", comment: "")
    static let artworks = NSLocalizedString("artworks", tableName: "GeneralTableViewController", bundle: .main, value: "", comment: "")
 
    var sections : [Section]
    
    init(techniques: [Technique]) {
        self.sections = [Section]()
        let tech = techniques.sorted(by: {
            $0.localizedName < $1.localizedName
        })
        var sectionsTechniques = [String: [Technique]]()
        var lastSectionUsed = ""
        // Build the sections that we're gonna use for the alphabetical sort
        for technique in tech {
            // Extract the first letter of the current Nameable. Ignore accent and uppercase this firstLetter
            var firstLetter = technique.localizedName[0...0].folding(options: .diacriticInsensitive, locale: .current).uppercased()
            
            if Int(firstLetter) != nil {
                firstLetter = "#"
            }
            
            // If this firstLetter is different of the last section used, so append a new section and append this Nameable into it
            if firstLetter != lastSectionUsed {
                sectionsTechniques.updateValue([technique], forKey: firstLetter)
                lastSectionUsed = firstLetter
            }
                // Else just append the Nameable into the last section
            else if sectionsTechniques[lastSectionUsed] != nil {
                sectionsTechniques[lastSectionUsed]!.append(technique)
                sectionsTechniques.updateValue(sectionsTechniques[lastSectionUsed]!, forKey: lastSectionUsed)
            }
        }
        var sections = sectionsTechniques.map({Section(name: $0.key, items: $0.value)}).sorted(by: { $0.name ?? "" < $1.name ?? "" })
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
        let cellIdentifier = "GeneralTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? GeneralTableViewCell  else {
            fatalError("The dequeued cell is not an instance of GeneralTableViewCell.")
        }
        
        // Fetches the appropriate artwork for the data source layout.
        let technique = self.sections[indexPath.section].items[indexPath.row]
        cell.titleLabel.text = technique.localizedName
        if technique.artworks.count == 1 {
            cell.subtitleLabel.text = String(technique.artworks.count) + " " + TechniquesTableViewDataSource.artwork
        }
        else {
            cell.subtitleLabel.text = String(technique.artworks.count) + " " + TechniquesTableViewDataSource.artworks
        }
        cell.artworksIds = technique.artworks.map({$0.id})
        return cell
    }
    
}

extension TechniquesTableViewDataSource : TableViewIndexDataSource {
    
    //MARK: - Types
    struct Style {
        static let indexTextColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        static let indexTintColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        static let indexFont = UIFont.boldSystemFont(ofSize: 12)
    }
    
    func indexItems(for tableViewIndex: TableViewIndex) -> [UIView] {
        tableViewIndex.tintColor = Style.indexTintColor
        let sectionIndexViews = sections.map({
            section -> UILabel in
            let label = UILabel()
            label.font = Style.indexFont
            label.textColor = Style.indexTextColor
            label.text = section.name
            return label
        })
        return sectionIndexViews
    }
}

