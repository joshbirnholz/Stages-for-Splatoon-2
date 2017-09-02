//
//  WidgetStagesViewController.swift
//  Salmon Run Schedule
//
//  Created by Josh Birnholz on 8/29/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit
import NotificationCenter


class WidgetStagesViewController: UITableViewController, NCWidgetProviding {
	
	var schedule: Schedule?
	
	static let widgetFormatter: DateFormatter = {
		let df = DateFormatter()
		df.setLocalizedDateFormatFromTemplate("hmma")
		return df
	}()
	
	var mode: Mode! {
		return nil
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "zigzag"))
		tableView.layer.isOpaque = false

		tableView.showsVerticalScrollIndicator = false
		tableView.showsHorizontalScrollIndicator = false

	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		tabBarController?.tabBar.tintColor = mode.color
	}
	
	func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
		// Perform any setup necessary in order to update the view.
		
		// If an error is encountered, use NCUpdateResult.Failed
		// If there's no update required, use NCUpdateResult.NoData
		// If there's an update, use NCUpdateResult.NewData
		
		print("Update")
		getSchedule { (result) in
			print("Completion")
			switch result {
			case .failure(let error):
				print("Error retreiving the schedule:", error.localizedDescription)
				completionHandler(.failed)
			case .success(let sch):
				self.schedule = sch
				
				DispatchQueue.main.async {
					self.tableView.reloadData()
					completionHandler(.newData)
				}
			}
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let schedule = schedule else {
			extensionContext?.widgetLargestAvailableDisplayMode = .compact
			return 0
		}
		
		if schedule[mode].count >= 2 {
			extensionContext?.widgetLargestAvailableDisplayMode = .expanded
		} else {
			extensionContext?.widgetLargestAvailableDisplayMode = .compact
		}
		
		return min(2, schedule[mode].count)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "StagesCell", for: indexPath) as? StagesCell else {
			return UITableViewCell()
		}
		
		guard let schedule = schedule else {
			return cell
		}
		
		let entry = schedule[mode][indexPath.row]
		
		let gameMode = Mode(rawValue: entry.gameMode.key) ?? .regular
		
		cell.modeLabel.text = entry.rule.name
		cell.modeLabel.textColor = gameMode.color
		
		cell.timeLabel.text = WidgetStagesViewController.widgetFormatter.string(from: entry.startTime) + " - " + WidgetStagesViewController.widgetFormatter.string(from: entry.endTime)
		
		(cell.viewWithTag(200) as? UIImageView)?.image = mode.icon
		
		cell.modeLabel.textColor = mode.color
		
		cell.stageAImageView.layer.cornerRadius = 4
		cell.stageAImageView.clipsToBounds = true
		cell.stageBImageView.layer.cornerRadius = 4
		cell.stageBImageView.clipsToBounds = true
		
		cell.stageANameLabel.text = entry.stageA.name
		cell.stageAImageView.image = UIImage(named: entry.stageA.name.lowercased().replacingOccurrences(of: " ", with: "-"))
		cell.stageBNameLabel.text = entry.stageB.name
		cell.stageBImageView.image = UIImage(named: entry.stageB.name.lowercased().replacingOccurrences(of: " ", with: "-"))
		
		if entry.endTime < Date() {
			cell.alpha = 0.4
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return extensionContext?.widgetMaximumSize(for: .compact).height ?? 44
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
