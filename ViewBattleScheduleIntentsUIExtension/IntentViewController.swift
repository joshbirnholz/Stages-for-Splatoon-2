//
//  IntentViewController.swift
//  ViewBattleScheduleIntentsUIExtension
//
//  Created by Josh Birnholz on 6/6/18.
//  Copyright © 2018 Joshua Birnholz. All rights reserved.
//

import IntentsUI

// As an example, this extension's Info.plist has been configured to handle interactions for INSendMessageIntent.
// You will want to replace this or add other intents as appropriate.
// The intents whose interactions you wish to handle must be declared in the extension's Info.plist.

// You can test this example integration by saying things to Siri like:
// "Send a message using <myApp>"

class WidgetViewController: WidgetStagesViewController, INUIHostedViewControlling {
	
	private var intentMode: ViewBattleScheduleBattleMode = .unknown
	
	override var mode: Mode! {
		return intentMode.nativeMode
	}
	
	// Prepare your view controller for the interaction to handle.
	func configureView(for parameters: Set<INParameter>, of interaction: INInteraction, interactiveBehavior: INUIInteractiveBehavior, context: INUIHostedViewContext, completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {
		
		guard let intent = interaction.intent as? ViewBattleScheduleIntent else {
			completion(false, Set(), .zero)
			return
		}
		
		self.intentMode = intent.mode
		
		getSchedule { (result) in
			switch result {
			case .failure(let error):
				print("Error retreiving the schedule:", error.localizedDescription)
				completion(false, Set(), .zero)
			case .success(var sch):
				sch.removeExpiredEntries()
				self.battleSchedule = sch
				
				DispatchQueue.main.async {
					self.tableView.reloadData()
					self.updateNoDataLabel()
					
					completion(true, parameters, self.desiredSize)
				}
			}
		}
		
	}
	
	override var entries: [BattleSchedule.Entry] {
		guard let battleSchedule = battleSchedule else {
			return []
		}
		
		if intentMode == .unknown {
			return ([battleSchedule[.regular].first] + [battleSchedule[.ranked].first] + [battleSchedule[.league].first]).compactMap { $0 }
		} else {
			return battleSchedule[mode]
		}
	}
	
	var desiredSize: CGSize {
		let width = self.extensionContext!.hostedViewMaximumAllowedSize.width
		let height: CGFloat = Array((0 ..< tableView.numberOfRows(inSection: 0))).reduce(0) { result, row in
			return result + self.tableView(tableView, heightForRowAt: IndexPath(row: row, section: 0))
		}
		let size = CGSize(width: width, height: height)
		
		if size.height > self.extensionContext!.hostedViewMaximumAllowedSize.height {
			return self.extensionContext!.hostedViewMaximumAllowedSize
		} else {
			return size
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let width = self.extensionContext!.hostedViewMaximumAllowedSize.width
		return width / 8 * 5 / 2
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard !entries.isEmpty else {
			return 0
		}
		
		if intentMode == .unknown {
			return entries.count
		} else {
			return min(2, entries.count)
		}
		
	}
	
}
