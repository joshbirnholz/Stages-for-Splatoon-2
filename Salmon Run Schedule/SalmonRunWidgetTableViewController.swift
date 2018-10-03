//
//  SalmonRunWidgetTableViewController
//  Salmon Run Schedule
//
//  Created by Josh Birnholz on 8/30/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit
import NotificationCenter

class SalmonRunWidgetTableViewController: SalmonRunWidgetTableViewControllerBase, NCWidgetProviding {
	func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
		// Perform any setup necessary in order to update the view.
		
		// If an error is encountered, use NCUpdateResult.Failed
		// If there's no update required, use NCUpdateResult.NoData
		// If there's an update, use NCUpdateResult.NewData
		if let runs = runSchedule, runs.isValid {
			DispatchQueue.main.async {
				self.updateNoDataLabel()
				completionHandler(.noData)
			}
			return
		}
		
		getRuns { (result) in
			switch result {
			case .failure(let error):
				print("Error getting runs:", error.localizedDescription)
				DispatchQueue.main.async {
					self.updateNoDataLabel()
					self.extensionContext?.widgetLargestAvailableDisplayMode = .compact
					completionHandler(.failed)
				}
			case .success(var r):
				r.removeExpiredShifts()
				r.sort()
				self.runSchedule = r
				DispatchQueue.main.async {
					self.tableView.reloadData()
					self.updateNoDataLabel()
					
					self.extensionContext?.widgetLargestAvailableDisplayMode = r.shifts.count > 1 ? .expanded : .compact
					self.preferredContentSize = self.tableView.contentSize
					
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
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let url = URL(string: "jbstages://openMode?mode=\(AppSection.salmonRun.rawValue)")!
		extensionContext?.open(url, completionHandler: nil)
	}
}
