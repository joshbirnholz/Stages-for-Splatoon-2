//
//  ViewController.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 8/27/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit


class UpcomingStagesViewController: UITableViewController {
	
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
		
		if schedule == nil {
			loadSchedule()
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
				schedule = sch
				
				DispatchQueue.main.async {
					self.tableView.reloadData()
					if #available(iOS 10.0, *) {
						self.tableView.refreshControl?.endRefreshing()
					}
				}
			}
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		guard let _ = schedule else {
			return 0
		}
		
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let schedule = schedule else  {
			return 0
		}
		
		return schedule[mode].count
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
		cell.timeLabel.text = dateFormatter.string(from: entry.startTime)
		
		cell.stageANameLabel.text = entry.stageA.name
		cell.stageAImageView.image = UIImage(named: entry.stageA.name.lowercased().replacingOccurrences(of: " ", with: "-"))
		cell.stageBNameLabel.text = entry.stageB.name
		cell.stageBImageView.image = UIImage(named: entry.stageB.name.lowercased().replacingOccurrences(of: " ", with: "-"))
		
		if entry.endTime < Date() {
			cell.alpha = 0.4
		}
		
		return cell
	}

}

