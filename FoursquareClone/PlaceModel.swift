//
//  PlaceModel.swift
//  FoursquareClone
//
//  Created by Nihad Ismayilov on 18.02.22.
//

import Foundation
import UIKit

class PlaceModel {
    
    static let sharedInstance = PlaceModel()
    
    var placeName = ""
    var placeType = ""
    var placeAtmosphere = ""
    var placeImage = UIImage()
    var placeLatitude = Double()
    var placeLongitude = Double()
    
    private init() {
        
    }
}
