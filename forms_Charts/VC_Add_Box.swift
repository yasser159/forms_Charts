//
//  VC_Add_Box.swift
//  forms_Charts
//
//  Created by Yasser Hajlaoui on 7/6/22.
//
import UIKit
import RealmSwift
import Photos
import PhotosUI

class VC_Add_Box: UIViewController {
    @IBOutlet weak var img_boxImage: UIImageView!
    @IBOutlet weak var txt_BoxName:  UITextField!
    
    let realm = try! Realm()
    let UIText = UIAlerts()
    var boxes: Results<Box>?
    var imageName = ""
    var selectedImage: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadBoxes()
        imageName = genImageName()
    }
    
    func loadBoxes() {
        boxes = realm.objects(Box.self)
    }
    
    @IBAction func btn_UploadBoxImage(_ sender: Any) {
        showImagePickerOptions()
    }
        
    @IBAction func SaveBox(_ sender: Any) {
    let newBox = Box()
    newBox.BoxInit(imageName: imageName , title: txt_BoxName.text ?? "No Name")
    imageToDisk(imageName, self.img_boxImage.image!)       //Saving Image to disk
    save(box: newBox)
    
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh_BoxListScreen_Tableview"), object: nil)
    self.dismiss(animated: true, completion: nil)
        
        print("Add box dismiss")
}
    
    @IBAction func btn_Cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Realm Save 💾 🗄 📂 🗂
    func save(box: Box){
                
        do {
            try realm.write {
                realm.add(box)
            }
        } catch {
            print("Error saving box \(error)")
        }
    }

    func showImagePickerOptions(){
        let alertVC = UIAlertController(title:   UIText.ImagePicker_title,
                                        message: UIText.ImagePicker_message,
                                        preferredStyle: .actionSheet)
        
        //Image picker for camera  📸 📸 📸 📸 📸 📸 📸 📸 📸 📸 📸 📸 📸 📸 📸 📸
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] (action) in
            
            guard let self = self else { return } //Capture self to avoid retain cycles
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in})
            if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
                print("Camera already authorised") //already authorized Good to Go
            } else if AVCaptureDevice.authorizationStatus(for: .video) ==  .notDetermined {
                print("Camera .notDetermined") // Problem
            } else if AVCaptureDevice.authorizationStatus(for: .video) ==  .denied {
                print("Camera .denied") //problem
                self.AppDoesNotHavePermissionToUseCamera()
                
            } else if AVCaptureDevice.authorizationStatus(for: .video) ==  .restricted {
                print("Camera .restricted") //problem
                self.showAlert( "Camera Usage Is Restricted" , "this function wont work becuase access to the Camera is restricted.")
            }
            else {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                    if granted {
                        print("Camera access allowed")  //access allowed
                    } else {
                        print("Camera access denied") //access denied   NOT Working
                    }
                })
            }
            //______________________________________________________________________
            //current code, uses old way, works
            let cameraImagePicker = self.imagePicker(sourceType: .camera)
            cameraImagePicker.delegate = self
            self.present(cameraImagePicker, animated: true){}
        }
            //Image Picker for Library 📚 📚 📚 📚 📚 📚 📚 📚 📚 📚 📚 📚 📚 📚 📚
            let libraryAction = UIAlertAction(title: UIText.LibraryImagePicker_title,
                                              style: .default) { [weak self] (action) in
                
                guard let self = self else { return } //Capture self to avoid retain cycles
                var config = PHPickerConfiguration(photoLibrary: .shared())
                config.selectionLimit = 1
                config.filter = .images
                let vc = PHPickerViewController(configuration: config)
                vc.delegate = self
                self.present(vc, animated: true)
            }
        
            // Image Picker Buttons
            let cancelAction = UIAlertAction(title: UIText.LibraryImagePicker_Cancel,
                                             style: .cancel, handler: nil)
            alertVC.addAction(libraryAction)
            alertVC.addAction(cameraAction)
            alertVC.addAction(cancelAction)
            self.present(alertVC, animated: true, completion: nil)
    }
    //___________________________________________________________________ 📸
    func AppDoesNotHavePermissionToUseCamera() {//                        🔐
        let PermissionPrompt = UIAlertController(title: "Action Requires Permission", message: "\"QRMedia\" does not have permission to use the camera.\n Click Continue to go to the App settings and Select: \"Allow\"." , preferredStyle: UIAlertController.Style.alert)
       
        PermissionPrompt.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action: UIAlertAction!) in
               self.gotoAppPrivacySettings() }))
        
        PermissionPrompt.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
               /*Cancel Logic*/ }))

        present(PermissionPrompt, animated: true, completion: nil)
    }
    
    func gotoAppPrivacySettings() {
            guard let url = URL(string: UIApplication.openSettingsURLString),
                UIApplication.shared.canOpenURL(url) else {
                    assertionFailure("Not able to open App privacy settings")
                    return
            }
        
        DispatchQueue.main.async { UIApplication.shared.open(url, options: [:], completionHandler: nil) }
    }
    
    func showAlert(_ title: String ,_ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)})
    }//                                                                 🔐
    
    func imagePicker(sourceType: UIImagePickerController.SourceType) -> UIImagePickerController{
        let imagePicker = UIImagePickerController()
            imagePicker.sourceType = sourceType
            imagePicker.allowsEditing = true
        return imagePicker
    }
    
    struct UIAlerts {
        let ImagePicker_title         = "Pick a Photo"
        let ImagePicker_message       = "Choose a picture from your photo library or take one using the Camera"
        let LibraryImagePicker_title  = "Photo Library"
        let LibraryImagePicker_Cancel = "Cancel"
    }
    
} // End 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧 🚧

extension VC_Add_Box: UIImagePickerControllerDelegate,
                      UINavigationControllerDelegate,
                      PHPickerViewControllerDelegate {
    //For Camera Only
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        self.img_boxImage.image = image.circleMasked //___________ 🌅 👉🏻 ⭕️
        selectedImage           = image.circleMasked
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    //this is the latest version of the picker
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                guard let image = reading as? UIImage, error == nil else{
                    return
                }
                
                DispatchQueue.main.async { //For Photo Library Only
                    self.img_boxImage.image = image.circleMasked  //___________ 🌅 👉🏻 ⭕️
                    self.selectedImage      = image.circleMasked
                    }
            }
        }
    }
}

extension UIImage {
  var isPortrait:  Bool    { return size.height > size.width }
  var isLandscape: Bool    { return size.width > size.height }
  var breadth:     CGFloat { return min(size.width, size.height) }
  var breadthSize: CGSize  { return CGSize(width: breadth, height: breadth) }
  var breadthRect: CGRect  { return CGRect(origin: .zero, size: breadthSize) }
  var circleMasked: UIImage? {
      UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
      defer { UIGraphicsEndImageContext() }
      guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait  ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
      UIBezierPath(ovalIn: breadthRect).addClip()
      UIImage(cgImage: cgImage, scale: 1, orientation: imageOrientation).draw(in: breadthRect)
      return UIGraphicsGetImageFromCurrentImageContext()
  }
}

