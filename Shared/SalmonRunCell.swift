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
	
	@IBOutlet weak var extendedInfoStackView: UIStackView?
	@IBOutlet weak var stageImageView: UIImageView?
	@IBOutlet weak var stageNameLabel: UILabel?
	
	@IBOutlet weak var weapon0imageView: UIImageView?
	@IBOutlet weak var weapon1imageView: UIImageView?
	@IBOutlet weak var weapon2imageView: UIImageView?
	@IBOutlet weak var weapon3ImageView: UIImageView?
	
	var weaponImageViews: [UIImageView] {
		return [weapon0imageView, weapon1imageView, weapon2imageView, weapon3ImageView].flatMap { $0 }
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		stageImageView?.layer.cornerRadius = 16
		
		bubbleView.layer.cornerRadius = 12
		bubbleView.clipsToBounds = true
		
		badgeView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "badgebg"))
		
//		badgeView.transform = CGAffineTransform(rotationAngle: CGFloat(-2.5 * Double.pi/180));
//		badgeView.layer.allowsEdgeAntialiasing = true
		
		badgeLabel.shadowOffset = CGSize(width: 0, height: 1)
		badgeLabel.shadowColor = .black
		
	}
	
	override func prepareForReuse() {
		weapon0imageView?.image = nil
		weapon1imageView?.image = nil
		weapon2imageView?.image = nil
		weapon3ImageView?.image = nil
		stageImageView?.image = nil
		stageNameLabel?.text = ""
		extendedInfoStackView?.isHidden = true
	}
	
}
