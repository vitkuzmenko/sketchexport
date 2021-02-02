//
//  SketchInspector.swift
//  SketchExport
//
//  Created by Vitaliy Kuzmenko on 11/09/2019.
//  Copyright © 2019 Faceter. All rights reserved.
//

import Foundation

enum SlicesInspectorError: Error {
    case fileReading(String?)
}

extension SlicesInspectorError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .fileReading(let output):
            return String(format: "sketchtool reading file error: %@", output ?? "")
        }
    }
    
}

class SlicesInspector {
    
    let sketchtoolExecutable: String
    
    let input: String
    
    private let pipe = Pipe()
    
    init(sketchtoolExecutable: String, input: String) {
        self.sketchtoolExecutable = sketchtoolExecutable
        self.input = input
    }
    
    func read() throws -> Output {
        let process = getListSlicesProcess()
        process.launch()
//        process.waitUntilExit()
        
        
        sleep(2)
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        
        if process.terminationStatus == 1 {
            let string = String(data: data, encoding: .utf8)
            throw SlicesInspectorError.fileReading(string)
        }
        
        return try decode(input: data)
    }
    
    private func getListSlicesProcess() -> Process {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = [sketchtoolExecutable, "list", "slices", input]
        process.standardOutput = pipe
        return process
    }
    
    private func decode(input: Data) throws -> Output {
        let decoder = JSONDecoder()
        return try decoder.decode(Output.self, from: input)
    }
    
}
