//
//  ViewController.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 8/27/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit
import Intents
import IntentsUI

class UpcomingStagesViewController: UITableViewController {
	
	@IBOutlet weak var noDataLabel: UILabel!
	
	var mode: Mode!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "zigzag"))
		tableView.layer.isOpaque = false
		
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(loadSchedule), for: UIControl.Event.valueChanged)
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
		intent.mode = ViewBattleScheduleBattleMode(nativeMode: self.mode)
		
		intent.suggestedInvocationPhrase = mode.description + " Stages"
		if let data = mode.shortcutIcon.pngData() {
			intent.setImage(INImage(imageData: data), forParameterNamed: \.mode)
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
		
		cell.stageAImageView.pin_setImage(from: remoteImageURL(forImageWithID: entry.stageA.imageID))
		cell.stageBImageView.pin_setImage(from: remoteImageURL(forImageWithID: entry.stageB.imageID))
		
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
		
		return schedule[mode][indexPath.row].startTime > Date()
	}
	
}

@available(iOS 12.0, *)
extension UpcomingStagesViewController: INUIAddVoiceShortcutViewControllerDelegate {
	func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
		if let error = error {
			print("Error adding voice shortcut:", error.localizedDescription)
		}
	}
	
	func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
		dismiss(animated: true, completion: nil)
	}
	
	
}
