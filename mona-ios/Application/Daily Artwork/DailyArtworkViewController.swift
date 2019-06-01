//
//  DailyArtworkViewController.swift
//  mona
//
//  Created by Paul Chaffanet on 2018-09-12.
//  Copyright © 2018 Lena Krause. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class DailyArtworkViewController: UIViewController, Contextualizable {
    
    //MARK: - Types
    struct Segues {
        struct Identifiers {
            static let showDailyArtworkImagePickerController = "showDailyArtworkImagePickerController"
            static let showDailyArtworkMapViewController = "showDailyArtworkMapViewController"
        }
    }
    
    struct Strings {
        // Strings file
        private static let tableName = "DailyArtworkViewController"
        
        struct General {
            static let title = NSLocalizedString("daily artwork", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        }
        
        struct Labels {
            static let title = NSLocalizedString("daily artwork", tableName: tableName, bundle: .main, value: "", comment: "").uppercased()
            static let unknownTitle = NSLocalizedString("unknown title", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
            static let unknownDate = NSLocalizedString("unknown date", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
            static let unknownArtist = NSLocalizedString("unknown artist", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
            static let unknownCategory = NSLocalizedString("unknown category", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
            static let unknownDimensions = NSLocalizedString("unknown dimensions", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        }
        
        struct NeedAuthorizationCameraOpenSettings {
            static let title = NSLocalizedString("need authorization camera open settings title", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
            static let message = NSLocalizedString("need authorization camera open settings message", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        }
        
        struct CameraUnavailable {
            static let title = NSLocalizedString("camera unavailable title", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
            static let message = NSLocalizedString("camera unavailable message", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        }
    }
    
    //MARK: - Properties
    var viewContext: NSManagedObjectContext?
    var artwork: Artwork?
    
    //MARK: - UI Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var artworkTitleLabel: UILabel!
    @IBOutlet weak var artistsAndDateLabel: UILabel!
    @IBOutlet weak var dimensionsLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var subcategoryLabel: UILabel!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    
    //var artworkImagePickerControllerDelegate : ArtworkImagePickerControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave), name: Notification.Name.NSManagedObjectContextDidSave, object: viewContext)
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.Identifiers.showDailyArtworkMapViewController {
            let dailyArtworkMapViewController = segue.destination as! DailyArtworkMapViewController
            dailyArtworkMapViewController.artwork = artwork
            showNavigationBar()
        }
        else if segue.identifier == Segues.Identifiers.showDailyArtworkImagePickerController {
            let dailyArtworkImagePickerController = segue.destination as! DailyArtworkImagePickerController
            dailyArtworkImagePickerController.sourceType = .camera
            dailyArtworkImagePickerController.artwork = artwork
        }
    }
    
    @objc private func contextDidSave() {
        if self.artwork == nil {
            setup()
        }
    }
    
    /**
     *
     */
    private func setup() {
        guard let viewContext = viewContext, let artwork = getDailyArtwork(context: viewContext)  else {
            return
        }
        self.artwork = artwork
        setupViewController(artwork: artwork)
    }
    
    /**
     * Setup the artwork
     */
    private func getDailyArtwork(context: NSManagedObjectContext) -> Artwork? {
        let lowerBound = 1
        let upperBound = Artwork.getCount(context: context)
        guard upperBound >= lowerBound else {
            return nil
        }
        let random = Int.random(in: lowerBound...upperBound)
        return Artwork.fetchRequest(id: Int16(random), context: context)
    }
    
    /**
     * Setup the view controller.
     */
    private func setupViewController(artwork: Artwork) {
        
        title = Strings.General.title
        // Set title of the view controller as "DAILY ARTWORK" or "OEUVRE DU JOUR"
        titleLabel.text = Strings.Labels.title
        //imageView.image = UIImage(named: "Daily Artwork Image")
       
        // Set the title of the daily artwork
        if let title = artwork.title {
            artworkTitleLabel.text = title
        }
        else {
            artworkTitleLabel.text = Strings.Labels.unknownTitle
        }
        
        // Set the artists for the daily artwork
        if artwork.artists.isEmpty {
            artistsAndDateLabel.text = Strings.Labels.unknownArtist + ", "
        }
        else {
            artistsAndDateLabel.text = artwork.artists.map({
                $0.name ?? Strings.Labels.unknownArtist
            }).joined(separator: ",") + ", "
        }
        
        // Concat the date to the artists for the daily artwork
        if let date = artwork.date {
            artistsAndDateLabel.text! += date.toString(format: "yyyy")
        }
        else {
            artistsAndDateLabel.text! += Strings.Labels.unknownDate
        }
        
        
        // Set the dimensions of the daily artwork
        if let dimensions = artwork.dimensions {
            dimensionsLabel.text = dimensions
        }
        else {
            dimensionsLabel.text = Strings.Labels.unknownDimensions
        }
        
        // Set the category of the daily artwork
        categoryLabel.text = artwork.category.localizedName
        
        // Set the subcategory of the daily artwork
        if let subcategory = artwork.subcategory {
            subcategoryLabel.text = subcategory.localizedName
        }
        else {
            subcategoryLabel.removeFromSuperview()
        }
    }
    
    private func showNavigationBar() {
        navigationController?.navigationBar.isHidden = false
    }
    
    private func hideNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        
        func show() {
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                performSegue(withIdentifier: Segues.Identifiers.showDailyArtworkImagePickerController, sender: self)
            }
            else {
                log.error("Camera is not available. Cannot present \(String(describing: self)).")
                UIAlertController.presentMessage(from: self,
                                                 title: Strings.CameraUnavailable.title,
                                                 message: Strings.CameraUnavailable.message,
                                                 completion: nil)
            }
        }
        
        
        let status =  AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            show()
            break
        case .denied, .restricted:
            // Faire une demande de modifications des réglages
            UIAlertController.presentOpenSettings(from: self,
                                                  title: Strings.NeedAuthorizationCameraOpenSettings.title,
                                                  message: Strings.NeedAuthorizationCameraOpenSettings.message,
                                                  completion: nil)
            break
        default:
            // demander pour accés
            AVCaptureDevice.requestAccess(for: .video, completionHandler: {
                (granted: Bool) in
                if granted {
                    show()
                }
            })
            break
        }

    }
}
