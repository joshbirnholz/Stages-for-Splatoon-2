//
//  SplatoonMainInterfaceController.swift
//  Stages Watch Extension
//
//  Created by Josh Birnholz on 11/1/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import WatchKit

// A `WKInterfaceController` that sets up the Splatoon Stages main menu items when it awakens.
class SplatoonMainInterfaceController: WKInterfaceController {
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		
		setupMenu()
	}
	
	fileprivate func setupMenu() {
		clearAllMenuItems()
		
		let shouldShowSalmonRun = UserDefaults.group.bool(forKey: "ShowSalmonRun")
		
		let regularSelector = #selector(setModeToRegular)
		let rankedSelector = #selector(setModeToRanked)
		let leagueSelector = #selector(setModeToLeague)
		let salmonRunSelector = #selector(setModeToSalmonRun)
		
		if shouldShowSalmonRun {
			addMenuItem(withImageNamed: "Regular Battle Tab", title: "Regular Battle", action: regularSelector)
			addMenuItem(withImageNamed: "Salmon Tab", title: "Salmon Run", action: salmonRunSelector)
			addMenuItem(withImageNamed: "Ranked Battle Tab", title: "Ranked Battle", action: rankedSelector)
			addMenuItem(withImageNamed: "League Battle Tab", title: "League Battle", action: leagueSelector)
		} else {
			addMenuItem(withImageNamed: "Ranked Battle Tab", title: "Ranked Battle", action: rankedSelector)
			addMenuItem(withImageNamed: "League Battle Tab", title: "League Battle", action: leagueSelector)
			addMenuItem(withImageNamed: "Regular Battle Tab", title: "Regular Battle", action: regularSelector)
		}
	}
	
	@objc fileprivate func setModeToRegular() {
		selectedMode = .battle(.regular)
	}
	
	@objc fileprivate func setModeToRanked() {
		selectedMode = .battle(.ranked)
	}
	
	@objc fileprivate func setModeToLeague() {
		selectedMode = .battle(.league)
	}
	
	@objc fileprivate func setModeToSalmonRun() {
		selectedMode = .salmonRun
	}
}
