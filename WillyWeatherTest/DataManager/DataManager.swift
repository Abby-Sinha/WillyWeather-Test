//
//  DataManager.swift
//  WillyWeatherTest
//
//  Created by Abhishek Sinha on 26/11/20.
//

import Foundation

enum Result<Success, Error: Swift.Error> {
    case success(Success)
    case failure(Error)
}

// override the Result.get() method
extension Result {
    func get() throws -> Success {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}

// use generics - this is where you can decode your data
extension Result where Success == Data {
    func decoded<T: Decodable>(using decoder: JSONDecoder = .init()) throws -> T {
        let data = try get()
        return try decoder.decode(T.self, from: data)
    }
}


 class DataManager
 {
    
    var db:DBHelper = DBHelper()
    
    func getData() {
        let status = Reachability().connectionStatus()

        switch status {
        case .unknown, .offline:
            print("Not connected")
            self.getDataFromDB()
        case .online(.wwan):
            print("Connected via WWAN")
            self.getDataFromServer()
        case .online(.wiFi):
            print("Connected via WiFi")
            self.getDataFromServer()
        }
        
    }
    
    func getDataFromDB() {
        var details:[DB_Details] = []
        details = db.read()
        NotificationCenter.default.post(name: Notification.Name("DATA_FETCHED"), object: details, userInfo: nil)
    }
    
    func getDataFromServer() {
        var dictData : [Server_Details] = []
        self.getDataByAPI(completion: { result in
            switch result {
            case .success(let data):
                print(data)
                do{
                    let string = String(data: data, encoding: .utf8)
                    print(string!)
                    dictData = try JSONDecoder().decode([Server_Details].self, from: data)
                    for data in dictData{
                        print(data)
                        self.db.insert(id: data.id, author: data.author, url: data.url, download_url: data.download_url, download_status: 0)
                    }
                    self.getDataFromDB()
                }
                catch{
                    
                }
            case .failure(let error):
                print(error)
            }
        })
        
    }
    
    func getDataByAPI(completion: @escaping(Result<Data, Error>) -> Void)
    {
        let url = URL(string: "https://picsum.photos/v2/list")!
        var request  = URLRequest(url: url)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in

            if error != nil {
                completion(.failure(error!))
                return
            }
            let httpResponse = response as! HTTPURLResponse
            if !(200...299).contains(httpResponse.statusCode) && !(httpResponse.statusCode == 304) {
                completion(.failure(httpResponse.statusCode as! Error))
            }

            if let data = data {
                completion(.success(data))
            }
        }.resume()
    }
    func updateDataInDB(id:String, download_status:Int) {
        self.db.update(id: id, download_status: download_status)
    }
 }
