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
        case filling;
        case cleaning;
        case canceling;
        case none;
    }
    
    init(directoryName : String!) {
        self.directoryName = directoryName
    }
    
    public private(set) var directoryName : String!
    
    public private(set) var state : State!
    
    public var delegate: MFMemoryFillerDelegate?
    
    public func fill() {
        setState(state: .filling);
        
        DispatchQueue.global().async {
            self.createDirectoryIfNeeded();
            
            let directoryURL = self.directoryURL();
            
            let k10MB = 10 * 1024 * 1024
            let k10KB = 10 * 1024
            
            var fileSize : Int = k10MB
            
            while (self.state == .filling) {
                let fileName = NSUUID.init().uuidString
                
                let freeDiskspace : Int = MFMemoryFiller.getFreeDiskspace()
                while (fileSize * 2 > freeDiskspace && fileSize >= k10KB) {
                    fileSize /= 10;
                }
                
                let data = self.crateRandomData(size: fileSize);
                
                do {
                    try data?.write(to: (directoryURL?.appendingPathComponent(fileName))!, options: Data.WritingOptions.atomic);
                } catch let error as NSError {
                    NSLog("Fail write file with error: %@", error.localizedDescription);
                    break;
                }
                
                self.delegate?.didWriteFile(memoryFiller: self);
            }
            
            self.setState(state: .none);
        }
    }
    
    public func clean() {
        setState(state: .cleaning);
        
        DispatchQueue.global().async {
            do {
                try FileManager.default.removeItem(at: self.directoryURL()!)
            } catch let error as NSError {
                NSLog("Fail clean with error: %@", error.localizedDescription);
            }
            
            self.setState(state: .none);
        }
    }
    
    public func cancel() {
        guard state == .filling || state == .cleaning else {
            return;
        }
        
        setState(state: .canceling);
    }
    
    public func getSize() -> Int {
        let directoryURL = self.directoryURL()
        
        guard (directoryURL != nil) else {
            return 0
        }
        
        let fileNamesArray : [String]?
        do {
            fileNamesArray = try FileManager.default.contentsOfDirectory(atPath: (directoryURL?.path)!)
        } catch {
            fileNamesArray = nil
        }
        
        guard (fileNamesArray != nil) else {
            return 0
        }
        
        var size : Int = 0
        
        for fileName in fileNamesArray! {
            let filePath = directoryURL?.appendingPathComponent(fileName).path
            
            let fileAttributes : [FileAttributeKey : Any]?
            do  {
                fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath!)
            } catch {
                fileAttributes = nil
            }
            
            if (fileAttributes != nil) {
                size += fileAttributes?[FileAttributeKey.size] as! Int
            }
        }
        
        return size
    }
    
    public static func getFreeDiskspace() -> Int {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        let attributes : [FileAttributeKey : Any]?
        do {
            attributes = try FileManager.default.attributesOfFileSystem(forPath: paths.last!)
        } catch {
            attributes = nil
        }
        
        guard (attributes != nil) else {
            return 0
        }
        
        let freeFileSystemSizeInBytes = attributes?[FileAttributeKey.systemFreeSize]
        
        return freeFileSystemSizeInBytes as! Int
    }
    
    // MARK: Private
    private func setState(state : State) {
        objc_sync_enter(self.state)
        self.state = state;
        
        self.delegate?.didChangeState(memoryFiller: self);
        objc_sync_exit(self.state)
    }
    
    private func directoryURL() -> URL? {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        return URL.init(fileURLWithPath: paths.first!, isDirectory: true).appendingPathComponent(directoryName)
    }
    
    private func createDirectoryIfNeeded() {
        do {
            try FileManager.default.createDirectory(atPath: (self.directoryURL()?.path)!, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            NSLog("Fail creating directory %@", error.localizedDescription)
        }
    }
    
    private func crateRandomData(size : Int) -> Data! {
        //http://stackoverflow.com/questions/4917968/best-way-to-generate-nsdata-object-with-random-bytes-of-a-specific-length
//        let bytes = [UInt32](repeating: 0, count: size / 4).map { _ in arc4random() }
        let bytes = [UInt32](repeating: 0, count: size / 4).map { _ in 0 }
        return Data(bytes: bytes, count: bytes.count)
    }
}
