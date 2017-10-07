//
//  SalmonRunWidgetTableViewController
//  Salmon Run Schedule
//
//  Created by Josh Birnholz on 8/30/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit
import NotificationCenter

class SalmonRunWidgetTableViewController: UITableViewController, NCWidgetProviding {
	
	@IBOutlet var noDataLabel: UILabel!
	var runSchedule: SalmonRunSchedule?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "blob"))
		tableView.layer.isOpaque = false
		
		tableView.showsHorizontalScrollIndicator = false
		tableView.showsVerticalScrollIndicator = false
		
	}
	
	func openApp() {
		let url = URL(string: "jbstages://openMode?mode=\(WatchScreen.salmonRun.rawValue)")!
		extensionContext?.open(url, completionHandler: nil)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	func updateNoDataLabel() {
		if let schedule = runSchedule, !schedule.runs.isEmpty {
			self.tableView.tableHeaderView = nil
		} else {
			self.tableView.tableHeaderView = noDataLabel
		}
	}
	
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
					completionHandler(.failed)
				}
			case .success(var r):
				r.removeExpiredRuns()
				r.sort()
				self.runSchedule = r
				DispatchQueue.main.async {
					self.tableView.reloadData()
					self.updateNoDataLabel()
					completionHandler(.newData)
				}
			}
		}
	}
	
	func badgeText(forRowAt indexPath: IndexPath) -> String? {
		guard let runs = runSchedule else {
			return nil
		}
		if runs.runs[indexPath.row].status == .open {
			return "Open!"
		}
		
		if indexPath.row == 0 {
			return "Next"
		}
		
		let previous = indexPath.row - 1
		if previous >= 0 && runs.runs[previous].status == .open {
			return "Next"
		}
		
		return nil
		
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let runs = runSchedule else {
			extensionContext?.widgetLargestAvailableDisplayMode = .compact
			return 0
		}
		
		if runs.runs.count > 2 {
			extensionContext?.widgetLargestAvailableDisplayMode = .expanded
		} else {
			extensionContext?.widgetLargestAvailableDisplayMode = .compact
		}
		
		return runs.runs.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "SalmonRunCell", for: indexPath) as! SalmonRunCell
		
		guard let run = runSchedule?.runs[indexPath.row] else {
			return cell
		}
		
		let timeString = dateFormatter.string(from: run.startTime) + " - "  + dateFormatter.string(from: run.endTime)
		cell.timeLabel.text = timeString
		
		if let text = badgeText(forRowAt: indexPath) {
			cell.badgeView.isHidden = false
			cell.badgeLabel.text = text
		} else {
			cell.badgeView.isHidden = true
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return extensionContext!.widgetMaximumSize(for: .compact).height / 2
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let url = URL(string: "jbstages://openMode?mode=\(WatchScreen.salmonRun.rawValue)")!
		extensionContext?.open(url, completionHandler: nil)
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
