//
//  JSONFileCache.swift
//  tawk.to
//
//  Created by Dominic Valencia on 12/5/20.
//  Copyright © 2020 Dominic Valencia. All rights reserved.
//

import Foundation

public class JSONFileCache {
    var filename = ""
    var documentsDirectoryPathString:String = ""
    var documentsDirectoryPath:URL!
    var jsonFilePath:URL?
    
    public init(name:String){
        
        self.filename = name.replacingOccurrences(of: "/", with: "_")
                            .replacingOccurrences(of: "=", with: "_")
                            .replacingOccurrences(of: "&", with: "_")
                            .appending(".json")
        documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        documentsDirectoryPath = URL(string: documentsDirectoryPathString)!
        let fileUrl = URL(string: self.filename)
        
        jsonFilePath = documentsDirectoryPath.appendingPathComponent((fileUrl?.absoluteString)!)
    }
    
    public func write(data:Data, update: Bool = false) {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: jsonFilePath!.absoluteString) {
            let created = fileManager.createFile(atPath: jsonFilePath!.absoluteString, contents: nil, attributes: nil)
            print("FileCreated: \(created)")
        } else {
            if update {
                do{
                    try fileManager.removeItem(atPath: jsonFilePath!.absoluteString)
                    let created = fileManager.createFile(atPath: jsonFilePath!.absoluteString, contents: nil, attributes: nil)
                    print("FileCreated: \(created)")
                }catch let error {
                    print("error occurred, here are the details:\n \(error)")
                }
            } else {
                print("File already exists")
            }
            
        }
        
        guard let file = FileHandle(forWritingAtPath:jsonFilePath!.absoluteString) else {
            print("no file handle")
            return
        }
        print("has file handle: writing")
        file.write(data)
        
    }
    
    public func read(_ noTimeDiff: Bool = false) -> Data? {
        if exists(noTimeDiff) {
            if let file = FileHandle(forReadingAtPath: jsonFilePath!.absoluteString){
                return file.readDataToEndOfFile()
            }else{
                print("Error Reading from \(String(describing: jsonFilePath?.absoluteString))")
            }
        }
        return nil
    }
    
    public func getfileCreatedDate() -> Date {
        
        var theCreationDate = Date()
        do{
            let aFileAttributes = try FileManager.default.attributesOfItem(atPath: self.jsonFilePath?.absoluteString ?? "") as [FileAttributeKey:Any]
            theCreationDate = aFileAttributes[FileAttributeKey.creationDate] as! Date
            
        } catch let theError as Error{
            print("file not found \(theError)")
        }
        return theCreationDate
    }
    
    public func clear() -> Void {
        if exists() {
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(atPath: jsonFilePath!.absoluteString)
                print("Removed: \(String(describing: jsonFilePath!.absoluteString))")
            }catch let error as NSError {
                print("Ooops! Something went wrong: \(error)")
            }
        }
    }
    
    public func exists(_ noTimeDiff: Bool = false) -> Bool {
        do {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: jsonFilePath!.absoluteString) {
                let fileAttributes = try fileManager.attributesOfItem(atPath: jsonFilePath!.absoluteString)
                let creationDate = fileAttributes[FileAttributeKey.creationDate] as? Date
                let timedifference = Calendar.current.dateComponents([ .minute], from: creationDate!, to: Date()).minute
                print("file: \(String(describing: jsonFilePath!.absoluteString))")
                print("creation date of file is", creationDate!)
                
                if timedifference! >= 30 && !noTimeDiff {
                    do {
                        try fileManager.removeItem(atPath: jsonFilePath!.absoluteString)
                        print("Removed: \(jsonFilePath!.absoluteString)")
                    }catch let error as NSError {
                        print("Ooops! Something went wrong: \(error)")
                    }
                    return false
                }else{
                    return true
                }
            } else {
                print("FILE NOT AVAILABLE")
            }
        }catch let error as NSError {
            print("file not found:", error)
        }
        return false
    }
}


