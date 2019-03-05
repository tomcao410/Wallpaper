//
//  WallpaperViewController.swift
//  Wallpaper
//
//  Created by Tom on 11/22/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit

class WallpaperViewController: UIViewController {


    
    // UI elements
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    // Global elements
    // Get pictures from pixabay.com
    let APIKey = "10707033-2653f7b68b7049784893153ae"
    let basePath = "https://pixabay.com/api/?key="
    var wallpapers = [Wallpaper]()
    static var wallpaperURL: String = String()
    var urlString: String = String()
    var page: Int = 1
    var totalHits: Int = Int()
    var hit: Int = 0

    
    // -----------WORK PLACE-----------
    
    //MARK: Refresh
    lazy var refresher: UIRefreshControl =
    {
            let refreshControl = UIRefreshControl()
            refreshControl.attributedTitle = NSAttributedString(string: "Refreshing...")
            refreshControl.tintColor = .gray
            refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
            
            return refreshControl
    }()
    
    @objc func refreshData ()
    {
        getWallpaper(from: urlString)
        refresher.endRefreshing()
    }
    
    // To do
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // search bar on the top
        navigationItem.titleView = searchBar
        
        // refresh
        tableView.refreshControl = refresher
        
        // get pictures from pixabay
        urlString = basePath + APIKey
        getWallpaper(from: urlString)
        
        // delegate table view and search bar
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    // spinner
    func spin()
    {
        spinner.isHidden = false
        spinner.startAnimating()
    }
    
    // Get wallpaper from pixabay (read JSON)
    func getWallpaper (from urlString: String)
    {
        //spin()
        let url = URL(string: urlString)
        let data = try! Data(contentsOf: url!)
        do
        {
            let jsonObj = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            totalHits = (jsonObj?["totalHits"] as? Int)!
            if let hits = jsonObj?["hits"] as? [[String: Any]]
            {
                for hitsPoint in hits
                {
                    if let wallpaper = try? hitsPoint as? NSDictionary
                    {
                        let temp = Wallpaper()
                        if let largeImage = wallpaper?.value(forKey: "largeImageURL")
                        {
                            temp.largeImageURL = largeImage as! String
                        }
                        wallpapers.append(temp)
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }catch
        {
            print("Error while loading largeImageURL key!")
        }
        
    }
    

}

//MARK: Search Bar extension
extension WallpaperViewController: UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        DispatchQueue.global().async {
            self.wallpapers.removeAll()
            DispatchQueue.main.async {
                self.searchBar.endEditing(true)
                self.searchBar.resignFirstResponder()
                self.urlString = self.basePath + self.APIKey + "&q=" + (searchBar.text!).encodeURIComponent()!
                self.getWallpaper(from: self.urlString)
                self.tableView.reloadData()
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.global().async {
            self.wallpapers.removeAll()
            self.urlString = self.basePath + self.APIKey
            self.getWallpaper(from: self.urlString)
            DispatchQueue.main.async {
                self.searchBar.endEditing(true)
                self.searchBar.resignFirstResponder()
                self.searchBar.showsCancelButton = false
                self.searchBar.text = ""
                self.tableView.reloadData()
            }
        }
    }
}
 
//MARK: TableView extension
extension WallpaperViewController: UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wallpapers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "wallpaperCell") as! WallpaperCell
        
        DispatchQueue.global().async
        {
            let url = URL(string: self.wallpapers[indexPath.row].largeImageURL)
            let data = NSData(contentsOf: url!)
            DispatchQueue.main.async
            {
                cell.wallpaperView.image = UIImage(data: data! as Data)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.global().async {
            if indexPath.row == self.wallpapers.count - 1
            {
                if indexPath.row == self.totalHits
                {
                    return
                }
                else
                {
                    self.page = self.page + 1
                    self.urlString = self.urlString + "&page=" + String(self.page)
                    self.getWallpaper(from: self.urlString)
                }
            }
        }
    }
    
    // Resolution fit
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let url = URL(string: wallpapers[indexPath.row].largeImageURL)
        let data = try? Data(contentsOf: url!)
        let image = UIImage(data: data!)
        let ratio = CGFloat((image?.size.width)!/(image?.size.height)!)
        let rowHeight = tableView.frame.width / ratio
        return rowHeight
    }
    
    // Wallpaper Detail View
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        WallpaperViewController.wallpaperURL = wallpapers[indexPath.row].largeImageURL
        performSegue(withIdentifier: "WallpaperDetail", sender: self )
    }
}

//MARK: String extension
extension String {
    func encodeURIComponent() -> String? {
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: "-_.!~*'()")
        return self.addingPercentEncoding(withAllowedCharacters: characterSet)
    }
}
