//
//  ProductList.swift
//  AR Beauty
//
//  Created by Madeline Eckhart on 6/25/18.
//  Copyright © 2018 MaddGaming. All rights reserved.
//

import Foundation
import UIKit
// maybe add in a .scn as an attribute too??????

class ProductList {
    var name: String = ""
    var type: Int = 0
    var image: UIImage
    
    init(newName: String, newType: Int, newImage: UIImage) {
        self.name = newName
        self.type = newType
        self.image = newImage
    }
    
    func getName() -> String {
        return name
    }
    
    func getType() -> Int {
        return type
    }
    
    func getImage() -> UIImage {
        return image
    }
}
