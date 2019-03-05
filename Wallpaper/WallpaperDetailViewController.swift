//
//  WallpaperDetailViewController.swift
//  Wallpaper
//
//  Created by Tom on 11/22/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit
import MobileCoreServices
class WallpaperDetailViewController: UIViewController {

    // UI elements
    @IBOutlet weak var wallpaperView: UIImageView!
    @IBOutlet weak var btnZoom: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    
    enum AttachmentType: String{
        case camera, video, photoLibrary
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        btnZoom.setImage(#imageLiteral(resourceName: "scopeBtn"), for: .normal)
        btnSave.setImage(#imageLiteral(resourceName: "saveBtn"), for: .normal)
        btnShare.setImage(#imageLiteral(resourceName: "shareBtn"), for: .normal)
        
        
    }
    
    @IBAction func actionSave(_ sender: Any)
    {
        let imgData = wallpaperView.image!.pngData()
        let compressedImg = UIImage(data: imgData!)
        UIImageWriteToSavedPhotosAlbum(compressedImg!, nil, nil, nil)
        
        
        let alert = UIAlertController(title: "Save photo", message: "Photo saved", preferredStyle: .alert)
        let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(OK)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func actionShare(_ sender: Any)
    {
        let itemshare : UIImage = wallpaperView.image!
        let activityVC = UIActivityViewController(activityItems: [itemshare], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop,UIActivity.ActivityType.postToFacebook ]
        self.present(activityVC, animated: true, completion: nil)
    }
    
    
    
    // Set UI
    func setUI()
    {
        let url = URL(string: WallpaperViewController.wallpaperURL)
        let data = NSData(contentsOf: url!)
        wallpaperView.image = UIImage(data: data! as Data)
    }
}
