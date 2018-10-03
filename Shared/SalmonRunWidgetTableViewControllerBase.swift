//
//  SalmonRunWidgetTableViewController
//  Salmon Run Schedule
//
//  Created by Josh Birnholz on 8/30/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit
import PINRemoteImage

class SalmonRunWidgetTableViewControllerBase: UITableViewController {
	
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
		let url = URL(string: "jbstages://openMode?mode=\(AppSection.salmonRun.rawValue)")!
		extensionContext?.open(url, completionHandler: nil)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	func updateNoDataLabel() {
		if let schedule = runSchedule, !schedule.shifts.isEmpty {
			self.tableView.tableHeaderView = nil
		} else {
			self.tableView.tableHeaderView = noDataLabel
		}
	}
	
	func badgeText(forRowAt indexPath: IndexPath) -> String? {
		guard let runs = runSchedule else {
			return nil
		}
		if runs.shifts[indexPath.row].currentStatus == .open {
			return "Open!"
		}
		
		if indexPath.row == 0 {
			return "Next"
		}
		
		let previous = indexPath.row - 1
		if previous >= 0 && runs.shifts[previous].currentStatus == .open {
			return "Next"
		}
		
		return nil
		
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let runSchedule = runSchedule else {
			return 0
		}
		
		return min(runSchedule.shifts.count, 2)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "SalmonRunCell", for: indexPath) as! SalmonRunCell
		
		guard let run = runSchedule?.shifts[indexPath.row] else {
			return cell
		}
		
		let timeString = dateFormatter.string(from: run.startTime) + " - "  + dateFormatter.string(from: run.endTime)
		cell.timeLabel.text = timeString
		
		if let stage = run.stage {
			cell.extendedInfoStackView?.isHidden = false
			cell.stageNameLabel?.text = stage.name
			
			cell.stageImageView?.pin_setImage(from: remoteImageURL(forImageWithID: stage.imageID))
			
			for (index, weapon) in run.weapons.prefix(4).enumerated() {
				guard let weapon = weapon else {
					cell.weaponImageViews[index].image = #imageLiteral(resourceName: "random weapon")
					continue
				}
				
				cell.weaponImageViews[index].pin_setImage(from: remoteImageURL(forImageWithID: weapon.imageID))
			}
		} else {
			cell.extendedInfoStackView?.isHidden = true
		}
		
		if let text = runSchedule?.badgeText(forRowAt: indexPath.row) {
			cell.badgeView.isHidden = false
			cell.badgeLabel.text = text
		} else {
			cell.badgeView.isHidden = true
		}
		
		return cell
	}

}
