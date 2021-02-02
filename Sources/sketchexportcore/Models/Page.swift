//
//  Page.swift
//  SketchExport
//
//  Created by Vitaliy Kuzmenko on 11/09/2019.
//  Copyright © 2019 Faceter. All rights reserved.
//

import Foundation

struct Page: Decodable {
    
    let id, name: String
    
    let slices: [Slice]
    
}

extension Page: Hashable {
 
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
    
}
