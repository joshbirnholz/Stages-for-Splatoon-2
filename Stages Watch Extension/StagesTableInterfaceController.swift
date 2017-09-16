//
//  StagesTableInterfaceController.swift
//  Stages Watch Extension
//
//  Created by Josh Birnholz on 9/13/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import WatchKit

class StageRowController: NSObject {
	
	@IBOutlet var timeLabel: WKInterfaceLabel!
	@IBOutlet var modeIconImage: WKInterfaceImage!
	@IBOutlet var modeLabel: WKInterfaceLabel!
	
	@IBOutlet var stageAGroup: WKInterfaceGroup!
	@IBOutlet var stageALabel: WKInterfaceLabel!
	@IBOutlet var stageBGroup: WKInterfaceGroup!
	@IBOutlet var stageBLabel: WKInterfaceLabel!
}

class StagesTableInterfaceController: WKInterfaceController {
	
	@IBOutlet var table: WKInterfaceTable!
	
	override func awake(withContext context: Any?) {
		guard let entries = context as? [BattleSchedule.Entry] else {
			return
		}
		
		table.setNumberOfRows(entries.count, withRowType: "StageTableRow")
		
		for (index, entry) in entries.enumerated() {
			guard let row = table.rowController(at: index) as? StageRowController else {
				continue
			}
			
			if let mode = Mode(rawValue: entry.gameMode.key) {
				row.modeIconImage.setImage(mode.icon)
				row.modeLabel.setTextColor(mode.color)
			}
			
			row.modeLabel.setText(entry.rule.name)
			row.stageALabel.setText(entry.stageA.name)
			row.stageAGroup.setBackgroundImage(UIImage(named: entry.stageA.name.lowercased().replacingOccurrences(of: " ", with: "-")))
			row.stageBGroup.setBackgroundImage(UIImage(named: entry.stageB.name.lowercased().replacingOccurrences(of: " ", with: "-")))
				
			(WKExtension.shared().delegate as? ExtensionDelegate)?.scheduleForegroundReload()
			
		}
		
		
	}
	
}
