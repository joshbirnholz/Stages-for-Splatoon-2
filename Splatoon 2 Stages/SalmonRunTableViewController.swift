//
//  SalmonRunTableViewController.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 8/27/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit

class SalmonRunTableViewController: UITableViewController {
	
	@IBOutlet var noDataLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "blob"))
		tableView.layer.isOpaque = false
		
		if #available(iOS 10.0, *) {
			let refreshControl = UIRefreshControl()
			refreshControl.addTarget(self, action: #selector(loadRuns), for: .valueChanged)
			refreshControl.tintColor = UIColor(white: 1, alpha: 0.4)
			tableView.refreshControl = refreshControl
		}
		
		if runSchedule == nil {
			loadRuns()
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		tabBarController?.tabBar.tintColor = #colorLiteral(red: 0.9867637753, green: 0.2715459905, blue: 0.03388012111, alpha: 1)
	}
	
	@objc func loadRuns() {
		getRuns { (result) in
			switch result {
			case .failure(let error):
				print("Error getting runs:", error.localizedDescription)
			case .success(var r):
				r.removeExpiredRuns()
				r.sort()
				runSchedule = r
				DispatchQueue.main.async {
					if #available(iOS 10.0, *) {
					self.tableView.refreshControl?.endRefreshing()
					}
					
					self.tableView.tableHeaderView = r.runs.isEmpty ? self.noDataLabel : nil
					
					self.tableView.reloadData()
					(self.tabBarController as? SplatoonTabBarController)?.updateSalmonRunBadge()
				}
			}
		}
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		guard let _ = runSchedule else {
			return 0
		}
		
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let runs = runSchedule else {
			return 0
		}
		
		return runs.runs.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "SalmonRunCell", for: indexPath) as! SalmonRunCell
		
		guard let run = runSchedule?.runs[indexPath.row] else {
			return cell
		}
		
		let timeString = dateFormatter.string(from: run.startTime) + " - "  + dateFormatter.string(from: run.endTime)
		cell.timeLabel.text = timeString
		
		if let text = runSchedule?.badgeText(forRowAt: indexPath.row) {
			cell.badgeView.isHidden = false
			cell.badgeLabel.text = text
		} else {
			cell.badgeView.isHidden = true
		}
		
		return cell
	}
}
