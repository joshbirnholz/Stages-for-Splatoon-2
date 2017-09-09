//
//  InitialInterfaceController.swift
//  Stages Watch Extension
//
//  Created by Josh Birnholz on 8/30/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import WatchKit

class InitialInterfaceController: WKInterfaceController {
	
	var buttonAction: ((Mode) -> ()) = { _ in }
	
	@IBOutlet var label: WKInterfaceLabel!
	@IBOutlet var retryButton: WKInterfaceButton!
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
	}
	
	override func didAppear() {
		super.didAppear()
		
		updateUserActivity("com.josh.birnholz.Splatoon-2-Stages.openMode", userInfo: ["mode": selectedMode.rawValue], webpageURL: URL(string: "https://splatoon2.ink"))
	}
	
	override func willDisappear() {
		super.willDisappear()
		invalidateUserActivity()
	}
	
	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
		super.willActivate()
	}
	
	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
		super.didDeactivate()
	}
	
	@IBAction func retryButtonPressed() {
		retryButton.setEnabled(false)
		label.setText("Loading…")
		buttonAction(selectedMode)
	}
}
