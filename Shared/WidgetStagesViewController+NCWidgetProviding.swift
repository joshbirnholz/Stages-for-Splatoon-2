//
//  WidgetStagesViewController+NCWidgetProviding.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 6/6/18.
//  Copyright © 2018 Joshua Birnholz. All rights reserved.
//

import UIKit
import NotificationCenter

extension WidgetViewController: NCWidgetProviding {
	
	func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
		// Perform any setup necessary in order to update the view.
		
		// If an error is encountered, use NCUpdateResult.Failed
		// If there's no update required, use NCUpdateResult.NoData
		// If there's an update, use NCUpdateResult.NewData
		
		if let schedule = battleSchedule, schedule.isValid {
			DispatchQueue.main.async {
				self.updateNoDataLabel()
				completionHandler(.noData)
			}
			return
		}
		
		getSchedule { (result) in
			print("Completion")
			switch result {
			case .failure(let error):
				print("Error retreiving the schedule:", error.localizedDescription)
				DispatchQueue.main.async {
					self.updateNoDataLabel()
					completionHandler(.failed)
				}
			case .success(var sch):
				sch.removeExpiredEntries()
				self.battleSchedule = sch
				
				DispatchQueue.main.async {
					self.tableView.reloadData()
					self.updateNoDataLabel()
					
					completionHandler(.newData)
				}
			}
		}
	}
	
	func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
		switch activeDisplayMode {
		case .compact:
			self.preferredContentSize = maxSize
		case .expanded:
			self.preferredContentSize = tableView.contentSize
		}
	}
	
}
