//
//  Box.swift
//  forms_Charts
//
//  Created by Yasser Hajlaoui on 7/6/22.
//

import Foundation
import RealmSwift


class Box: Object{

    @objc dynamic var imageName: String  = ""
    @objc dynamic var title:     String  = ""
    let items = List<Item>()
    
    func BoxInit(imageName: String, title: String){
        self.imageName = imageName
           self.title = title
       }
}

