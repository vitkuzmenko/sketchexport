//
//  Asset.swift
//  SketchExport
//
//  Created by Vitaliy Kuzmenko on 11/09/2019.
//  Copyright © 2019 Faceter. All rights reserved.
//

import Foundation

class Asset {
    
    let page: Page
    
    let name: String
    
    var items: [AssetItem]
    
    init(page: Page, slice: Slice) {
        self.page = page
        
        let asset = AssetItem(slice: slice)
        
        self.name = asset.name
        self.items = [asset]
    }
    
}

extension Asset: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case images, info, properties
    }
 
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(items, forKey: .images)
        try container.encode(getInfo(), forKey: .info)
        try container.encode(getProperties(), forKey: .properties)
    }
    
    func getInfo() -> AssetInfo {
        return AssetInfo(version: 1, author: "slicer")
    }
    
    func getProperties() -> AssetProperties {
        return AssetProperties(preservesVectorRepresentation: true)
    }
    
}
