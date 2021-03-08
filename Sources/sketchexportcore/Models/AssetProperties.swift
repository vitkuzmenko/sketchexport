//
//  AssetProperties.swift
//  SketchExport
//
//  Created by Vitaliy Kuzmenko on 11/09/2019.
//  Copyright © 2019 Faceter. All rights reserved.
//

import Foundation

struct AssetProperties: Encodable {
    
    let preservesVectorRepresentation: Bool

    enum CodingKeys: String, CodingKey {
        case preservesVectorRepresentation = "preserves-vector-representation"
    }
    
}
