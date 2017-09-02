//
//  InitialInterfaceController.swift
//  Stages Watch Extension
//
//  Created by Josh Birnholz on 8/30/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import WatchKit

class InitialInterfaceController: WKInterfaceController {
	
	var buttonAction: (() -> ()) = { }
	
	@IBOutlet var label: WKInterfaceLabel!
	@IBOutlet var retryButton: WKInterfaceButton!
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		
		initialInterfaceController = self
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
		buttonAction()
	}
}
