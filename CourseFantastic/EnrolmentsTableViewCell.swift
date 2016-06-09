//
//  EnrolmentsTableViewCell.swift
//  CourseFantastic
//
//  Created by Lee Kelly on 22/04/2016.
//  Copyright © 2016 LMK Technologies. All rights reserved.
//

import UIKit


class EnrolmentsTableViewCell: UITableViewCell {
    
    @IBOutlet var colourView: UIView!
    @IBOutlet var courseLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
