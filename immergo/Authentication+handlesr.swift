//
//  Authentication+handlesr.swift
//  immergo
//
//  Created by David Faliskie on 11/24/16.
//  Copyright © 2016 David Faliskie. All rights reserved.
//

import UIKit

extension AuthenticationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    // displays the image picker for a profile pic choice
    func changeProfilePicture(){
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
        
    }
    
    // dealing with what happens when a user picks an image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        // get edited image from picker
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            
            selectedImageFromPicker = editedImage
            
        // else get original image from picker
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            
            selectedImageFromPicker = originalImage
            
        }
        
        if let selectedImage = selectedImageFromPicker {
            profilePicture.image = selectedImage
        }
        
        
        // close out of picker view 
        dismiss(animated: true, completion: nil)
        
    }
    
    // when user hits cancle on the picker view
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
}

