//
//  InitialInterfaceController.swift
//  Stages Watch Extension
//
//  Created by Josh Birnholz on 8/30/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import WatchKit

class InitialInterfaceController: WKInterfaceController {
	
	@IBOutlet var loadingImage: WKInterfaceImage!
	var buttonAction: ((AppSection) -> ())? = nil
	
	@IBOutlet var retryButton: WKInterfaceButton!
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		
		(WKExtension.shared().delegate as? ExtensionDelegate)?.initialInterfaceController = self
		
		if let error = context as? Error {
			showError(error)
		}
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
	
	func showError(_ error: Error) {
		let okAction = WKAlertAction(title: "OK", style: .default) { }
		presentAlert(withTitle: "An error occurred loading data.", message: error.localizedDescription, preferredStyle: WKAlertControllerStyle.alert, actions: [okAction])
		loadingImage.stopAnimating()
		loadingImage.setHidden(true)
		retryButton.setEnabled(true)
		retryButton.setHidden(false)
		buttonAction = (WKExtension.shared().delegate as? ExtensionDelegate)?.loadSchedule
	}
	
	@IBAction func retryButtonPressed() {
		retryButton.setEnabled(false)
		retryButton.setHidden(true)
		loadingImage.setHidden(false)
		loadingImage.startAnimating()
		buttonAction?(selectedMode)
	}
}
