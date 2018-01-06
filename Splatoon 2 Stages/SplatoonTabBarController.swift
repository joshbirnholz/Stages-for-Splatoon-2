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
	
	/// Updates the Salmon Run tab bar item's badge. Does nothing if the Salmon Run tab is not shown.
	func updateSalmonRunBadge() {
		
		guard let salmonRunTabBarItem = tabBar.items?.last, salmonRunTabBarItem.title == "Salmon Run" else {
			return
		}
		
		salmonRunTabBarItem.badgeColor = #colorLiteral(red: 0.9867637753, green: 0.2715459905, blue: 0.03388012111, alpha: 1)
		
		guard let run = runSchedule?.shifts.first else {
			salmonRunTabBarItem.badgeValue = nil
			return
		}
		
		salmonRunTabBarItem.badgeValue = run.currentStatus == .open ? "!" : nil

	}
	
	@objc func presentSettings() {
		performSegue(withIdentifier: "Settings", sender: nil)
	}
	
}
