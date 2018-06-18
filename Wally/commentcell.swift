//
//  commentcell.swift
//  Wally
//
//  Created by alessio giacobbe on 03/02/18.
//  Copyright © 2018 alessio giacobbe. All rights reserved.
//

import UIKit

class commentcell: UITableViewCell {
    
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var comment: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
