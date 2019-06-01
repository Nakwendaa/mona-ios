//
//  GeneralTableViewController.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-18.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit
import CoreData

class GeneralTableViewController : UIViewController, Contextualizable {
    
    //Contextualizable
    var viewContext: NSManagedObjectContext?
    
    // Table View
    @IBOutlet weak var tableView: UITableView!
    var tableViewDataSource : UITableViewDataSource?
    @IBOutlet weak var headerTableViewLabel: UILabel!
    
    // Table View Index
    @IBOutlet weak var tableViewIndex: TableViewIndex!
    var tableViewIndexDataSource : TableViewIndexDataSource?
    @IBOutlet weak var tableViewIndexWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewIndexTrailingConstraint: NSLayoutConstraint!
   
    // Table View Index Animation
    var canPerformTableViewIndexAnimation = true
    
    struct Strings {
        private static let tableName = "GeneralTableViewController"
        static let artists = NSLocalizedString("artists", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let materials = NSLocalizedString("materials", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        static let techniques = NSLocalizedString("techniques", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
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
    
    var progressView : UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch title {
        case Strings.artists:
            setup(type: Artist.self)
            break
        case Strings.materials:
            setup(type: Material.self)
            break
        case Strings.techniques:
            //setupProgressView()
            setup(type: Technique.self)
            break
        default:
            break
        }
        
        headerTableViewLabel.text = title
        tableView.delegate = self
        tableViewIndex.delegate = self
        tableViewIndex.itemSpacing = 2
        tableViewIndexTrailingConstraint.constant = -tableViewIndex.frame.width
        tableViewIndex.indexOffset = UIOffset(horizontal: -4, vertical: 0)
        //tableViewIndex.backgroundColor = .clear
        //tableViewIndex.backgroundView.backgroundColor = .clear
        setTransparentNavigationBar(tintColor: .black)
    }
    
    private func setup<T : NSManagedObject & Namable>(type: T.Type) {
        guard let context = viewContext else {
            return
        }
        let privateManagedContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedContext.parent = context

        let syncNamablesFetchRequest : NSFetchRequest<T.T> = T.fetchRequest()
        let asyncNamablesFetchRequest = NSAsynchronousFetchRequest(fetchRequest: syncNamablesFetchRequest) { result in
            guard let namablesAsync = result.finalResult else { return }
            
            DispatchQueue.main.async {
                let namables: [T] = namablesAsync.lazy
                    .compactMap { $0.objectID } // Retrives all the objectsID
                    .compactMap { context.object(with: $0) as? T }
                
                // Techniques
                let tableViewDataSource = NamableTableViewDataSource(namables: namables)
                self.tableViewDataSource = tableViewDataSource
                self.tableViewIndexDataSource = tableViewDataSource
                self.tableView.dataSource = tableViewDataSource
                self.tableViewIndex.dataSource = tableViewDataSource
                //self.progressView.removeFromSuperview()
                self.tableView.reloadData()
                self.tableViewIndex.reloadData()
            }
        }
        do {
            // Creates a new `Progress` object
            let progress = Progress(totalUnitCount: 1)
            
            // Sets the new progess as default one in the current thread
            progress.becomeCurrent(withPendingUnitCount: 1)
            
            // Keeps a reference of `NSPersistentStoreAsynchronousResult` returned by `execute`
            let fetchResult = try privateManagedContext.execute(asyncNamablesFetchRequest) as? NSPersistentStoreAsynchronousResult
            
            // Resigns the current progress
            progress.resignCurrent()
            
            // Adds observer
            fetchResult?.progress?.addObserver(self, forKeyPath: #keyPath(Progress.completedUnitCount), options: .new, context: nil)
        }
        catch {
            log.error("Failed to fetch techniques asynchronously. Error: \(error)")
        }
    }
    
    /*
    private func setupProgressView() {
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.center = view.center
        progressView.setProgress(0, animated: true)
        progressView.trackTintColor = .lightGray
        progressView.tintColor = .blue
        view.addSubview(progressView)
    }
    */
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(Progress.completedUnitCount), let newValue = change?[.newKey] as? Float {
            //progressView.setProgress(newValue, animated: true)
        }
    }
    
}

//MARK: - UITableViewDelegate
extension GeneralTableViewController : UITableViewDelegate {
    
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
        let cell = tableView.cellForRow(at: indexPath) as! GeneralTableViewCell
        let viewController = UIStoryboard(name: "Artworks", bundle: nil).instantiateViewController(withIdentifier: "ArtworksTableViewController") as! ArtworksTableViewController
        viewController.artworksIds = cell.artworksIds
        viewController.title = cell.titleLabel.text
        viewController.viewContext = viewContext
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Scroll View Delegate
extension GeneralTableViewController : UIScrollViewDelegate {
    
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
extension GeneralTableViewController : TableViewIndexDelegate {
    
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
