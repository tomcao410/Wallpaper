//
//  WallpaperCell.swift
//  Wallpaper
//
//  Created by Tom on 11/22/18.
//  Copyright © 2018 Tom. All rights reserved.
//

import UIKit

class WallpaperCell: UITableViewCell {

    
    @IBOutlet weak var wallpaperView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        spinner.startAnimating()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
