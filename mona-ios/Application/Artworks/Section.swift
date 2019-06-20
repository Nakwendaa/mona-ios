//
//  Section.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-06-17.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//


protocol Section {
    associatedtype Item
    init(name: String, items: [Item])
    var name : String { get set }
    var items : [Item] { get set }
}

protocol TextSection : Section where Item: TextRepresentable {}
protocol DateSection : Section where Item: DateRepresentable {}
protocol LocationSection : Section where Item: LocationRepresentable {}


struct GeneralSection<T: TextRepresentable & ArtworksSettable> : TextSection {
    var name : String
    var items : [T]
}

struct ArtworksSection : TextSection, DateSection, LocationSection {
    var name : String
    var items : [Artwork]
}
