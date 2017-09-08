//
//  SalmonRunTableViewController
//  Salmon Run Schedule
//
//  Created by Josh Birnholz on 8/30/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit
import NotificationCenter

class SalmonRunTableViewController: UITableViewController, NCWidgetProviding {
	
	var runs: Runs?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "blob"))
		tableView.layer.isOpaque = false
		
		tableView.showsHorizontalScrollIndicator = false
		tableView.showsVerticalScrollIndicator = false
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
		// Perform any setup necessary in order to update the view.
		
		// If an error is encountered, use NCUpdateResult.Failed
		// If there's no update required, use NCUpdateResult.NoData
		// If there's an update, use NCUpdateResult.NewData
		if let runs = runs, runs.isValid {
			completionHandler(.noData)
			return
		}
		
		getRuns { (result) in
			switch result {
			case .failure(let error):
				print("Error getting runs:", error.localizedDescription)
				completionHandler(.noData)
			case .success(let r):
				self.runs = r
				DispatchQueue.main.async {
					self.tableView.reloadData()
					completionHandler(.newData)
				}
			}
		}
	}
	
	func badgeText(forRowAt indexPath: IndexPath) -> String? {
		guard let runs = runs else {
			return nil
		}
		if runs.runs[indexPath.row].isOpen {
			return "Open!"
		}
		
		if indexPath.row == 0 {
			return "Next"
		}
		
		let previous = indexPath.row - 1
		if previous >= 0 && runs.runs[previous].isOpen {
			return "Next"
		}
		
		return nil
		
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let runs = runs else {
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
		
		guard let run = runs?.runs[indexPath.row] else {
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
	
	func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
		switch activeDisplayMode {
		case .compact:
			self.preferredContentSize = maxSize
		case .expanded:
			self.preferredContentSize = tableView.contentSize
		}
	}
}
