//
//  StagesInterfaceController
//  Stages Watch Extension
//
//  Created by Josh Birnholz on 8/30/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import WatchKit
import Foundation


class StagesInterfaceController: WKInterfaceController {
	
	@IBOutlet var modeIconImage: WKInterfaceImage!
	@IBOutlet var modeNameLabel: WKInterfaceLabel!
	@IBOutlet var timeLabel: WKInterfaceLabel!
	
	@IBOutlet var stageALabel: WKInterfaceLabel!
	@IBOutlet var stageAGroup: WKInterfaceGroup!
	@IBOutlet var stageBLabel: WKInterfaceLabel!
	@IBOutlet var stageBGroup: WKInterfaceGroup!
	
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
		
		guard let entry = context as? Schedule.Entry,
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
		stageAGroup.setBackgroundImage(UIImage(named: entry.stageA.name.lowercased().replacingOccurrences(of: " ", with: "-")))
		
		stageBLabel.setText(entry.stageB.name)
		stageBGroup.setBackgroundImage(UIImage(named: entry.stageB.name.lowercased().replacingOccurrences(of: " ", with: "-")))
		
		(WKExtension.shared().delegate as? ExtensionDelegate)?.scheduleForegroundReload()
		
    }
	
	override func didAppear() {
		if schedule == nil || !schedule!.isValid {
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
		selectedMode = .regular
	}
	
	@IBAction func rankedBattleButtonPressed() {
		selectedMode = .ranked
	}
	
	@IBAction func leagueBattleButtonPressed() {
		selectedMode = .league
	}
	
	
}
