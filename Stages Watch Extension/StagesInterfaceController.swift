//
//  StagesInterfaceController
//  Stages Watch Extension
//
//  Created by Josh Birnholz on 8/30/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import WatchKit
import Foundation


class StagesInterfaceController: SplatoonMainInterfaceController {
	
	@IBOutlet var modeIconImage: WKInterfaceImage!
	@IBOutlet var modeNameLabel: WKInterfaceLabel!
	@IBOutlet var timeLabel: WKInterfaceLabel!
	
	@IBOutlet var stageALabel: WKInterfaceLabel!
	@IBOutlet var stageAGroup: WKInterfaceGroup!
	@IBOutlet var stageBLabel: WKInterfaceLabel!
	@IBOutlet var stageBGroup: WKInterfaceGroup!
	
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
		
		guard var entry = context as? BattleSchedule.Entry,
			let mode = Mode(rawValue: entry.gameMode.key) else {
			return
		}
		
//		setTitle(mode.description)
		setTitle(dateFormatter.string(from: entry.startTime))
		
		modeIconImage.setImage(mode.icon)
		modeNameLabel.setText(entry.rule.name)
		modeNameLabel.setTextColor(mode.color)
		
//		timeLabel.setText(dateFormatter.string(from: entry.startTime) + " - " + dateFormatter.string(from: entry.endTime))
		
		stageALabel.setText(entry.stageA.name)
		stageBLabel.setText(entry.stageB.name)
		
		loadImage(withSplatNetID: entry.stageA.imageID) { [weak self] image in
			DispatchQueue.main.async {
				self?.stageAGroup.setBackgroundImage(image)
			}
		}
		
		loadImage(withSplatNetID: entry.stageB.imageID) { [weak self] image in
			DispatchQueue.main.async {
				self?.stageBGroup.setBackgroundImage(image)
			}
		}
		
		(WKExtension.shared().delegate as? ExtensionDelegate)?.scheduleForegroundReload()
		
    }
	
	override func didAppear() {
		if battleSchedule == nil || !battleSchedule!.isValid {
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
