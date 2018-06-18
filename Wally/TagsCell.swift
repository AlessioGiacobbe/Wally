//
//  TagsCell.swift
//  Wally
//
//  Created by alessio giacobbe on 23/01/18.
//  Copyright © 2018 alessio giacobbe. All rights reserved.
//

import UIKit

class TagsCell: UITableViewCell {

    let imageParallaxFactor: CGFloat = 20
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
