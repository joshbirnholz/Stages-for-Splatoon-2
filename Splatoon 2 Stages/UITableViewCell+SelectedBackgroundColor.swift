//
//  UITableViewCell+SelectedBackgroundColor.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 9/8/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit

extension UITableViewCell {
	@IBInspectable dynamic var selectedBackgroundColor: UIColor? {
		get {
			return selectedBackgroundView?.backgroundColor
		}
		set {
			let backgroundView = UIView()
			backgroundView.backgroundColor = newValue
			backgroundView.layer.masksToBounds = true
			self.selectedBackgroundView = backgroundView
		}
	}
}

