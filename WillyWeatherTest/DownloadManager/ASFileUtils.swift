//
//  ASFileUtils.swift
//  ASDownloadManager

import UIKit

class ASFileUtils: NSObject {
    
    // MARK:- Helpers
    
    static func moveFile(fromUrl url:URL,
                         toDirectory directory:String? ,
                         withName name:String) -> (Bool, Error?, URL?) {
        var newUrl:URL
        if let directory = directory {
            let directoryCreationResult = self.createDirectoryIfNotExists(withName: directory)
            guard directoryCreationResult.0 else {
                return (false, directoryCreationResult.1, nil)
            }
            newUrl = self.getFilePath(toDirectory: directory, withName: name)
        } else {
            newUrl = self.cacheDirectoryPath().appendingPathComponent(name)
        }
        do {
            try FileManager.default.moveItem(at: url, to: newUrl)
            return (true, nil, newUrl)
        } catch {
            return (false, error, nil)
        }
    }
    
    static func cacheDirectoryPath() -> URL {
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        return URL(fileURLWithPath: cachePath)
    }
    
    static func createDirectoryIfNotExists(withName name:String) -> (Bool, Error?)  {
        let directoryUrl = self.cacheDirectoryPath().appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: directoryUrl.path) {
            return (true, nil)
        }
        do {
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
            return (true, nil)
        } catch  {
            return (false, error)
        }
    }
    static func getFilePath(toDirectory directory:String, withName name:String) -> URL{
        return self.cacheDirectoryPath().appendingPathComponent(directory).appendingPathComponent(name)
    }
    static func removeFileAtPath(toDirectory directory:String, withName name:String) {
        let filepath = self.getFilePath(toDirectory: directory, withName: name)
        do {
            if FileManager.default.fileExists(atPath: filepath.path) {
                try FileManager.default.removeItem(atPath: filepath.path)
            }
        } catch let error as NSError {
            print("An error took place: \(error)")
        }
    }
}
