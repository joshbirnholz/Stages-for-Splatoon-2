//
//  StagesCell.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 8/27/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit

class StagesCell: UITableViewCell {
	
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var modeLabel: UILabel!
	
	@IBOutlet weak var stageAImageView: UIImageView!
	@IBOutlet weak var stageANameLabel: UILabel!
	
	@IBOutlet weak var stageBImageView: UIImageView!
	@IBOutlet weak var stageBNameLabel: UILabel!
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		stageAImageView.layer.cornerRadius = 6
		stageBImageView.layer.cornerRadius = 6
		
		stageAImageView.clipsToBounds = true
		stageBImageView.clipsToBounds = true
		
		if let view = viewWithTag(100) {
			view.layer.cornerRadius = 4
			view.clipsToBounds = true
		}
		
		if let view = viewWithTag(101) {
			view.layer.cornerRadius = 4
			view.clipsToBounds = true
		}
	}
	
}
