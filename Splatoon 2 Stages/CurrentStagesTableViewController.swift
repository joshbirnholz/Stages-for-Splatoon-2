//
//  CurrentStagesTableViewController.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 8/27/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit
import WatchConnectivity
import PINRemoteImage
import Intents

class CurrentStagesTableViewController: UITableViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "sitebg"))
		tableView.layer.isOpaque = false
		
		tableView.refreshControl?.tintColor = UIColor(white: 1, alpha: 0.4)
		
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(loadSchedule), for: UIControl.Event.valueChanged)
		tableView.refreshControl = refreshControl
		
		if battleSchedule == nil {
			loadSchedule()
		}
		
		if runSchedule == nil {
			getRunSchedule()
		}
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		tabBarController?.tabBar.tintColor = #colorLiteral(red: 0.942276895, green: 0.1737183928, blue: 0.484048605, alpha: 1)
		
		if #available(iOS 12.0, *) {
			let interaction = INInteraction(intent: intent, response: nil)
			
			interaction.donate { error in
				if let error = error {
					print("Error donating interaction:", error.localizedDescription)
				}
			}
		}
		
	}
	
	@available(iOS 12.0, *)
	var intent: ViewBattleScheduleIntent {
		let intent = ViewBattleScheduleIntent()
		intent.mode = .unknown
		
		intent.suggestedInvocationPhrase = "Current stages"
		if let data = #imageLiteral(resourceName: "Overview Shortcut").pngData() {
			intent.setImage(INImage(imageData: data), forParameterNamed: \.mode)
//			intent.setImage(INImage(imageData: data), forParameterNamed: "mode")
		}
		
		return intent
	}

	
	@objc func loadSchedule() {
		getSchedule { (result) in
			switch result {
			case .failure(let error):
				print("Error retreiving the schedule:", error.localizedDescription)
			case .success(let sch):
				battleSchedule = sch
				
				DispatchQueue.main.async {
					self.tableView.reloadData()
					self.tableView.refreshControl?.endRefreshing()
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
				r.removeExpiredShifts()
				r.sort()
				runSchedule = r
				
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
		return battleSchedule == nil ? 0 : 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return battleSchedule == nil ? 0 : 4
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row > 2 {
			return tableView.dequeueReusableCell(withIdentifier: "AttributionCell", for: indexPath)
		}
		
		return stagesCell(forRowAt: indexPath)
	}
	
	func stagesCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "StagesCell", for: indexPath) as? StagesCell else {
			return UITableViewCell()
		}
		
		guard let schedule = battleSchedule else {
			return cell
		}
		
		guard var entry: BattleSchedule.Entry = {
			func match(entry: BattleSchedule.Entry) -> Bool {
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
		cell.stageBNameLabel.text = entry.stageB.name
		
		cell.stageAImageView.pin_setImage(from: remoteImageURL(forImageWithID: entry.stageA.imageID))
		cell.stageBImageView.pin_setImage(from: remoteImageURL(forImageWithID: entry.stageB.imageID))
		
		return cell
	}
	
	@IBAction func attributionButtonPressed(_ sender: UIButton) {
		let url = URL(string: "https://splatoon2.ink")!
		
		UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
	}
	
//	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//		return nil
//	}
	
//	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//		return "Splatoon 2 is © 2017 Nintendo"
//	}
	
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
