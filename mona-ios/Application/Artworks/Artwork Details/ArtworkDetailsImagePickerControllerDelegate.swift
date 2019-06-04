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

class ArtworkDetailsImagePickerControllerDelegate : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, Contextualizable {
    
    //MARK: - Types
    struct Segues {
        static let showArtworkDetailsRatingViewController = "showArtworkDetailsRatingViewController"
        static let presentWonBadge = "presentWonBadge"
    }
    
    weak var artwork: Artwork?
    //MARK: - Contextualizable
    var viewContext: NSManagedObjectContext?
    
    let onSuccess : (() -> Void)?
    let onFailure : ((Error) -> Void)?
    
    init(artwork: Artwork?, onSuccess: (() -> Void)?, onFailure: ((Error) -> Void)?) {
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
        
        guard let artwork = self.artwork else {
            log.debug("artwork property of ArtworkDetailsImagePickerControllerDelegate is nil.")
            return
        }
        
        guard let originalImage = info[.originalImage] as? UIImage else {
            log.error("Expected a dictionary containing an image, but was provided the following: \(info)")
            return
        }
        
        MonaPhotosAlbum.shared.save(image: originalImage,
                                    onSuccess: {
                                        localIdentifier in
                                        log.info("Successfully saved image to Camera Roll with localIdentifier \(localIdentifier).")
                                        guard let context = self.viewContext else {
                                            return
                                        }
                                        let entityName = String(describing: Photo.self)
                                        let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: context)
                                        let photo = Photo(entity: entityDescription!, insertInto: context)
                                        photo.localIdentifier = localIdentifier
                                        artwork.addToPhotos(photo)
                                        artwork.photoSent = false
                                        artwork.isCollected = true
                                        artwork.isTargeted = false
                                        
                                        /*
                                        CoreDataStack.fetchAsynchronously(type: Badge.self, context: context, entityName: "Badge") { badges, privateManagedContext in
                                            for badge in badges {
                                                if badge.localizedName == artwork.district.name {
                                                    badge.currentValue += 1
                                                }
                                                else if ["1", "3", "5", "8", "10", "15", "20", "25", "30"].contains(badge.localizedName) {
                                                    badge.currentValue += 1
                                                }
                                            }
                                            do {
                                                try privateManagedContext.save()
                                                do {
                                                    try context.save()
                                                }
                                                catch {
                                                    log.error("Failed to save context: \(error)")
                                                }
                                            }
                                            catch {
                                                log.error("Failed to save context: \(error)")
                                            }
                                        }
                                        */
                                        

                                        MonaAPI.shared.artwork(id: Int(artwork.id), rating: nil, comment: nil, photo: originalImage) { (result) in
                                            switch result {
                                            case .success(_):
                                                log.info("Successful upload for artwork's photo with id: \(artwork.id).")
                                                artwork.photoSent = true
                                                context.mergePolicy = NSOverwriteMergePolicy
                                                do {
                                                    try context.save()
                                                }
                                                catch {
                                                    log.error("Failed to save context: \(error)")
                                                }
                                            case .failure(let userArtworkError):
                                                log.error("Failed to upload photo for artwork with id: \(artwork.id).")
                                                log.error(userArtworkError)
                                                log.error(userArtworkError.localizedDescription)
                                            }
                                        }
                                        do {
                                            try context.save()
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
            let context = viewContext!
            let fetchRequest = NSFetchRequest<Badge>(entityName: "Badge")
            do {
                let badges = try context.fetch(fetchRequest)
                let notCollectedBadges = badges.filter { !$0.isCollected }
                
                
                for notCollectedBadge in notCollectedBadges {
                    if notCollectedBadge.localizedName == artwork.district.name {
                        notCollectedBadge.currentValue += 1
                    }
                    else if ["1", "3", "5", "8", "10", "15", "20", "25", "30"].contains(notCollectedBadge.collectedImageName) {
                        notCollectedBadge.currentValue += 1
                    }
                }
                let newlyCollectedBadges = notCollectedBadges.filter { $0.isCollected }
                picker.performSegue(withIdentifier: Segues.presentWonBadge, sender: newlyCollectedBadges)
                
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            picker.performSegue(withIdentifier: Segues.showArtworkDetailsRatingViewController, sender: picker)
        }
        else {
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    private func forcePortraitMode(originalImage: UIImage, mediaMetadata: NSDictionary) -> UIImage {
        
        let portraitImageResult : UIImage
        
        guard let orientationObjectValue = mediaMetadata.object(forKey: "Orientation") else {
            log.error("Orientation key doesn't exists.")
            fatalError()
        }
        
        guard let rawValueCGImageOrientation = orientationObjectValue as? UInt32 else {
            log.error("Orientation object is not UInt32.")
            fatalError()
        }
        
        guard let cgImageOrientation = CGImagePropertyOrientation(rawValue: rawValueCGImageOrientation) else {
            log.error("Cannot create an instance of CGImagePropertyOrientation with the raw value specified.")
            fatalError()
        }
        
        switch cgImageOrientation {
        case .up:
            log.debug("Image's orientation is up")
            portraitImageResult = UIImage(cgImage: originalImage.cgImage!, scale: CGFloat(1.0), orientation: .right)
            break
        case .down:
            log.debug("Image's orientation is down")
            portraitImageResult = UIImage(cgImage: originalImage.cgImage!, scale: CGFloat(1.0), orientation: .left)
            break
        case .left:
            log.debug("Image's orientation is left")
            portraitImageResult = UIImage(cgImage: originalImage.cgImage!, scale: CGFloat(1.0), orientation: originalImage.imageOrientation)
            break
        case .right:
            log.debug("Image's orientation is right")
            portraitImageResult = UIImage(cgImage: originalImage.cgImage!, scale: CGFloat(1.0), orientation: originalImage.imageOrientation)
            break
        case .upMirrored:
            log.debug("Image's orientation is upMirrored")
            portraitImageResult = UIImage(cgImage: originalImage.cgImage!, scale: CGFloat(1.0), orientation: originalImage.imageOrientation)
            break
        case .downMirrored:
            log.debug("Image's orientation is downMirrored")
            portraitImageResult = UIImage(cgImage: originalImage.cgImage!, scale: CGFloat(1.0), orientation: originalImage.imageOrientation)
            break
        case .leftMirrored:
            log.debug("Image's orientation is leftMirrored")
            portraitImageResult = UIImage(cgImage: originalImage.cgImage!, scale: CGFloat(1.0), orientation: originalImage.imageOrientation)
            break
        case .rightMirrored:
            log.debug("Image's orientation is rightMirrored")
            portraitImageResult = UIImage(cgImage: originalImage.cgImage!, scale: CGFloat(1.0), orientation: originalImage.imageOrientation)
            break
        @unknown default:
            log.debug("Image's orientation is unknow")
            portraitImageResult = UIImage(cgImage: originalImage.cgImage!, scale: CGFloat(1.0), orientation: originalImage.imageOrientation)
        }
        
        return portraitImageResult 
    }
}

