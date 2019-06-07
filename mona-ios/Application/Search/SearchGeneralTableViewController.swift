//
//  SearchGeneralTableViewController.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-06-04.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

class SearchGeneralTableViewController: UIViewController {
    
    //MARK: - Types
    struct Segues {
        static let showArtworksTableViewController = "showArtworksTableViewController"
    }
    
    //MARK: - Properties
    var artworksNamables = [ArtworksNamable]()
    
    //MARK: - UI Properties
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Overriden methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case Segues.showArtworksTableViewController:
            let destination = segue.destination as! ArtworksTableViewController
            let cell = sender as! GeneralTableViewCell
            destination.artworks = cell.artworks
        default:
            return
        }
    }

}

//MARK: - UITableViewDataSource
extension SearchGeneralTableViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artworksNamables.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "tableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.textLabel?.text = artworksNamables[indexPath.row].nameNamable
        return cell
    }
    
}

//MARK: - UITableViewDelegate
extension SearchGeneralTableViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let cell = tableView.cellForRow(at: indexPath)
        performSegue(withIdentifier: Segues.showArtworksTableViewController, sender: cell)
    }
}
