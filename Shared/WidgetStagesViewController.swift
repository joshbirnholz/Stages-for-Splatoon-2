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
	
	@IBOutlet var noDataLabel: UILabel!
	var battleSchedule: BattleSchedule?
	
	static let widgetFormatter: DateFormatter = {
		let df = DateFormatter()
		df.setLocalizedDateFormatFromTemplate("hmma")
		return df
	}()
	
	var mode: Mode! {
		return nil
	}
	
	var entries: [BattleSchedule.Entry] {
		guard let battleSchedule = battleSchedule else {
			return []
		}
		return battleSchedule[mode]
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "zigzag"))
		tableView.layer.isOpaque = false

		tableView.showsVerticalScrollIndicator = false
		tableView.showsHorizontalScrollIndicator = false
		
	}
	
	func updateNoDataLabel() {
		if !entries.isEmpty {
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
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard !entries.isEmpty else {
			extensionContext?.widgetLargestAvailableDisplayMode = .compact
			return 0
		}
		
		if entries.count >= 2 {
			extensionContext?.widgetLargestAvailableDisplayMode = .expanded
		} else {
			extensionContext?.widgetLargestAvailableDisplayMode = .compact
		}
		
		return min(2, entries.count)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "StagesCell", for: indexPath) as? StagesCell else {
			return UITableViewCell()
		}
		
		guard !entries.isEmpty else {
			return cell
		}
		
		var entry = entries[indexPath.row]
		
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
		cell.stageBNameLabel.text = entry.stageB.name
		
		loadImage(withSplatNetID: entry.stageA.imageID) { image in
			DispatchQueue.main.async {
				(tableView.cellForRow(at: indexPath) as? StagesCell)?.stageAImageView.image = image
			}
		}
		
		loadImage(withSplatNetID: entry.stageB.imageID) { image in
			DispatchQueue.main.async {
				(tableView.cellForRow(at: indexPath) as? StagesCell)?.stageBImageView.image = image
			}
		}
		
		if entry.endTime < Date() {
			cell.alpha = 0.4
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return extensionContext?.widgetMaximumSize(for: .compact).height ?? 44
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		print(#function)
		let url = URL(string: "jbstages://openMode?mode=\(mode.rawValue)")!
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
