//
//  ImageHandling.swift
//  forms_Charts
//
//  Created by Yasser Hajlaoui on 7/6/22.
//

import Foundation
import UIKit

let myFileManagerURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let defaults = UserDefaults.standard //user defaults

func imageToDisk(_ name: String,_ image: UIImage) {
    
    if let original_JPG_Data = image.jpegData(compressionQuality: 1.0),
        let path = documentDirectoryPath()?.appendingPathComponent(name) {
        try? original_JPG_Data.write(to: path)
    }
    
    if let thumb_JPG_Data = image.jpegData(compressionQuality: 0.0),
        let path = documentDirectoryPath()?.appendingPathComponent( name + "_thumb" ) {
        try? thumb_JPG_Data.write(to: path)
    }
}
func diskToImage(_ fileName: String) -> UIImage? {
       
    let documentDirectory = myFileManagerURL;
       let fileURL = documentDirectory.appendingPathComponent(fileName)
    
       do {
           
           let imageData = try Data(contentsOf: fileURL)
           return UIImage(data: imageData)
           
       } catch {
          print("Problem Loading Image From Disk")
       }
       return #imageLiteral(resourceName: "contacts logo.jpeg")
   }

func deleteObjectImages(_ deletedBox : Box){
    var toBeDeletedImages: [URL] = []// collect paths to images to be deleted

            let documentDirectory =  myFileManagerURL
            toBeDeletedImages.append(documentDirectory.appendingPathComponent(deletedBox.imageName))
            toBeDeletedImages.append(documentDirectory.appendingPathComponent(deletedBox.imageName + "_thumb"))
    
        for items in deletedBox.items {
                toBeDeletedImages.append(documentDirectory.appendingPathComponent(items.imageName))
                toBeDeletedImages.append(documentDirectory.appendingPathComponent(items.imageName + "_thumb"))
        }
        
        do {
            for filePath in toBeDeletedImages {
                try FileManager.default.removeItem(at: filePath)
            }
        }
        catch {
            print("ImageHandling.Error Deleting File")
        }
}

func deleteItemImage(_ fileName : String){
    let documentDirectory =  myFileManagerURL
    let filePath = documentDirectory.appendingPathComponent(fileName)
    do {
        try FileManager.default.removeItem(at: filePath)
    }
    catch {
        print("ImageHandling.Error Deleting File")
    }
}

// Generate Image Name from Current date
func genImageName() -> String {
    let date :NSDate = NSDate()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "ddMMyyyyHHmmss"
    dateFormatter.timeZone = NSTimeZone(name: "PT") as TimeZone?
    let imageName = "/\(dateFormatter.string(from: date as Date))"
    return imageName
}

func documentDirectoryPath() -> URL? {
    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return path.first
}

func generateQRCode(from string: String) -> UIImage? {
    
    let data = string.data(using: String.Encoding.ascii)

    if let filter = CIFilter(name: "CIQRCodeGenerator") {
        filter.setValue(data, forKey: "inputMessage")
        let transform = CGAffineTransform(scaleX: 6, y: 6)

        if let output = filter.outputImage?.transformed(by: transform) {
            return UIImage(ciImage: output)
        }
    }
    return nil
}

func setBrightnessToMax(){                   //Set Brightness to Max
    UIScreen.main.brightness = CGFloat(1.0)
}

func restoreBrightness()                     // Restore Brightness From saved value
{
    UIScreen.main.brightness = CGFloat(defaults.float(forKey: "UserSetBrightness"))
}

extension UIImageView {
    
    func roundedImage() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
}
