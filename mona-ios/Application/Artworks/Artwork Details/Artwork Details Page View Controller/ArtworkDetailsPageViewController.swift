//
//  ArtworkDetailsPageViewController.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-22.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

class ArtworkDetailsPageViewController : UIPageViewController, UIPageViewControllerDelegate {
    
    var artwork : Artwork!
    let artworkDetailsDescriptionViewController = UIStoryboard(name: "Artworks", bundle: .main).instantiateViewController(withIdentifier: "ArtworkDetailsDescriptionViewController") as! ArtworkDetailsDescriptionViewController
    let artworkDetailsMapViewController = UIStoryboard(name: "Artworks", bundle: .main).instantiateViewController(withIdentifier: "ArtworkDetailsMapViewController") as! ArtworkDetailsMapViewController
    
    lazy var VCArr : [UIViewController] = {
        return [artworkDetailsDescriptionViewController,
                artworkDetailsMapViewController]
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        artworkDetailsDescriptionViewController.artwork = artwork
        artworkDetailsMapViewController.artwork = artwork
        setViewControllers([artworkDetailsDescriptionViewController], direction: .forward, animated: true, completion: nil)
        if artwork.isCollected {
            let artworkDetailsCommentRatingViewController = UIStoryboard(name: "Artworks", bundle: .main).instantiateViewController(withIdentifier: "ArtworkDetailsCommentRatingViewController") as! ArtworkDetailsCommentRatingViewController

            artworkDetailsCommentRatingViewController.artwork = artwork
            VCArr.append(artworkDetailsCommentRatingViewController)
        }
    }
    
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "showArtworkDetailsMapViewController" {
            guard let artworkDetailsMapViewController = segue.destination as? ArtworkDetailsMapViewController else {
                return
            }
            artworkDetailsMapViewController.artwork = artwork
        }
    }
    */
    
    func enableCommentRatingView() {
        if VCArr.count == 3 {
            VCArr.remove(at: 2)
        }
        let artworkDetailsCommentRatingViewController = UIStoryboard(name: "Artworks", bundle: nil).instantiateViewController(withIdentifier: "ArtworkDetailsCommentRatingViewController") as! ArtworkDetailsCommentRatingViewController
        artworkDetailsCommentRatingViewController.artwork = artwork
        VCArr.append(artworkDetailsCommentRatingViewController)
        setViewControllers([VCArr[0]], direction: .forward, animated: true, completion: nil)
    }
    
}

extension ArtworkDetailsPageViewController : UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = VCArr.firstIndex(of: viewController) else {
            return nil
        }
        if viewControllerIndex == 0 {
            return nil
        }
        else {
            return VCArr[viewControllerIndex-1]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = VCArr.firstIndex(of: viewController) else {
            return nil
        }
        
        if viewControllerIndex == 0 {
            return VCArr[1]
        }
        
        if viewControllerIndex == 1 && VCArr.count == 3 {
            return VCArr[2]
        }
        
        return nil
    }
    
    public func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return VCArr.count
    }
    
    public func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = VCArr.firstIndex(of: firstViewController) else {
                return 0
        }
        return firstViewControllerIndex
    }
    
}

