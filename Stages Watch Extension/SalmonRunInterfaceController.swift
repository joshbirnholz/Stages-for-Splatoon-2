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
	
	@IBOutlet var stageGroup: WKInterfaceGroup!
	@IBOutlet var stageNameLabel: WKInterfaceLabel!
	
	@IBOutlet var weaponGroup: WKInterfaceGroup!
	@IBOutlet var weaponImage0: WKInterfaceImage!
	@IBOutlet var weaponImage1: WKInterfaceImage!
	@IBOutlet var weaponImage2: WKInterfaceImage!
	@IBOutlet var weaponImage3: WKInterfaceImage!
	
	lazy var weaponImages = [weaponImage0, weaponImage1, weaponImage2, weaponImage3]
	
	func setBadgeText(_ text: String?) {
		if let text = text {
			badge.setHidden(false)
			badgeLabel.setText(text)
		} else {
			badge.setHidden(true)
		}
	}
}

class SalmonRunInterfaceController: SplatoonMainInterfaceController {
	
	@IBOutlet var table: WKInterfaceTable!
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		
		guard let runSchedule = runSchedule else {
			(WKExtension.shared().delegate as? ExtensionDelegate)?.loadSchedule(displayMode: selectedMode)
			return
		}
		
		table.setNumberOfRows(runSchedule.shifts.count, withRowType: "SalmonRowController")
		
		for (index, run) in runSchedule.shifts.enumerated() {
			guard let row = table.rowController(at: index) as? SalmonRunRowController else {
				continue
			}
			
			let timeString = dateFormatter.string(from: run.startTime) + " -\n"  + dateFormatter.string(from: run.endTime)
			
			row.timeLabel.setText(timeString)
			row.setBadgeText(runSchedule.badgeText(forRowAt: index))
			
			if let stage = run.stage {
				row.stageGroup.setHidden(false)
				row.stageNameLabel.setText(stage.name)
				
				loadImage(withSplatNetID: stage.imageID) { image in
					DispatchQueue.main.async {
						row.stageGroup.setBackgroundImage(image)
					}
				}
			}
			
			for (index, weapon) in (run.weapons.prefix(4)).enumerated() {
				row.weaponGroup.setHidden(false)
				
				guard let weapon = weapon else {
					row.weaponImages[index]?.setImage(#imageLiteral(resourceName: "random weapon"))
					continue
				}
				
				loadImage(withSplatNetID: weapon.imageID) { image in
					DispatchQueue.main.async {
						row.weaponImages[index]?.setImage(image)
					}
				}
				
			}
			
		}
		
		(WKExtension.shared().delegate as? ExtensionDelegate)?.scheduleForegroundReload()
		
	}
	
	override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
		if segueIdentifier == "shiftDetail" {
			return runSchedule?.shifts[rowIndex]
		}
		
		return nil
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
