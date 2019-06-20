//
//  Array+Extension.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-17.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import CoreLocation

extension Array {
    public func toDictionary<Key: Hashable>(with selectKey: (Element) -> Key) -> [Key:Element] {
        var dict = [Key:Element]()
        for element in self {
            dict[selectKey(element)] = element
        }
        return dict
    }
}

extension Array where Element: TextSection {
    
    func sortText() -> [Element] {
        // Read
        var items = flatMap { $0.items }
        items.sort(by: { $0.text < $1.text })
        
        // The key is the name of the section. The value is an array of Items
        var itemsSections = [String: [Element.Item]]()
        
        // Build the sections that we're gonna use for the alphabetical sort
        for item in items {
            // Extract the first letter of the current Nameable. Ignore accent and uppercase this firstLetter
            var firstCharacterString = item.text[0...0].folding(options: .diacriticInsensitive, locale: .current).uppercased()
            
            if Int(firstCharacterString) != nil {
                firstCharacterString = "#"
            }
            
            if itemsSections[firstCharacterString] == nil {
                itemsSections[firstCharacterString] = [item]
            }
            else if var itemsArray = itemsSections[firstCharacterString] {
                itemsArray.append(item)
                itemsSections[firstCharacterString] = itemsArray
            }
        }
        
        // SORTING [SINCE A DICTIONARY IS AN UNSORTED LIST]
        var sections = itemsSections.sorted(by: {
            $0.0 < $1.0
        }).map {
            Element.init(name: $0.key, items: $0.value)
        }
        
        // Numbers after character "Z"
        if sections.contains(where: { $0.name == "#" }) {
            sections.append(sections.remove(at: 0))
        }
        return sections
    }
    
}

extension Array where Element: DateSection {
    
    func sortDate() -> [Element] {
        let unknownDateString = NSLocalizedString("Unknown date", tableName: "Array+Extension", bundle: .main, value: "", comment: "")
        var items = flatMap { $0.items }
        items.sort(by: { ($0.date ?? .distantPast) < ($1.date ?? .distantPast) })
        var itemsSections = [String: [Element.Item]]()
        
        for item in items {
            // Extract the first letter of the current artwork. Ignore accent and uppercase this firstLetter
            let year : String
            
            if let date = item.date {
                year = date.toString(format: "yyyy")
            }
            else {
                year = unknownDateString
            }
            
            if itemsSections[year] == nil {
                itemsSections[year] = [item]
            }
            else if var itemsArray = itemsSections[year] {
                itemsArray.append(item)
                itemsSections[year] = itemsArray
            }
        }
        
        // SORTING [SINCE A DICTIONARY IS AN UNSORTED LIST]
        let sections = itemsSections.sorted(by: { $0.0 < $1.0})
            .map { Element.init(name: $0.key, items: $0.value) }
        

        return sections
    }
}

extension Array where Element : LocationSection {
    
    func sortDistance(from origin: CLLocation) -> [Element] {
        let tableName = "Array+Extension"
        let keys = [
            NSLocalizedString("Less than 100 m", tableName: tableName, bundle: .main, value: "", comment: ""),
            NSLocalizedString("Less than 1 km", tableName: tableName, bundle: .main, value: "", comment: ""),
            NSLocalizedString("Less than 5 km", tableName: tableName, bundle: .main, value: "", comment: ""),
            NSLocalizedString("Less than 10 km", tableName: tableName, bundle: .main, value: "", comment: ""),
            NSLocalizedString("More than 10 km", tableName: tableName, bundle: .main, value: "", comment: ""),
            NSLocalizedString("Unknown distance", tableName: tableName, bundle: .main, value: "", comment: "")
        ]
        
        let items = flatMap { $0.items }
        var itemsSections = [String: [(CLLocationDistance, Element.Item)]]()
        
        for item in items {
            
            let key : String
            let distance = origin.distance(from: item.location)
            
            switch distance {
            case ...100:
                key = keys[0]
            case ...1000:
                key = keys[1]
            case ...5000:
                key = keys[2]
            case ...10000:
                key = keys[3]
            case 10000...:
                key = keys[4]
            default:
                key = keys[5]
            }
            
            if itemsSections[key] == nil {
                itemsSections[key] = [(distance, item)]
            }
            else if var arr = itemsSections[key] {
                arr.append((distance, item))
                itemsSections[key] = arr
            }
            
        }
        
        let itemsSectionsDistanceSorted = itemsSections.map { key, value in
            // Sort items by distance for each key
            (key, value.sorted(by: { $0.0 < $1.0 }))
        }
        
        
        let itemsSectionsKeyAndDistanceSorted = itemsSectionsDistanceSorted.sorted {
            // Sort items based on order in keys
            let lKeyIndex = keys.firstIndex(of: $0.0) ?? Int.max
            let rKeyIndex = keys.firstIndex(of: $1.0) ?? Int.max
            return lKeyIndex < rKeyIndex
        }
    
        let sections = itemsSectionsKeyAndDistanceSorted.map { Element.init(name: $0.0, items: $0.1.map { $0.1 }) }
        
        return sections
    }
}
