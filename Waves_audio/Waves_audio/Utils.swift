//
//  Utils.swift
//  Waves_audio
//
//  Created by RodrigoCarrapeiro on 18/12/19.
//  Copyright © 2019 Rodrigo Pereira Carrapeiro. All rights reserved.
//

import UIKit

class Utils: NSObject {
  
    func randomString(length: Int) -> String {
        let values = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in values.randomElement()! })
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
