//
//  ArtworksTableViewController.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-18.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class ArtworksTableViewController : SearchViewController {
    
    // Table View
    @IBOutlet weak var tableView: UITableView!
    var artworksTableViewDataSource : ArtworksTableViewDataSource!
    @IBOutlet weak var headerTableViewLabel: UILabel!
    @IBOutlet weak var filterButton: UIButton!
    
    // Table View Index
    @IBOutlet weak var tableViewIndex: TableViewIndex!
    var tableViewIndexDataSource : TableViewIndexDataSource?
    @IBOutlet weak var tableViewIndexTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewIndexWidthConstraint: NSLayoutConstraint!

    // Refresh Control
    let refreshControl = UIRefreshControl()
    let locationManager = CLLocationManager()
    
    // Table View Index Animation
    var canPerformTableViewIndexAnimation = true
    
    // This variable is useful to avoid unnecessary tableview.reloadData when the viewDidLoad
    var didViewLoaded = false
    
    // This variable is useful to hide filter button if search
    var hideFilterButton = false
    
    struct Strings {
        private static let tableName = "ArtworksTableViewController"
        static let untitled = NSLocalizedString("untitled", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        
        struct NeedAuthorizationLocationOpenSettings {
            static let title = NSLocalizedString("need authorization", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
            static let message = NSLocalizedString("sort by distance can not be used if location services are not enabled", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        }
    }
    
    struct Style {
        struct BackgroundViewOfHeaderViewStickingNavigationBar {
            static let backgroundColor : UIColor = UIColor(red: 250.0/255.0, green: 217.0/255.0, blue: 1.0/255.0, alpha: 1)
            static let shadowColor : CGColor = UIColor.gray.cgColor
            static let shadowOffset : CGSize = CGSize(width: 0, height: 0.05)
            static let shadowRadius : CGFloat = CGFloat(integerLiteral: 1)
            static let shadowOpacity : Float = 1
            static let bottomBorderColor : UIColor = .lightGray
            static let bottomBorderWidth : CGFloat = 0.5
        }
    }
    
    struct Segues {
        static let showArtworkDetailsViewController = "showArtworkDetailsViewController"
    }
    
    var artworks = [Artwork]()
    
    //MARK: Overriden methods
    override func viewDidLoad() {
        super.viewDidLoad()
        headerTableViewLabel.text = title
        tableViewIndex.itemSpacing = 2
        tableViewIndexTrailingConstraint.constant = -tableViewIndex.frame.width
        tableViewIndex.indexOffset = UIOffset(horizontal: -4, vertical: 0)
        setTransparentNavigationBar(tintColor: .black)
        
        
        tableView.delegate = self
        tableViewIndex.delegate = self

        DispatchQueue.main.async {
            self.artworksTableViewDataSource = ArtworksTableViewDataSource(artworks: self.artworks)
            self.tableViewIndexDataSource = self.artworksTableViewDataSource
            self.tableView.dataSource = self.artworksTableViewDataSource
            self.tableViewIndex.dataSource = self.artworksTableViewDataSource
            self.tableView.reloadData()
            self.tableViewIndex.reloadData()
        }
        
        
        setupRefreshControl()
        setupLocationManager()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: .applicationDidBecomeActive, object: nil)
        
        if hideFilterButton {
            filterButton.isHidden = true
        }
        
    }
    
    @objc func applicationDidBecomeActive() {
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.tableHeaderView?.setNeedsLayout()
        tableView.tableHeaderView?.layoutIfNeeded()
        tableView.tableHeaderView?.updateConstraints()
        
        // Refresh visible thumbnails when back from a view
        if didViewLoaded {
            tableView.reloadData()
        }
        didViewLoaded = true
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sizeHeaderToFit()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
            
        case Segues.showArtworkDetailsViewController:
            let destination = segue.destination as! ArtworkDetailsViewController
            let cell = sender as! ArtworkTableViewCell
            destination.title = cell.titleLabel.text
            destination.artwork = cell.artwork
            return
            
        default:
            return
            
        }
        
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
 
    
    //MARK: Actions
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        let filterPopoverViewController = FilterPopoverViewController()
        filterPopoverViewController.preferredContentSize = CGSize(width: 128, height: 128)
        filterPopoverViewController.modalPresentationStyle = .popover
        
        if let pres = filterPopoverViewController.presentationController {
            pres.delegate = filterPopoverViewController
        }
        
        if let pop = filterPopoverViewController.popoverPresentationController {
            pop.sourceView = sender
            pop.sourceRect = sender.bounds
        }
        
        present(filterPopoverViewController, animated: true)
        // Ajouter les actions pour les filtres
        filterPopoverViewController.titleButton.addTarget(self, action: #selector(sortByTitle), for: .touchUpInside)
        filterPopoverViewController.dateButton.addTarget(self, action: #selector(sortByDate), for: .touchUpInside)
        filterPopoverViewController.distanceButton.addTarget(self, action: #selector(sortByDistance), for: .touchUpInside)
    }
    
    //MARK: Private methods
    // Modifier la hauteur de la headerView
    private func sizeHeaderToFit() {
        let tableHeaderView = tableView.tableHeaderView!
        let tableEnclosingView = tableHeaderView.subviews[0]
        
        let width = tableView.frame.width
        let height = tableEnclosingView.frame.height + filterButton.frame.height + 16.0
        var frame = tableHeaderView.frame
        frame.size.height = height
        frame.size.width = width
        tableHeaderView.frame = frame
        tableView.tableHeaderView = tableHeaderView
        tableHeaderView.setNeedsLayout()
        tableHeaderView.layoutIfNeeded()
    }
    
    private func setupRefreshControl() {
        // Refresh Control handling
        refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("updating location", comment: "").capitalizingFirstLetter())
        refreshControl.addTarget(self, action: #selector(refreshLocation), for: .valueChanged)
    }
    
    @objc func sortByTitle() {
        refreshControl.endRefreshing()
        refreshControl.removeFromSuperview()
        artworksTableViewDataSource.sort(by: .title, coordinate: nil)
        tableViewIndex.indexOffset = UIOffset(horizontal: -4, vertical: 0)
        tableViewIndexWidthConstraint.constant = 24
        tableViewIndexTrailingConstraint.constant = -tableViewIndexWidthConstraint.constant
        tableView.reloadData()
        tableViewIndex.reloadData()
    }
    
    @objc func sortByDate() {
        refreshControl.endRefreshing()
        refreshControl.removeFromSuperview()
        artworksTableViewDataSource.sort(by: .date, coordinate: nil)
        tableViewIndex.indexOffset = UIOffset(horizontal: -12, vertical: 0)
        tableViewIndexWidthConstraint.constant = 44
        tableViewIndexTrailingConstraint.constant = -tableViewIndexWidthConstraint.constant
        tableView.reloadData()
        tableViewIndex.reloadData()
    }
    
    @objc func sortByDistance() {
        tableViewIndex.indexOffset = UIOffset(horizontal: -16, vertical: 0)
        tableViewIndexWidthConstraint.constant = 44
        tableViewIndexTrailingConstraint.constant = -tableViewIndexWidthConstraint.constant
        tableView.addSubview(refreshControl)
        tableView.setContentOffset(CGPoint(x: 0, y: -80), animated: false)
        tableView.isScrollEnabled = false
        refreshControl.beginRefreshing()
        refreshControl.sendActions(for: .valueChanged)
    }
    
    @objc func refreshLocation() {
        dismiss(animated: true, completion: nil)
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted, .denied:
            UIAlertController.presentOpenSettings(from: self, title: Strings.NeedAuthorizationLocationOpenSettings.title, message: Strings.NeedAuthorizationLocationOpenSettings.message, completion: {
                self.refreshControl.endRefreshing()
            })
            break
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            tableView.isScrollEnabled = false
            break
        default:
            break
        }
    }
}

//MARK: - UITableViewDelegate
extension ArtworksTableViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        guard let tableViewHeaderFooterView = view as? UITableViewHeaderFooterView else {
            return
        }
        
        tableViewHeaderFooterView.backgroundView?.backgroundColor = .clear
        tableViewHeaderFooterView.backgroundView?.layer.sublayers = nil
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        
        guard let tableViewHeaderFooterView = view as? UITableViewHeaderFooterView else {
            return
        }
        
        tableViewHeaderFooterView.backgroundView?.backgroundColor = .clear
        tableViewHeaderFooterView.backgroundView?.layer.sublayers = nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: Segues.showArtworkDetailsViewController, sender: tableView.cellForRow(at: indexPath))
    }
}

// MARK: - Scroll View Delegate
extension ArtworksTableViewController : UIScrollViewDelegate {
    
    // Code le fait que les headers views de chaque section change de couleur d'arrière-plan lorsque ceux-ci stick au top de la view
    // lorsque que l'on scrolle
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard let heightTableHeaderView = tableView.tableHeaderView?.frame.height,
            let indexes = tableView.indexPathsForVisibleRows,
            !indexes.isEmpty else {
                return
        }
        
        if indexes[0].section == 0 && tableView.contentOffset.y < heightTableHeaderView {
            
            tableView.headerView(forSection: 0)?.backgroundView?.backgroundColor = .clear
            tableView.headerView(forSection: 0)?.backgroundView?.layer.sublayers = nil
            
            if canPerformTableViewIndexAnimation {
                
                for cell in tableView.visibleCells {
                    if let generalTableViewCell = cell as? GeneralTableViewCell {
                        generalTableViewCell.trailingMarginConstraint.constant = 0
                    }
                }
                tableViewIndexTrailingConstraint.constant = -tableViewIndex.frame.width
                UIView.animate(withDuration: 0.25, animations: {
                    self.tableViewIndex.layoutIfNeeded()
                    for cell in self.tableView.visibleCells {
                        cell.layoutIfNeeded()
                    }
                })
            }
            
        }
        else {
            tableViewIndexTrailingConstraint.constant = 0
            
            for cell in tableView.visibleCells {
                if let generalTableViewCell = cell as? GeneralTableViewCell {
                    generalTableViewCell.trailingMarginConstraint.constant = tableViewIndex.frame.width
                }
            }
            
            if indexes[0].section == 0 && tableView.contentOffset.y < tableView.frame.height {
                UIView.animate(withDuration: 0.25, animations: {
                    self.tableViewIndex.layoutIfNeeded()
                    for cell in self.tableView.visibleCells {
                        cell.layoutIfNeeded()
                    }
                })
            }
            
            // Header View stick at navigation bar
            guard let headerViewStickingNavigationBar = tableView.headerView(forSection: indexes[0].section), let backgroundViewOfHeaderViewStickingNavigationBar = headerViewStickingNavigationBar.backgroundView else {
                return
            }
            
            backgroundViewOfHeaderViewStickingNavigationBar.backgroundColor = Style.BackgroundViewOfHeaderViewStickingNavigationBar.backgroundColor
            backgroundViewOfHeaderViewStickingNavigationBar.layer.shadowColor = Style.BackgroundViewOfHeaderViewStickingNavigationBar.shadowColor
            backgroundViewOfHeaderViewStickingNavigationBar.layer.shadowOffset = Style.BackgroundViewOfHeaderViewStickingNavigationBar.shadowOffset
            backgroundViewOfHeaderViewStickingNavigationBar.layer.shadowRadius = Style.BackgroundViewOfHeaderViewStickingNavigationBar.shadowRadius
            backgroundViewOfHeaderViewStickingNavigationBar.layer.shadowOpacity = Style.BackgroundViewOfHeaderViewStickingNavigationBar.shadowOpacity
            backgroundViewOfHeaderViewStickingNavigationBar.addBottomBorderWithColor(color: Style.BackgroundViewOfHeaderViewStickingNavigationBar.bottomBorderColor, width: Style.BackgroundViewOfHeaderViewStickingNavigationBar.bottomBorderWidth)
            backgroundViewOfHeaderViewStickingNavigationBar.addTopBorderWithColor(color: Style.BackgroundViewOfHeaderViewStickingNavigationBar.bottomBorderColor, width: Style.BackgroundViewOfHeaderViewStickingNavigationBar.bottomBorderWidth)
            
            for i in 1..<indexes[0].count {
                tableView.headerView(forSection: indexes[0].section + i)?.backgroundView?.backgroundColor = .clear
                tableView.headerView(forSection: indexes[0].section + i)?.backgroundView?.layer.sublayers = nil
            }
            
        }
    }
    
}

//MARK: - TableViewIndexDelegate
extension ArtworksTableViewController : TableViewIndexDelegate {
    
    func tableViewIndexProcessingTouches(_ tableViewIndex: TableViewIndex) {
        canPerformTableViewIndexAnimation = false
    }
    
    func tableViewIndexFinalizingTouches(_ tableViewIndex: TableViewIndex) {
        canPerformTableViewIndexAnimation = true
        guard let indexes = tableView.indexPathsForVisibleRows else { return }
        guard let heightTableHeaderView = tableView.tableHeaderView?.frame.height else {
            return
        }
        if indexes.count > 0 && indexes[0].section == 0 && tableView.contentOffset.y < heightTableHeaderView {
            tableViewIndexTrailingConstraint.constant = -self.tableViewIndex.frame.width
            for cell in tableView.visibleCells {
                if let generalTableViewCell = cell as? GeneralTableViewCell {
                    generalTableViewCell.trailingMarginConstraint.constant = self.tableViewIndex.frame.width
                }
            }
            UIView.animate(withDuration: 0.25, animations: {
                tableViewIndex.layoutIfNeeded()
                for cell in self.tableView.visibleCells {
                    cell.layoutIfNeeded()
                }
            })
        }
        
    }
    
    func tableViewIndexShouldScrollToTop(_ tableViewIndex: TableViewIndex) {
        tableView.setContentOffset(.zero, animated: false)
    }
    
    func tableViewIndex(_ tableViewIndex: TableViewIndex, didSelect item: UIView, at index: Int) -> Bool {
        let indexPath = IndexPath(row: 0, section: index)
        tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        
        return true // return true to produce haptic feedback on capable devices
    }
    
}

//MARK: - CLLocationManagerDelegate
extension ArtworksTableViewController : CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let errorCode = (error as NSError).code
        switch errorCode {
            
        case CLError.locationUnknown.rawValue:
            log.error("Core Location error: location unknown error. Error: \(error)")
            break
        case CLError.denied.rawValue:
            log.error("Core Location error: denied usage error. Error: \(error)")
            break
        case CLError.headingFailure.rawValue:
            log.error("Core Location error: heading failure error. Error: \(error)")
            break
        case CLError.network.rawValue:
            log.error("Core Location error: network error. Error: \(error)")
            break
        default:
            log.error("Core Location error: error unknown. Error: \(error)")
            break
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let userCoordinate = locations.last else {
            return
        }
        artworksTableViewDataSource.sort(by: .distance, coordinate: userCoordinate)
        tableViewIndex.indexOffset = UIOffset(horizontal: -16, vertical: 0)
        tableViewIndexWidthConstraint.constant = 44
        tableViewIndexTrailingConstraint.constant = -tableViewIndexWidthConstraint.constant
        tableView.separatorColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1)
        refreshControl.endRefreshing()
        tableView.isScrollEnabled = true
        tableView.reloadData()
        tableViewIndex.reloadData()
        manager.stopUpdatingLocation()
    }
    
}


