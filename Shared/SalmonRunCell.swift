//
//  SalmonRunCell.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 8/28/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit

class SalmonRunCell: UITableViewCell {
	
	@IBOutlet private weak var bubbleView: UIView!
	@IBOutlet weak var timeLabel: UILabel!
	
	@IBOutlet weak var badgeView: UIView!
	@IBOutlet weak var badgeLabel: UILabel!
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		bubbleView.layer.cornerRadius = 12
		bubbleView.clipsToBounds = true
		
		badgeView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "badgebg"))
		
//		badgeView.transform = CGAffineTransform(rotationAngle: CGFloat(-2.5 * Double.pi/180));
//		badgeView.layer.allowsEdgeAntialiasing = true
		
		badgeLabel.shadowOffset = CGSize(width: 0, height: 1)
		badgeLabel.shadowColor = .black
		
	}
	
}
