//
//  GeneralTableViewController.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-18.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit
import CoreData

final class GeneralTableViewController<T: ArtworksSettable & TextRepresentable>: SearchViewController, UITableViewDelegate, UIScrollViewDelegate, TableViewIndexDelegate {
    
    //MARK: - Properties
    //MARK: UI Properties
    // Table View
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    var tableViewDataSource : UITableViewDataSource?
    // Table View Index
    @IBOutlet weak var tableViewIndex: TableViewIndex!
    var tableViewIndexDataSource : TableViewIndexDataSource?
    @IBOutlet weak var tableViewIndexWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewIndexTrailingConstraint: NSLayoutConstraint!
    // Progress View
    var progressView : UIProgressView!
    
    //MARK: Strings
    let artists = NSLocalizedString("artists", tableName: "GeneralTableViewController", bundle: .main, value: "", comment: "").capitalizingFirstLetter()
    let materials = NSLocalizedString("materials", tableName: "GeneralTableViewController", bundle: .main, value: "", comment: "").capitalizingFirstLetter()
    let techniques = NSLocalizedString("techniques", tableName: "GeneralTableViewController", bundle: .main, value: "", comment: "").capitalizingFirstLetter()
    //MARK: Style for background view of header view stick navigation bar
    let backgroundColorBackgroundViewOfHeaderViewStickingNavigationBar = UIColor(red: 250.0/255.0, green: 217.0/255.0, blue: 1.0/255.0, alpha: 1)
    let shadowColorBackgroundViewOfHeaderViewStickingNavigationBar = UIColor.gray.cgColor
    let shadowOffsetBackgroundViewOfHeaderViewStickingNavigationBar = CGSize(width: 0, height: 0.05)
    let shadowRadiusBackgroundViewOfHeaderViewStickingNavigationBar = CGFloat(integerLiteral: 1)
    let shadowOpacityBackgroundViewOfHeaderViewStickingNavigationBar : Float = 1
    let borderColorBackgroundViewOfHeaderViewStickingNavigationBar : UIColor = .lightGray
    let bottomBorderWidthBackgroundViewOfHeaderViewStickingNavigationBar : CGFloat = 0.5
    //MARK: Properties
    var canPerformTableViewIndexAnimation = true
    var items = [T]()

    
    //MARK: - Overriden methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup tableviewdatasourcel
        adjustTableViewInsets()
        DispatchQueue.main.async {
            let tableViewDataSource = GeneralTableViewDataSource(items: self.items)
            self.tableViewDataSource = tableViewDataSource
            self.tableViewIndexDataSource = tableViewDataSource
            self.tableView.dataSource = tableViewDataSource
            self.tableViewIndex.dataSource = tableViewDataSource
            self.tableView.reloadData()
            self.tableViewIndex.reloadData()
        }
        
        tableView.delegate = self
        let tableHeaderView = MainListHeaderView.loadFromNib()
        tableHeaderView.titleLabel.text = title
        tableView.tableHeaderView = tableHeaderView
        let generalTableViewCellNib = UINib(nibName: String(describing: GeneralTableViewCell.self), bundle: .main)
        tableView.register(generalTableViewCellNib, forCellReuseIdentifier: GeneralTableViewCell.reuseIdentifier)
        tableViewIndex.delegate = self
        tableViewIndex.itemSpacing = 2
        tableViewIndexTrailingConstraint.constant = -tableViewIndex.frame.width
        tableViewIndex.indexOffset = UIOffset(horizontal: -4, vertical: 0)
        tableViewIndex.backgroundColor = .clear
        tableViewIndex.backgroundView.backgroundColor = .clear
        setTransparentNavigationBar(tintColor: .black)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.tableHeaderView?.setNeedsLayout()
        tableView.tableHeaderView?.layoutIfNeeded()
        tableView.tableHeaderView?.updateConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sizeHeaderToFit()
    }
    
    private func sizeHeaderToFit() {
        let tableHeaderView = tableView.tableHeaderView!
        let tableEnclosingView = tableHeaderView.subviews[0]
        
        let width = tableView.frame.width
        let height = tableEnclosingView.frame.height + 14.0
        var frame = tableHeaderView.frame
        frame.size.height = height
        frame.size.width = width
        tableHeaderView.frame = frame
        tableView.tableHeaderView = tableHeaderView
        tableHeaderView.setNeedsLayout()
        tableHeaderView.layoutIfNeeded()
    }
    
    private func adjustTableViewInsets() {
        // Disable all automatic
        automaticallyAdjustsScrollViewInsets = false
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
            tableView.insetsContentViewsToSafeArea = false
        }
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
        tableViewTopConstraint.constant = statusBarHeight + navigationBarHeight
    }
    
    
    //MARK: - UITableViewDelegate
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
        let storyboard = UIStoryboard(name: "Artworks", bundle: .main)
        let artworksTableViewController = storyboard.instantiateViewController(withIdentifier: "ArtworksTableViewController") as! ArtworksTableViewController
        artworksTableViewController.title = cell.titleLabel.text
        artworksTableViewController.artworks = cell.artworks
        navigationController?.pushViewController(artworksTableViewController, animated: true)
    }
    
    //MARK: - ScrollViewDelegate
    // Code le fait que les headers views de chaque section change de couleur d'arrière-plan lorsque ceux-ci stick au top de la view
    // lorsque que l'on scrolle
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard let heightTableHeaderView = tableView.tableHeaderView?.frame.height,
            let indexes = tableView.indexPathsForVisibleRows,
            !indexes.isEmpty else {
                return
        }
        
        // Show title if the user scrolled below the main tableHeaderView
        let didTheUserScrolledBelowTableHeaderView = tableView.contentOffset.y >= heightTableHeaderView
        switch (didTheUserScrolledBelowTableHeaderView, navigationItem.titleView) {
        case (true, let titleView) where titleView != nil:
            navigationItem.titleView = nil
        case (false, nil):
            navigationItem.titleView = UIView()
        default:
            break
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
                // Hide the title in the navigation bar (navigation item) by setting an empty view
                return
            }
            
            
            backgroundViewOfHeaderViewStickingNavigationBar.backgroundColor = backgroundColorBackgroundViewOfHeaderViewStickingNavigationBar
            backgroundViewOfHeaderViewStickingNavigationBar.layer.shadowColor = shadowColorBackgroundViewOfHeaderViewStickingNavigationBar
            backgroundViewOfHeaderViewStickingNavigationBar.layer.shadowOffset = shadowOffsetBackgroundViewOfHeaderViewStickingNavigationBar
            backgroundViewOfHeaderViewStickingNavigationBar.layer.shadowRadius = shadowRadiusBackgroundViewOfHeaderViewStickingNavigationBar
            backgroundViewOfHeaderViewStickingNavigationBar.layer.shadowOpacity = shadowOpacityBackgroundViewOfHeaderViewStickingNavigationBar
            backgroundViewOfHeaderViewStickingNavigationBar.addBottomBorderWithColor(
                color: borderColorBackgroundViewOfHeaderViewStickingNavigationBar,
                width: bottomBorderWidthBackgroundViewOfHeaderViewStickingNavigationBar)
            backgroundViewOfHeaderViewStickingNavigationBar.addTopBorderWithColor(
                color: borderColorBackgroundViewOfHeaderViewStickingNavigationBar,
                width: bottomBorderWidthBackgroundViewOfHeaderViewStickingNavigationBar)
            
            for i in 1..<indexes[0].count {
                tableView.headerView(forSection: indexes[0].section + i)?.backgroundView?.backgroundColor = .clear
                tableView.headerView(forSection: indexes[0].section + i)?.backgroundView?.layer.sublayers = nil
            }
            
        }
    }
    
    
    //MARK: - TableViewIndexDelegate
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
