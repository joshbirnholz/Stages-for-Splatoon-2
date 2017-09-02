//
//  SplatoonTabBarController.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 8/28/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit

class SplatoonTabBarController: UITabBarController {
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		updateSalmonRunBadge()
	}
	
	func updateSalmonRunBadge() {
		
		guard let item = tabBar.items?.last else {
			return
		}
		
		item.badgeColor = #colorLiteral(red: 0.9867637753, green: 0.2715459905, blue: 0.03388012111, alpha: 1)
		
		guard let run = runs?.runs.first else {
			item.badgeValue = nil
			return
		}
		
		item.badgeValue = run.isOpen ? "!" : nil

	}
	
}
