//
//  WidgetStagesViewController.swift
//  Salmon Run Schedule
//
//  Created by Josh Birnholz on 8/29/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit
import PINRemoteImage

class WidgetStagesViewController: UITableViewController {
	
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
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		fatalError("\(#function) unimplemented")
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
		
		let mode = Mode(rawValue: entry.gameMode.key) ?? self.mode!
		
		(cell.viewWithTag(200) as? UIImageView)?.image = mode.icon
		
		cell.modeLabel.textColor = mode.color
		
		cell.stageAImageView.layer.cornerRadius = 4
		cell.stageAImageView.clipsToBounds = true
		cell.stageBImageView.layer.cornerRadius = 4
		cell.stageBImageView.clipsToBounds = true
		
		cell.stageANameLabel.text = entry.stageA.name
		cell.stageBNameLabel.text = entry.stageB.name
		
		cell.stageAImageView.pin_setImage(from: remoteImageURL(forImageWithID: entry.stageA.imageID))
		cell.stageBImageView.pin_setImage(from: remoteImageURL(forImageWithID: entry.stageB.imageID))
		
		if entry.endTime < Date() {
			cell.alpha = 0.4
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		fatalError("\(#function) unimplemented")
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		print(#function)
		let url = URL(string: "jbstages://openMode?mode=\(mode.rawValue)")!
		extensionContext?.open(url, completionHandler: nil)
	}
	
}
