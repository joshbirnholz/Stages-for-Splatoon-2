//
//  UIImageView+fade.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 11/14/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit

extension UIImageView {
	func fade(to image: UIImage?, duration: TimeInterval = 0.25) {
		UIView.transition(with: self, duration: duration, options: [.transitionCrossDissolve, .allowUserInteraction], animations: { self.image = image }, completion: nil)
	}
}
