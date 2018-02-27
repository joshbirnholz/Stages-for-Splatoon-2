//
//  ViewController.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 8/27/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit


class UpcomingStagesViewController: UITableViewController {
	
	@IBOutlet weak var noDataLabel: UILabel!
	
	var mode: Mode!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "zigzag"))
		tableView.layer.isOpaque = false
		
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(loadSchedule), for: .valueChanged)
		refreshControl.tintColor = UIColor(white: 1, alpha: 0.4)
		tableView.refreshControl = refreshControl
		
		navigationItem.title = mode.description
		
		if battleSchedule == nil {
			loadSchedule()
		}
		
		updateNoDataLabel()
	}
	
	func updateNoDataLabel() {
		if let schedule = battleSchedule, !schedule[mode].isEmpty {
			self.tableView.tableHeaderView = nil
		} else {
			self.tableView.tableHeaderView = noDataLabel
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		tabBarController?.tabBar.tintColor = mode.color
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
					self.updateNoDataLabel()
					self.tableView.refreshControl?.endRefreshing()
				}
			}
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		guard let _ = battleSchedule else {
			return 0
		}
		
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let schedule = battleSchedule else  {
			return 0
		}
		
		return schedule[mode].count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "StagesCell", for: indexPath) as? StagesCell else {
			return UITableViewCell()
		}
		
		guard let schedule = battleSchedule else {
			return cell
		}
		
		var entry = schedule[mode][indexPath.row]
		
		let gameMode = Mode(rawValue: entry.gameMode.key) ?? .regular
		
		cell.modeLabel.text = entry.rule.name
		cell.modeLabel.textColor = gameMode.color
		cell.timeLabel.text = dateFormatter.string(from: entry.startTime)
		
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
		
		cell.selectedBackgroundColor = .clear
		cell.tintColor = mode.color
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		guard let schedule = battleSchedule else {
			return false
		}
		
//		return schedule[mode][indexPath.row].startTime > Date()
		return false
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		print(#function)
		
		guard let entry = battleSchedule?[mode][indexPath.row] else {
			return
		}
		
		let popup = PopupDialog(title: entry.rule.name + "\n" + mode.description, message: dateFormatter.string(from: entry.startTime) + " - " + dateFormatter.string(from: entry.endTime) + "\n" + entry.stageA.name + "\n" + entry.stageB.name + "\n")
		(popup.presentationController as? PresentationController)?.overlay.blurEnabled = false
		popup.modalPresentationCapturesStatusBarAppearance = false
		
		let reminderButton = PopupDialogButton(title: "Two Seconds") {
			let alertTime = AlertTime(timeInterval: (entry.startTime.timeIntervalSinceNow * -1) + 2)
			entry.scheduleAlerts([alertTime])
		}
		
		popup.addButton(reminderButton)
		
		present(popup, animated: true, completion: nil)
	}
	
}

