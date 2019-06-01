//
//  ArtworkDetailsViewController.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-22.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import AVFoundation
import Photos

class ArtworkDetailsViewController: UIViewController {
    
    //MARK: - Types
    struct Segues {
        static let embedArtworkDetailsPageViewController = "embedArtworkDetailsPageViewController"
        static let showArtworkDetailsFullMapViewController = "showArtworkDetailsFullMapViewController"
        static let showArtworkDetailsImagePickerController = "showArtworkDetailsImagePickerController"
    }
    
    struct Strings {
        private static let tableName = "ArtworkDetailsViewController"
        static let untitled = NSLocalizedString("untitled", tableName: tableName, bundle: .main, value: "", comment: "").capitalizingFirstLetter()
        
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
    let locationManager = CLLocationManager()
    var artwork : Artwork!
    
    //MARK: - Utils properties
    var keyboardWasShown = false
    
    //MARK: - UI Properties
    var pageVC: ArtworkDetailsPageViewController!
    // View
    @IBOutlet var viewTapGesture: UITapGestureRecognizer!
    // Photo Image View
    @IBOutlet weak var photoImageView: UIImageView!
    // Details View
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var detailsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var detailsViewBottomConstraint: NSLayoutConstraint!
    // Details View's Header
    @IBOutlet weak var headerDetailsView: UIView!
    // Details View's Header's Title
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabelHeightLayoutConstraint: NSLayoutConstraint!
    // Details View's Camera Button
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var defaultView: UIView!
    @IBOutlet weak var defaultCameraButton: UIButton!
    
    //MARK: - Overriden methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeaderViewAndTitle()
        setupDetailsView()
        self.setupDefaultView()
        DispatchQueue.main.async {
            self.setupPhotoImageView()
        }
        setTransparentNavigationBar(tintColor: .black)
        setupNotificationsForKeyboard()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == Segues.embedArtworkDetailsPageViewController,
            let pageVC = segue.destination as? ArtworkDetailsPageViewController {
            self.pageVC = pageVC
            self.pageVC.artwork = artwork
        }
        else if segue.identifier == Segues.showArtworkDetailsFullMapViewController,
            let vc = segue.destination as? ArtworkDetailsFullMapViewController {
            vc.artwork = artwork
        }
        else if segue.identifier == Segues.showArtworkDetailsImagePickerController,
            let vc = segue.destination as? ArtworkDetailsImagePickerController {
            vc.sourceType = .camera
            vc.artwork = artwork
            vc.onSuccess = {
                DispatchQueue.main.async {
                    self.setupDefaultView()
                    self.setupPhotoImageView()
                    self.pageVC.enableCommentRatingView()
                }
            }
        }
        
    }
    
    //MARK: - Private methods
    private func setupHeaderViewAndTitle() {
        // Title
        headerDetailsView.addBottomBorderWithColor(color: .init(white: 1, alpha: 0), width: 1)
        if let title = artwork.title {
            titleLabel.text = title
        }
        else {
            titleLabel.text = Strings.untitled
        }
        if titleLabel.isTruncated {
            titleLabelHeightLayoutConstraint.constant += 24
            titleLabel.layoutIfNeeded()
            titleLabel.updateConstraints()
        }
    }
    
    private func setupDetailsView() {
        detailsView.layer.shadowColor = UIColor.black.cgColor
        detailsView.layer.shadowOpacity = 1
        detailsView.layer.shadowOffset = CGSize.zero
        detailsView.layer.shadowRadius = 5
    }
    
    private func setupDefaultView() {
        guard artwork.isCollected, defaultView != nil else {
            return
        }
        defaultView.removeFromSuperview()
    }
    
    private func setupPhotoImageView() {
        if artwork.isCollected {
            guard   let photosOrderedSet = artwork.photos,
                    let lastPhotoAdded = photosOrderedSet.lastObject as? Photo,
                    let asset = MonaPhotosAlbum.shared.fetchAsset(withLocalIdentifier: lastPhotoAdded.localIdentifier)  else {
                return
            }
            
            // Get image from asset
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            option.deliveryMode = .highQualityFormat
            option.isNetworkAccessAllowed = true
            option.version = .original
            option.isSynchronous = false
            manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: option, resultHandler: {
                result, info in
                if let image = result {
                    self.photoImageView.image = image
                }
            })
        }
    }
    
    private func setupNotificationsForKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func makeAnimation() {
        UIView.animate(withDuration: 0.6, animations: {
            if self.detailsViewBottomConstraint.constant == 0 {
                self.detailsViewBottomConstraint.constant = -self.detailsView.frame.height + self.headerDetailsView.frame.height
                self.detailsView.backgroundColor = self.detailsView.backgroundColor?.withAlphaComponent(0.4)
                self.titleLabel.textColor = UIColor(red: CGFloat(18)/255.0, green: CGFloat(22)/255.0, blue: CGFloat(26)/255.0, alpha: 1.0)
            }
            else {
                self.detailsViewBottomConstraint.constant = 0
                self.detailsView.backgroundColor = self.detailsView.backgroundColor?.withAlphaComponent(1.0)
                self.titleLabel.textColor = UIColor(red: CGFloat(18)/255.0, green: CGFloat(22)/255.0, blue: CGFloat(26)/255.0, alpha: 1.0)
            }
            self.view.layoutIfNeeded()
        })
    }
    
    //MARK: - Actions
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        func show() {
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                performSegue(withIdentifier: Segues.showArtworkDetailsImagePickerController, sender: self)
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
    
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        makeAnimation()
        view.endEditing(true)
    }
    
    
    //MARK: - Notifications handlers
    @objc func keyboardWasShown(notification: NSNotification)
    {
        keyboardWasShown = true
        let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height - (tabBarController?.tabBar.frame.height ?? 0)
        log.debug("Keyboard's height is \(keyboardHeight)")
        
        UIView.animate(withDuration: 0.6, animations: {
            log.debug("detailsViewBottomConstraint.constant is \(self.detailsViewBottomConstraint.constant)")
            self.detailsViewBottomConstraint.constant = keyboardHeight
            log.debug("detailsViewBottomConstraint.constant is \(self.detailsViewBottomConstraint.constant)")
            self.view.layoutIfNeeded()
        })
    }
    
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        
        keyboardWasShown = false
        
        UIView.animate(withDuration: 0.6, animations: {
            log.debug("detailsViewBottomConstraint.constant is \(self.detailsViewBottomConstraint.constant)")
            self.detailsViewBottomConstraint.constant = 0
            log.debug("detailsViewBottomConstraint.constant is \(self.detailsViewBottomConstraint.constant)")
            self.view.layoutIfNeeded()
        })
    }
}
