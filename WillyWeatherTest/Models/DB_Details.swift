//
//  DB_Details.swift
//  WillyWeatherTest
//
//  Created by Abhishek Sinha on 26/11/20.
//

import Foundation

class DB_Details
{
    let id: String
    let url: String
    let download_url: String
    let author: String
    let download_status: Int
    init(id:String, author:String, url:String, download_url:String, download_status:Int)
    {
        self.id = id
        self.author = author
        self.url = url
        self.download_url = download_url
        self.download_status = download_status
    }
}
