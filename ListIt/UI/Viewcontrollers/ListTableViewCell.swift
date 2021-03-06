//
//  ListTableViewController.swift
//  ListIt
//
//  Created by Chris Collins on 12/13/15.
//  Copyright © 2015 Jonathan Green. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell{

    @IBOutlet weak var theView: UIView!
    @IBOutlet weak var listHeadingTitle: UILabel!
    @IBOutlet weak var listImage: UIImageView!
    @IBOutlet weak var listedTime: UILabel!
    @IBOutlet weak var usersName: UILabel!
    @IBOutlet weak var listPrice: UILabel!
    @IBOutlet weak var userTypeIcon: UIImageView!
    @IBOutlet weak var onlineIndicator: UIImageView!
    @IBOutlet weak var share: UIButton!
    @IBOutlet weak var comment: UIButton!
    @IBOutlet weak var userImage: UIButton!
    
    override func awakeFromNib() {
        
        self.selectionStyle = .None
        
        theView.layer.borderWidth = 2
        theView.layer.borderColor = UIColor.whiteColor().CGColor
        theView.layer.cornerRadius = 3
        theView.layer.masksToBounds = true
    }
}
