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

class DailyArtworkViewController: UIViewController {
    
    //MARK: - Types
    struct Segues {
        struct Identifiers {
            static let showDailyArtworkMapViewController = "showDailyArtworkMapViewController"
            static let showArtworkDetailsViewController = "showArtworkDetailsViewController"
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
    var artwork: Artwork?
    var imagePickerDelegate: ArtworkDetailsImagePickerControllerDelegate!
    
    //MARK: - UI Properties
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var artworkDetailsStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var artworkTitleLabel: UILabel!
    @IBOutlet weak var artistsAndDateLabel: UILabel!
    @IBOutlet weak var dimensionsLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var subcategoryLabel: UILabel!
    //MARK: Buttons
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var targetButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    
    //MARK: - Overriden methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Provisoire, améliorer ceci quand ça sera possible
        contentView.frame.size.height = max(contentView.frame.size.height, mainStackView.frame.size.height + tabBarController!.tabBar.frame.height + 32)
        scrollView.contentSize = contentView.frame.size
        // Fin de la chose provisoire
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case Segues.Identifiers.showDailyArtworkMapViewController:
            let dailyArtworkMapViewController = segue.destination as! DailyArtworkMapViewController
            dailyArtworkMapViewController.artwork = artwork
            showNavigationBar()
        case Segues.Identifiers.showArtworkDetailsViewController:
            let artworkDetailsViewController = segue.destination as! ArtworkDetailsViewController
            artworkDetailsViewController.artwork = artwork
            showNavigationBar()
        default:
            return
        }
        
    }
    


    

    private func getDailyArtwork() -> Artwork? {
        let lowerBound = 0
        let upperBound = AppData.artworks.count
        guard upperBound >= lowerBound else {
            return nil
        }
        let random = Int.random(in: lowerBound..<upperBound)
        return AppData.artworks[random]
    }
    
    private func setup() {
        artwork = getDailyArtwork()
        guard let artwork = artwork else {
            return
        }
        imagePickerDelegate = ArtworkDetailsImagePickerControllerDelegate(
            artwork: artwork,
            onSuccess: nil,
            onFailure: nil
        )
        setupViewController(artwork: artwork)
    }
    
    @objc private func artworkDetailsStackViewTapped() {
        performSegue(withIdentifier: Segues.Identifiers.showArtworkDetailsViewController, sender: nil)
    }
    
    private func setupViewController(artwork: Artwork) {
        
        let artworkDetailsTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(artworkDetailsStackViewTapped))
        artworkDetailsStackView.addGestureRecognizer(artworkDetailsTapGestureRecognizer)
        
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
        categoryLabel.text = artwork.category.text
        
        // Set the subcategory of the daily artwork
        if let subcategory = artwork.subcategory {
            subcategoryLabel.text = subcategory.text
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
    
    //MARK: - Actions
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        
        func show() {
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                let imagePickerController = UIImagePickerController()
                imagePickerController.sourceType = .camera
                imagePickerController.delegate = imagePickerDelegate
                present(imagePickerController, animated: true, completion: nil)
            }
            else {
                log.error("Camera is not available. Cannot present \(String(describing: self)).")
                UIAlertController.presentMessage(
                    from: self,
                    title: Strings.CameraUnavailable.title,
                    message: Strings.CameraUnavailable.message,
                    okCompletion: nil,
                    presentCompletion: nil
                )
            }
        }
        
        
        let status =  AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            show()
            break
        case .denied, .restricted:
            // Faire une demande de modifications des réglages
            UIAlertController.presentOpenSettings(
                from: self,
                title: Strings.NeedAuthorizationCameraOpenSettings.title,
                message: Strings.NeedAuthorizationCameraOpenSettings.message,
                cancelCompletion: nil,
                openSettingsCompletion: nil,
                presentCompletion: nil
            )
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
    
    @IBAction func targetButtonTapped(_ sender: UIButton) {
        
        targetButton.isSelected = !targetButton.isSelected
        
        guard let artwork = artwork else {
            targetButton.isSelected = targetButton.isSelected ? false : targetButton.isSelected
            return
        }
        
        artwork.isTargeted = targetButton.isSelected
        
        DispatchQueue.main.async {
            do {
                try AppData.context.save()
            }
            catch {
                log.error("Failed to save context: \(error)")
                return
            }
        }
    }
    
}
