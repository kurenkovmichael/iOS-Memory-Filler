//
//  MFMemoryFiller.swift
//  MemoryFiller
//
//  Created by Михаил Куренков on 11.03.17.
//  Copyright © 2017 Михаил Куренков. All rights reserved.
//

import UIKit

class MFMemoryFiller: NSObject {
    
    public enum State : Int {
        case filling
        case cleaning
        case canceling
        case none
    }
    
    init(directoryName: String) {
        self.directoryName = directoryName
    }
    
    public private(set) var directoryName: String
    
    public private(set) var state: State = .none
    
    public var delegate: MFMemoryFillerDelegate?
    
    public func fill() {
        setState(state: .filling)
        
        DispatchQueue.global().async {
            self.createDirectoryIfNeeded()
            
            guard let directoryURL = self.directoryURL() else {
                NSLog("Failed create base directory URL")
                self.setState(state: .none)
                return
            }
            
            let k10MB = 10 * 1024 * 1024
            let k10KB = 10 * 1024
            
            var fileSize : Int = k10MB
            
            while (self.state == .filling) {
                let fileName = NSUUID.init().uuidString
                
                let freeDiskspace : Int = MFMemoryFiller.getFreeDiskspace()
                while (fileSize * 2 > freeDiskspace && fileSize >= k10KB) {
                    fileSize /= 10
                }
                
                let data = self.crateRandomData(size: fileSize)
                
                do {
                    let fileUrl = directoryURL.appendingPathComponent(fileName)
                    try data?.write(to: fileUrl, options: Data.WritingOptions.atomic)
                } catch let error as NSError {
                    NSLog("Fail write file with error: %@", error.localizedDescription)
                    break
                }
                
                self.delegate?.didWriteFile(memoryFiller: self)
            }
            
            self.setState(state: .none)
        }
    }
    
    public func clean() {
        setState(state: .cleaning)
        
        DispatchQueue.global().async {
            guard let directoryURL = self.directoryURL() else {
                NSLog("Failed create base directory URL")
                self.setState(state: .none)
                return
            }
            
            do {
                try FileManager.default.removeItem(at: directoryURL)
            } catch let error as NSError {
                NSLog("Fail clean with error: %@", error.localizedDescription)
            }
            
            self.setState(state: .none)
        }
    }
    
    public func cancel() {
        guard state == .filling || state == .cleaning else {
            return
        }
        
        setState(state: .canceling)
    }
    
    public func getSize() -> Int {
        guard let directoryURL = self.directoryURL(),
              let fileNames = try? FileManager.default.contentsOfDirectory(atPath: directoryURL.path)
        else {
            return 0
        }
        
        var size : Int = 0
        
        for fileName in fileNames {
            let filePath = directoryURL.appendingPathComponent(fileName).path
            
            let fileAttributes: [FileAttributeKey : Any]?
            do  {
                fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath)
            } catch {
                fileAttributes = nil
            }
            
            if let attributes = fileAttributes,
               let sizeAttribute = attributes[FileAttributeKey.size] as? Int
            {
                size += sizeAttribute
            }
        }
        
        return size
    }
    
    public static func getFreeDiskspace() -> Int {
        let paths = NSSearchPathForDirectoriesInDomains(
            FileManager.SearchPathDirectory.documentDirectory,
            FileManager.SearchPathDomainMask.userDomainMask,
            true
        )
        guard let path = paths.last else { return 0 }
        
        let attributes = try? FileManager.default.attributesOfFileSystem(forPath: path)
        let freeFileSystemSizeInBytes = attributes?[FileAttributeKey.systemFreeSize] as? Int
        return freeFileSystemSizeInBytes ?? 0
    }
    
    // MARK: Private
    private func setState(state : State) {
        objc_sync_enter(self.state)
        self.state = state
        
        self.delegate?.didChangeState(memoryFiller: self)
        objc_sync_exit(self.state)
    }
    
    private func directoryURL() -> URL? {
        let paths = NSSearchPathForDirectoriesInDomains(
            FileManager.SearchPathDirectory.documentDirectory,
            FileManager.SearchPathDomainMask.userDomainMask,
            true
        )
        guard let path = paths.first else { return nil }
        
        return URL(fileURLWithPath: path, isDirectory: true)
            .appendingPathComponent(directoryName)
    }
    
    private func createDirectoryIfNeeded() {
        guard let directoryURL = self.directoryURL() else {
            NSLog("Failed create base directory URL")
            return
        }
        
        do {
            try FileManager.default.createDirectory(
                atPath: directoryURL.path,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch let error as NSError {
            NSLog("Fail creating directory %@", error.localizedDescription)
        }
    }
    
    private func crateRandomData(size : Int) -> Data! {
        //http://stackoverflow.com/questions/4917968/best-way-to-generate-nsdata-object-with-random-bytes-of-a-specific-length
//        let bytes = [UInt32](repeating: 0, count: size / 4).map { _ in arc4random() }
        let bytes = [UInt32](repeating: 0, count: size).map { _ in 0 }
        return Data(bytes: bytes, count: bytes.count)
    }
}
