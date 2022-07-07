//
//  Item.swift
//  
//
//  Created by Yasser Hajlaoui on 7/6/22.
//

import Foundation
import RealmSwift

class Item: Object {
    
    @objc dynamic var imageName: String  = ""
    //@objc dynamic var title:     String  = ""
    //@objc dynamic var quantity:  Int32   = 0
    //@objc dynamic var dateCreated : Date?
    var parentBox = LinkingObjects(fromType: Box.self, property: "items")

    
    func ItemInit(imageName: String){
        self.imageName = imageName
           //self.title = title
 }

}
