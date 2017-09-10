//
//  SalmonRunInterfaceController.swift
//  Stages Watch Extension
//
//  Created by Josh Birnholz on 9/10/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import WatchKit

class SalmonRunRowController: NSObject {
	
	@IBOutlet private var badgeLabel: WKInterfaceLabel!
	@IBOutlet var badge: WKInterfaceGroup!
	@IBOutlet var timeLabel: WKInterfaceLabel!
	
	func setBadgeText(_ text: String?) {
		if let text = text {
			badge.setHidden(false)
			badgeLabel.setText(text)
		} else {
			badge.setHidden(true)
		}
	}
}

class SalmonRunInterfaceController: WKInterfaceController {
	
	@IBOutlet var table: WKInterfaceTable!
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		
		guard let runSchedule = runSchedule else {
			(WKExtension.shared().delegate as? ExtensionDelegate)?.loadSchedule(displayMode: selectedMode)
			return
		}
		
		table.setNumberOfRows(runSchedule.runs.count, withRowType: "SalmonRowController")
		
		for (index, run) in runSchedule.runs.enumerated() {
			guard let row = table.rowController(at: index) as? SalmonRunRowController else {
				continue
			}
			
			let timeString = dateFormatter.string(from: run.startTime) + " -\n"  + dateFormatter.string(from: run.endTime)
			
			row.timeLabel.setText(timeString)
			row.setBadgeText(runSchedule.badgeText(forRowAt: index))
			
		}
		
		(WKExtension.shared().delegate as? ExtensionDelegate)?.scheduleForegroundReload()
		
	}
	
	override func didAppear() {
		if runSchedule == nil || !runSchedule!.isValid {
			WKInterfaceController.reloadRootControllers(withNames: ["Initial"], contexts: nil)
			(WKExtension.shared().delegate as? ExtensionDelegate)?.loadSchedule(displayMode: selectedMode)
		}
	}
	
	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
		super.willActivate()
	}
	
	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
		super.didDeactivate()
	}
	
	@IBAction func regularBattleButtonPressed() {
		selectedMode = .battle(.regular)
	}
	
	@IBAction func rankedBattleButtonPressed() {
		selectedMode = .battle(.ranked)
	}
	
	@IBAction func leagueBattleButtonPressed() {
		selectedMode = .battle(.league)
	}
	
	deinit {
		timer = nil
	}
	
	@IBAction func salmonRunButtonPressed() {
		selectedMode = .salmonRun
	}
	
	
}
