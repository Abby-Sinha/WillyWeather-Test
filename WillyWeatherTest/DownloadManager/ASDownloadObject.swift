//
//  ASDownloadObject.swift
//  ASDownloadManager
//


import UIKit

class ASDownloadObject: NSObject {

    var completionBlock: ASDownloadManager.DownloadCompletionBlock
    var progressBlock: ASDownloadManager.DownloadProgressBlock?
    let downloadTask: URLSessionDownloadTask
    let directoryName: String?
    let fileName:String?
    
    init(downloadTask: URLSessionDownloadTask,
         progressBlock: ASDownloadManager.DownloadProgressBlock?,
         completionBlock: @escaping ASDownloadManager.DownloadCompletionBlock,
         fileName: String?,
         directoryName: String?) {
        
        self.downloadTask = downloadTask
        self.completionBlock = completionBlock
        self.progressBlock = progressBlock
        self.fileName = fileName
        self.directoryName = directoryName
    }
    
}
