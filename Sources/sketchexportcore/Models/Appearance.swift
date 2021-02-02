//
//  Appearance.swift
//  SketchExport
//
//  Created by Vitaliy Kuzmenko on 11/09/2019.
//  Copyright © 2019 Faceter. All rights reserved.
//

import Foundation

struct Appearance: Encodable {
    
    let appearance, value: String
    
}

extension Appearance: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(appearance)
        hasher.combine(value)
    }
    
}

extension Appearance {
 
    static let light = Appearance(appearance: "luminosity", value: "light")
    
    static let dark = Appearance(appearance: "luminosity", value: "dark")
    
}
