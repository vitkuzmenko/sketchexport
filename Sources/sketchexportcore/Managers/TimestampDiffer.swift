//
//  TimestampDiffer.swift
//  SketchExport
//
//  Created by Vitaliy Kuzmenko on 12/09/2019.
//  Copyright © 2019 Faceter. All rights reserved.
//

import Foundation

enum TimestampDiffeError: Error {
    case canNotRetriveSketchModificationDate(String)
}

class TimestampDiffer {
    
    let input: String
    
    let rootFolder: String
    
    var fileTimestamp: TimeInterval = 0
    
    private let fm = FileManager.default
    
    init(input: String, rootFolder: String) {
        self.input = input
        self.rootFolder = rootFolder
    }
    
    func shouldExport() throws -> Bool {
        do {
            fileTimestamp = try loadFileTimestamp()
        } catch {
            throw error
        }
        
        do {
            let lastExportTimestamp = try loadLastExportTimestamp()
            return fileTimestamp != lastExportTimestamp.timestamp
        } catch {
            if let nsError = error as NSError?, nsError.code == NSFileReadNoSuchFileError {
                return true
            } else {
                throw error
            }
        }
    }
    
    private func loadFileTimestamp() throws -> TimeInterval {
        do {
            let url = URL(fileURLWithPath: input)
            let values = try url.resourceValues(forKeys: [.contentModificationDateKey, .creationDateKey])
            if let date = values.allValues[.contentModificationDateKey] as? Date {
                return date.timeIntervalSince1970
            } else if let date = values.allValues[.creationDateKey] as? Date {
                return date.timeIntervalSince1970
            } else {
                throw TimestampDiffeError.canNotRetriveSketchModificationDate(input)
            }
        } catch {
            throw error
        }
    }
    
    private func loadLastExportTimestamp() throws -> Timestamp {
        let path = getTimestampJSONPath()
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let timestamp = try decoder.decode(Timestamp.self, from: data)
            return timestamp
        } catch {
            throw error
        }
    }
    
    func writeCurrentTimestamp() throws {
        do {
            let path = getTimestampJSONPath()
            let timestamp = Timestamp(timestamp: fileTimestamp)
            let encoder = JSONEncoder()
            let data = try encoder.encode(timestamp)
            let fileURL = URL(fileURLWithPath: path)
            try data.write(to: fileURL)
        } catch {
            throw error
        }
    }
    
    private func getTimestampJSONPath() -> String {
        return String(format: "%@/Timestamp.json", rootFolder)
    }
    
}
