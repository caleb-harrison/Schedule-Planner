//
//  ProfileViewController.swift
//  Schedule Planner
//
//  Created by Caleb Harrison on 3/23/21.
//

import UIKit

class ProfileViewController: UITableViewController {
    
    @IBOutlet var profileTableView: UITableView!
    
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var changePictureButton: UIButton!
    
    var imagePicker = UIImagePickerController()
    
    @IBOutlet var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileTableView.backgroundColor = UIColor.white
        profileTableView.reloadData()
        getProfilePicture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        profileTableView.reloadData()
        nameLabel.text = UserDefaults.standard.string(forKey: "ProfileName") ?? "Profile Name"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.profilePicture.layer.cornerRadius = profilePicture.bounds.width/2
    }

    @IBAction func changePictureButtonClicked(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { _ in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        //If you want work actionsheet on ipad then you have to use popoverPresentationController to present the actionsheet, otherwise app will crash in iPad
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = sender
            alert.popoverPresentationController?.sourceRect = sender.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera(){
        if (UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            //If you dont want to edit the photo then you can set allowsEditing to false
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery(){
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        //If you dont want to edit the photo then you can set allowsEditing to false
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func changeNameButtonClicked() {
        let alert = UIAlertController(title: "Change your name",
              message: nil,
              preferredStyle: .alert)
        // textfield (for profile name)
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.text = self.nameLabel.text
            textField.placeholder = "Enter your name here"
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
        let saveEdit = UIAlertAction(title: "Save", style: .default, handler: { (action) -> Void in
            // get textfield's text
            let nameText = alert.textFields![0].text
            // save name to user default
            UserDefaults.standard.set(nameText, forKey: "ProfileName")
            // set name label
            self.nameLabel.text = nameText
        })
        
        // add action buttons and present the alert
        alert.addAction(cancel)
        alert.addAction(saveEdit)
        present(alert, animated: true, completion: nil)
    }
    
    enum StorageType {
        case userDefaults
        case fileSystem
    }
    
    private func store(image: UIImage,
                           forKey key: String,
                           withStorageType storageType: StorageType) {
            if let pngRepresentation = image.pngData() {
                switch storageType {
                case .fileSystem:
                    if let filePath = filePath(forKey: key) {
                        do {
                            try pngRepresentation.write(to: filePath,
                                                        options: .atomic)
                        } catch let err {
                            print("Saving results in error: ", err)
                        }
                    }
                case .userDefaults:
                    UserDefaults.standard.set(pngRepresentation,
                                              forKey: key)
                }
            }
        }
        
    private func retrieveImage(forKey key: String,
                                   inStorageType storageType: StorageType) -> UIImage? {
            switch storageType {
            case .fileSystem:
                if let filePath = self.filePath(forKey: key),
                    let fileData = FileManager.default.contents(atPath: filePath.path),
                    let image = UIImage(data: fileData) {
                    return image
                }
            case .userDefaults:
                if let imageData = UserDefaults.standard.object(forKey: key) as? Data,
                    let image = UIImage(data: imageData) {
                    return image
                }
            }
            
            return nil
    }
        
    private func filePath(forKey key: String) -> URL? {
            let fileManager = FileManager.default
            guard let documentURL = fileManager.urls(for: .documentDirectory,
                                                     in: .userDomainMask).first else {
                                                        return nil
            }
            
            return documentURL.appendingPathComponent(key + ".png")
    }
        
    @objc
    private func save() {
        if let profilePic = UIImage(named: "profile-pic") {
            DispatchQueue.global(qos: .background).async {
                self.store(image: profilePic,
                           forKey: "profilePicture",
                           withStorageType: .fileSystem)
            }
        }
    }
        
    func getProfilePicture() {
        if let imageData = UserDefaults.standard.object(forKey: "profilePicture") as? Data, let image = UIImage(data: imageData) {
            
            self.profilePicture.image = image
        }
    }
    
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            // save profile pic
            self.store(image: editedImage, forKey: "profilePicture", withStorageType: .userDefaults)
            // set profile pic
            self.profilePicture.image = editedImage
            self.tableView.reloadData()
        }
        
        //Dismiss the UIImagePicker after selection
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        self.dismiss(animated: true, completion: nil)
    }
}
