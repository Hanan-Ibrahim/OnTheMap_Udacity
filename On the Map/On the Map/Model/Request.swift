//
//  Request.swift
//  On the Map
//
//  Created by Hanoudi on 5/11/20.
//  Copyright © 2020 Hanoudi. All rights reserved.
//

import Foundation


struct LoginRequest: Codable{
    let udacity: LoginData
}

struct LoginData: Codable{
    let username: String
    let password: String
}

struct StudentLocation: Codable{
    // Singlton Instance to save current Student Location
    static var instance: StudentLocation? = nil
    
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Float
    var longitude:Float
}
