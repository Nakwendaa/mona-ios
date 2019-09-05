//
//  ArtworkDetailsImagePickerControllerDelegate.swift
//  mona-ios
//
//  Created by Paul Chaffanet on 2019-05-22.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit
import Photos
import CoreData

class ArtworkDetailsImagePickerControllerDelegate : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - Types
    struct Segues {
        static let showArtworkDetailsRatingViewController = "showArtworkDetailsRatingViewController"
        static let presentWonBadge = "presentWonBadge"
    }
    
    let artwork: Artwork
    let onSuccess : (() -> Void)?
    let onFailure : ((Error) -> Void)?
    
    init(artwork: Artwork, onSuccess: (() -> Void)?, onFailure: ((Error) -> Void)?) {
        self.artwork = artwork
        self.onSuccess = onSuccess
        self.onFailure = onFailure
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Pop the picker if the user canceled.
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        
        guard let originalImage = info[.originalImage] as? UIImage else {
            log.error("Expected a dictionary containing an image, but was provided the following: \(info)")
            return
        }
        
        MonaPhotosAlbum.shared.save(image: forcePortraitMode(originalImage: originalImage),
                                    onSuccess: {
                                        localIdentifier in
                                        //log.info("Successfully saved image to Camera Roll with localIdentifier \(localIdentifier).")
                                        let entityName = String(describing: Photo.self)
                                        let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: AppData.context)
                                        let photo = Photo(entity: entityDescription!, insertInto: AppData.context)
                                        photo.localIdentifier = localIdentifier
                                        self.artwork.addToPhotos(photo)
                                        self.artwork.photoSent = false
                                        self.artwork.isCollected = true
                                        self.artwork.isTargeted = false
                                        
                                        /*
                                        MonaAPI.shared.artwork(id: Int(self.artwork.id), rating: nil, comment: nil, photo: originalImage) { result in
                                            switch result {
                                            case .success(_):
                                                log.info("Successful upload for artwork's photo with id: \(self.artwork.id).")
                                                self.artwork.photoSent = true
                                                do {
                                                    try AppData.context.save()
                                                }
                                                catch {
                                                    log.error("Failed to save context: \(error)")
                                                }
                                            case .failure(let userArtworkError):
                                                log.error("Failed to upload photo for artwork with id: \(self.artwork.id).")
                                                log.error(userArtworkError)
                                                log.error(userArtworkError.localizedDescription)
                                            }
                                        }
                                        */
                                        do {
                                            try AppData.context.save()
                                        }
                                        catch {
                                            log.error("Failed to save context: \(error)")
                                        }
                                        
                                        guard let onSuccess = self.onSuccess else {
                                            return
                                        }
                                        onSuccess()
                                    },
                                    onFailure: {
                                        error in
                                        guard let onFailure = self.onFailure else {
                                            return
                                        }
                                        onFailure(error)
                                    })
        
        
        if !artwork.isCollected {
            let notCollectedBadges = AppData.badges.filter { !$0.isCollected }
            for notCollectedBadge in notCollectedBadges {
                //print("notCollectedBadge.text: \(notCollectedBadge.text)")
                //print("artworks.district.text: \(artwork.district.text)")
                if notCollectedBadge.text == artwork.district.text {
                    notCollectedBadge.currentValue += 1
                }
                else if ["1", "3", "5", "8", "10", "15", "20", "25", "30"].contains(notCollectedBadge.collectedImageName) {
                    notCollectedBadge.currentValue += 1
                }
            }
            let newlyCollectedBadges = notCollectedBadges.filter { $0.isCollected }
            let storyboard = UIStoryboard(name: "Artworks", bundle: .main)
            
            if !newlyCollectedBadges.isEmpty {
                let navVC = storyboard.instantiateViewController(withIdentifier: "WonBadgeNavigationViewController") as! UINavigationController
                let wonBadgeVC = navVC.viewControllers[0] as! WonBadgeViewController
                //let wonBadgeVC = storyboard.instantiateViewController(withIdentifier: "WonBadgeViewController") as! WonBadgeViewController
                wonBadgeVC.badges = newlyCollectedBadges
                picker.present(navVC, animated: true, completion: nil)
            }
            
            let artworkDetailsRatingVC = storyboard.instantiateViewController(withIdentifier: "RatingViewController") as! ArtworkDetailsRatingViewController
            artworkDetailsRatingVC.artwork = artwork
            picker.pushViewController(artworkDetailsRatingVC, animated: true)
        }
        else {
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    private func forcePortraitMode(originalImage image: UIImage) -> UIImage {
        
        let portraitImageResult : UIImage
        
        switch image.imageOrientation {
        case .up:
            log.debug("Image's orientation is up")
            portraitImageResult = UIImage(cgImage: image.cgImage!, scale: CGFloat(1.0), orientation: .right)
            break
        case .down:
            log.debug("Image's orientation is down")
            portraitImageResult = UIImage(cgImage: image.cgImage!, scale: CGFloat(1.0), orientation: .right)
            break
        case .left:
            log.debug("Image's orientation is left")
            portraitImageResult = UIImage(cgImage: image.cgImage!, scale: CGFloat(1.0), orientation: image.imageOrientation)
            break
        case .right:
            log.debug("Image's orientation is right")
            portraitImageResult = UIImage(cgImage: image.cgImage!, scale: CGFloat(1.0), orientation: image.imageOrientation)
            break
        case .upMirrored:
            log.debug("Image's orientation is upMirrored")
            portraitImageResult = UIImage(cgImage: image.cgImage!, scale: CGFloat(1.0), orientation: image.imageOrientation)
            break
        case .downMirrored:
            log.debug("Image's orientation is downMirrored")
            portraitImageResult = UIImage(cgImage: image.cgImage!, scale: CGFloat(1.0), orientation: image.imageOrientation)
            break
        case .leftMirrored:
            log.debug("Image's orientation is leftMirrored")
            portraitImageResult = UIImage(cgImage: image.cgImage!, scale: CGFloat(1.0), orientation: image.imageOrientation)
            break
        case .rightMirrored:
            log.debug("Image's orientation is rightMirrored")
            portraitImageResult = UIImage(cgImage: image.cgImage!, scale: CGFloat(1.0), orientation: image.imageOrientation)
            break
        @unknown default:
            log.debug("Image's orientation is unknow")
            portraitImageResult = UIImage(cgImage: image.cgImage!, scale: CGFloat(1.0), orientation: image.imageOrientation)
        }
        
        return portraitImageResult
    }
}

