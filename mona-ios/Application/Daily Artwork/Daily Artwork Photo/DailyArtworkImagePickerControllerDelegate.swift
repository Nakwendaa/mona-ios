//
//  DailyArtworkImagePickerControllerDelegate.swift
//  mona
//
//  Created by Paul Chaffanet on 2019-05-06.
//  Copyright © 2019 Paul Chaffanet. All rights reserved.
//

import UIKit

class DailyArtworkImagePickerControllerDelegate : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let artwork: Artwork
    
    init(artwork: Artwork) {
        self.artwork = artwork
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Pop the picker if the user canceled.
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        /*
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        guard let mediaMetadata = info[UIImagePickerControllerMediaMetadata] as? NSDictionary else {
            fatalError("Expected a dictionary containing a dictionary, but was provided the following: \(info)")
        }
        
        let selectedImage = forcePortraitMode(originalImage: originalImage, mediaMetadata: mediaMetadata)
        
        if dataManager.saveImage(image: selectedImage, forArtwork: artwork) {
            artwork.photoSent = false
            dataManager.saveCachedArtwork(artwork)
            if !artwork.isCollected {
                artwork.isCollected = true
                artwork.isTargeted = false
                dataManager.saveCachedArtwork(artwork)
                
                
                //Badges
                let wonBadges = dataManager.getWonBadgesAfterPicture(artwork: artwork)
                wonBadges.forEach({ dataManager.saveCachedBadge($0) })
                
                
                /*
                if currentReachabilityStatus != .notReachable  {
                    DispatchQueue.main.async {
                        if let login = dataManager.loadLogin(), let username = login["username"], let password = login["password"]  {
                            _ = AddPhotoOperation(withUsername: username, withPassword: password, artwork: self.artwork)
                        }
                        else {
                            log.error("Unable to load login info.")
                        }
                    }
                    
                }
                */
                
                picker.performSegue(withIdentifier: "showDailyArtworkRatingViewController", sender: picker)
            }
            else {
                /*
                if currentReachabilityStatus != .notReachable  {
                    DispatchQueue.main.async {
                        if let login = dataManager.loadLogin(), let username = login["username"], let password = login["password"]  {
                            _ = AddPhotoOperation(withUsername: username, withPassword: password, artwork: self.artwork)
                        }
                        else {
                            log.error("Unable to load login info.")
                        }
                    }
                    
                }
                */
                
                picker.dismiss(animated: true, completion: nil)
            }
        }
        */
        
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
