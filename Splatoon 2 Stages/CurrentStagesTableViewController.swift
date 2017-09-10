//
//  CurrentStagesTableViewController.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 8/27/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit
import WatchConnectivity

class CurrentStagesTableViewController: UITableViewController {
	
	@IBOutlet var watchSettingsButton: UIBarButtonItem!
	
	@IBAction func settingsButtonPressed(_ sender: Any) {
		tabBarController?.performSegue(withIdentifier: "Settings", sender: sender)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "sitebg"))
		tableView.layer.isOpaque = false
		
		if #available(iOS 10.0, *) {
			tableView.refreshControl?.tintColor = UIColor(white: 1, alpha: 0.4)
		}
		
		if #available(iOS 10.0, *) {
			let refreshControl = UIRefreshControl()
			refreshControl.addTarget(self, action: #selector(loadSchedule), for: .valueChanged)
			tableView.refreshControl = refreshControl
		}
		
		if schedule == nil {
			loadSchedule()
		}
		
		if runs == nil {
			getRunSchedule()
		}
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
//		if schedule == nil || (!(schedule!.regularEntries.first?.isCurrent ?? true)) {
//			loadSchedule()
//		}
		
		
		tabBarController?.tabBar.tintColor = #colorLiteral(red: 0.942276895, green: 0.1737183928, blue: 0.484048605, alpha: 1)
	}
	
	@objc func loadSchedule() {
		getSchedule { (result) in
			switch result {
			case .failure(let error):
				print("Error retreiving the schedule:", error.localizedDescription)
			case .success(let sch):
				schedule = sch
				
				DispatchQueue.main.async {
					if #available(iOS 10.0, *) {
						self.tableView.reloadData()
						self.tableView.refreshControl?.endRefreshing()
					}
				}
			}
		}
		
	}
	
	func getRunSchedule() {
		getRuns { (result) in
			switch result {
			case .failure(let error):
				print("Error retreiving salmon runs:", error.localizedDescription)
			case .success(var r):
				r.removeExpiredRuns()
				r.sort()
				runs = r
				
				DispatchQueue.main.async {
					(self.tabBarController as? SplatoonTabBarController)?.updateSalmonRunBadge()
				}
				
			}
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return schedule == nil ? 0 : 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return schedule == nil ? 0 : 3
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return stagesCell(forRowAt: indexPath)
	}
	
	func stagesCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "StagesCell", for: indexPath) as? StagesCell else {
			return UITableViewCell()
		}
		
		guard let schedule = schedule else {
			return cell
		}
		
		guard let entry: Schedule.Entry = {
			func match(entry: Schedule.Entry) -> Bool {
				let now = Date()
				return entry.startTime < now && entry.endTime > now
			}
			
			switch indexPath.row {
			case 0:
				return schedule.regularEntries.first(where: match)
			case 1:
				return schedule.rankedEntries.first(where: match)
			case 2:
				return schedule.leagueEntries.first(where: match)
			default:
				return nil
			}
			}() else {
				return cell
		}
		
		let gameMode = Mode(rawValue: entry.gameMode.key) ?? .regular
		
		cell.modeLabel.text = String(describing: gameMode)
		//		cell.modeLabel.textColor = gameMode.color
		cell.timeLabel.text = entry.rule.name
		cell.timeLabel.textColor = gameMode.color
		
		cell.stageANameLabel.text = entry.stageA.name
		cell.stageAImageView.image = UIImage(named: entry.stageA.name.lowercased().replacingOccurrences(of: " ", with: "-"))
		cell.stageBNameLabel.text = entry.stageB.name
		cell.stageBImageView.image = UIImage(named: entry.stageB.name.lowercased().replacingOccurrences(of: " ", with: "-"))
		
		return cell
	}
	
	func salmonRunCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let run = runs?.runs.first else {
			return UITableViewCell()
		}
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "SalmonCell", for: indexPath) as! SalmonRunCell
		cell.setNeedsLayout()
		
		let timeString = dateFormatter.string(from: run.startTime) + " - "  + dateFormatter.string(from: run.endTime)
		cell.timeLabel.text = timeString
		
		cell.badgeLabel.text = run.status == .open ? "Open!" : "Next"
		
		return cell
	}
	
	@IBAction func unwindToCurrentStagesViewController(segue: UIStoryboardSegue) {
	
	}
	
//	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//		return nil
//	}
	
//	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//		return "Splatoon 2 is © 2017 Nintendo"
//	}
	
}
