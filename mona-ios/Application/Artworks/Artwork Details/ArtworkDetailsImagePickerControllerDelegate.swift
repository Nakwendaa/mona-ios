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
    }
    
    weak var artwork: Artwork?
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
                                        let context = CoreDataStack.mainContext
                                        let entityName = String(describing: Photo.self)
                                        let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: context)
                                        let photo = Photo(entity: entityDescription!, insertInto: context)
                                        photo.localIdentifier = localIdentifier
                                        artwork.addToPhotos(photo)
                                        artwork.photoSent = false
                                        artwork.isCollected = true
                                        artwork.isTargeted = false
                                        

                                        MonaAPI.shared.artwork(id: Int(artwork.id), rating: nil, comment: nil, photo: originalImage) { (result) in
                                            switch result {
                                            case .success(_):
                                                log.info("Successful upload for artwork's photo with id: \(artwork.id).")
                                                artwork.photoSent = true
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

