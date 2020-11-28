//
//  ViewController.swift
//  WillyWeatherTest
//
//  Created by Abhishek Sinha on 25/11/20.
//

import UIKit

extension UIImage {
  convenience init?(url: URL?) {
    guard let url = url else { return nil }
            
    do {
      self.init(data: try Data(contentsOf: url))
    } catch {
      print("Cannot load image from url: \(url) with error: \(error)")
      return nil
    }
  }
}
extension UIButton {

    private class Action {
        var action: (UIButton) -> Void

        init(action: @escaping (UIButton) -> Void) {
            self.action = action
        }
    }

    private struct AssociatedKeys {
        static var ActionTapped = "actionTapped"
    }

    private var tapAction: Action? {
        set { objc_setAssociatedObject(self, &AssociatedKeys.ActionTapped, newValue, .OBJC_ASSOCIATION_RETAIN) }
        get { return objc_getAssociatedObject(self, &AssociatedKeys.ActionTapped) as? Action }
    }


    @objc dynamic private func handleAction(_ recognizer: UIButton) {
        tapAction?.action(recognizer)
    }


    func addTapHandler(action: @escaping (UIButton) -> Void) {
        self.addTarget(self, action: #selector(handleAction(_:)), for: .touchUpInside)
        tapAction = Action(action: action)

    }
    
    func hasImage(named imageName: String, for state: UIControl.State) -> Bool {
            guard let buttonImage = image(for: state), let namedImage = UIImage(named: imageName) else {
                return false
            }

        return buttonImage.pngData() == namedImage.pngData()
        }
}
class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet var tblViewDetails: UITableView!
    @IBOutlet var activityLoader: UIActivityIndicatorView!
    var details:[DB_Details] = []
    var dataManager:DataManager = DataManager()
    private let downloadManager = ASDownloadManager.shared
    let directoryName : String = "DownloadDirectory"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.fetchedData(notification:)), name: Notification.Name("DATA_FETCHED"), object: nil)
        self.activityLoader.frame = self.view.bounds
        self.activityLoader.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.activityLoader.startAnimating()
        dataManager.getData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @objc func fetchedData(notification: Notification){
        self.details = notification.object as! [DB_Details]
        if self.details.count > 0 {
            DispatchQueue.main.async {
                self.activityLoader.stopAnimating()
                self.tblViewDetails.separatorStyle = .singleLine
                self.tblViewDetails.delegate = self
                self.tblViewDetails.dataSource = self
                self.tblViewDetails.reloadData()
            }
        }else{
            DispatchQueue.main.async {
                self.activityLoader.stopAnimating()
                let alert = UIAlertController(title: "No Data Found", message: "Please Check Your Internet connection and try again", preferredStyle:.alert)
                alert.addAction(UIAlertAction(title: "Ok", style:.default, handler: { [self] action in
                    self.dataManager.getData()
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.details.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL_DETAILS", for: indexPath) as! DetailsTableViewCell
        cell.lblDetails.text = "ID - \(self.details[indexPath.row].id) : Credit - \(self.details[indexPath.row].author)!"
        cell.btnDownloadORCancel.addTapHandler { (btn) in
            self.btnTapped(btn: btn, indexPath: indexPath, cell: cell)
        }
        if self.details[indexPath.row].download_status == 1 {
            cell.btnDownloadORCancel.setImage(UIImage(named: "img_Delete"), for: .normal)
        }else {
            cell.btnDownloadORCancel.setImage(UIImage(named: "img_Download"), for: .normal)
        }
        cell.progressView.progress = 0
        cell.progressView.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let status = Reachability().connectionStatus()
        var imageUrl : URL
        switch status {
        case .unknown, .offline:
            print("Not connected")
            imageUrl = ASFileUtils.getFilePath(toDirectory: directoryName, withName: self.details[indexPath.row].id)
            print(imageUrl)
        
        case .online(_):
            if self.details[indexPath.row].download_status == 1 {
                imageUrl = ASFileUtils.getFilePath(toDirectory: directoryName, withName: self.details[indexPath.row].id)
            }else{
                imageUrl = URL(string: self.details[indexPath.row].download_url)!
            }
        }
        let image = UIImage(url: imageUrl)!
        self.addImageViewWithImage(image: image)
    }
    
    func btnTapped(btn:UIButton, indexPath:IndexPath, cell:DetailsTableViewCell) {
        print("IndexPath : \(indexPath.row)")
        if btn.hasImage(named: "img_Download", for: .normal) {
            let status = Reachability().connectionStatus()
            switch status {
            case .unknown, .offline:
                print("Not connected")
                let alert = UIAlertController(title: "No Internet", message: "Please Check Your Internet connection", preferredStyle:.alert)
                alert.addAction(UIAlertAction(title: "Ok", style:.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            case .online(_):
                cell.progressView.isHidden = false
                btn.setImage(UIImage(named: "img_Cancel"), for: .normal)
                backgroundDownload(id: self.details[indexPath.row].id, url: self.details[indexPath.row].download_url, cell: cell)
            }
        } else if btn.hasImage(named: "img_Cancel", for: .normal) {
            cell.progressView.isHidden = true
            btn.setImage(UIImage(named: "img_Download"), for: .normal)
            self.downloadManager.cancelAllDownloads()
            print("NO")
        }else if btn.hasImage(named: "img_Delete", for: .normal){
            ASFileUtils.removeFileAtPath(toDirectory: directoryName, withName: self.details[indexPath.row].id)
            btn.setImage(UIImage(named: "img_Download"), for: .normal)
            dataManager.updateDataInDB(id: self.details[indexPath.row].id, download_status: 0)
        }
    }
    
    func backgroundDownload(id:String, url:String, cell:DetailsTableViewCell) {
        let request = URLRequest(url: URL(string: url)!)
        
        self.downloadManager.showLocalNotificationOnBackgroundDownloadDone = true
        self.downloadManager.localNotificationText = "All background downloads complete"
        
        let downloadKey = self.downloadManager.downloadFile(withRequest: request, inDirectory: directoryName, withName: id, shouldDownloadInBackground: true, onProgress: { (progress) in
            let percentage = Float(progress * 100)
            debugPrint("Background progress : \(percentage)")
            cell.progressView.progress = percentage
        }) { [weak self] (error, url) in
            if let error = error {
                print("Error is \(error as NSError)")
                DispatchQueue.main.async {
                    self?.tblViewDetails.reloadData()
                }
            } else {
                if let url = url {
                    print("Downloaded file's url is \(url.path)")
                    cell.progressView.isHidden = true
                    self?.dataManager.updateDataInDB(id :id , download_status:1)
                    self?.dataManager.getDataFromDB()
                    
                }
            }
        }
        
        print("The key is \(downloadKey!)")
    }
    
    @objc func removeImage() {

        let imageView = (self.view.viewWithTag(100)! as! UIImageView)
        imageView.removeFromSuperview()
    }
    
    func addImageViewWithImage(image: UIImage) {

        let imageView = UIImageView(frame: self.view.frame)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.black
        imageView.isUserInteractionEnabled = true
        imageView.image = image
        imageView.tag = 100

        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(self.removeImage))
        dismissTap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(dismissTap)
        self.view.addSubview(imageView)
    }
}

