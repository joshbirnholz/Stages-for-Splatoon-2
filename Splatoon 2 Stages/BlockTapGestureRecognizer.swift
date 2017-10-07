//
//  BlockTapGestureRecognizer.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 9/19/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit

class BlockTapGestureRecognizer: UITapGestureRecognizer {
	
	var action: () -> () = { }
	
	@objc private func performAction() {
		action()
	}
	
	init(_ action: @escaping () -> ()) {
		self.action = action
		super.init(target: self, action: #selector(performAction))
	}
	
}
