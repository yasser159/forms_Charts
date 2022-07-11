//
//  BoxCell.swift
//  Pods
//
//  Created by Yasser Hajlaoui on 7/6/22.
//

import UIKit
import SwipeCellKit

class BoxCell: SwipeTableViewCell {

    @IBOutlet weak var boxImageView: UIImageView!
    @IBOutlet weak var boxTitleLabel: UILabel!
    
    func setBox(box: Box) {
        boxImageView.image = diskToImage(box.imageName + "_thumb")
        //boxImageView.roundedImage()  // ⭕️  old way
        boxTitleLabel.text = box.title
        }
    }
