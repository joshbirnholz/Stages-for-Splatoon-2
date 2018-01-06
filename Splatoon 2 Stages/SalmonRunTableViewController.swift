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
		
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(loadRuns), for: .valueChanged)
		refreshControl.tintColor = UIColor(white: 1, alpha: 0.4)
		tableView.refreshControl = refreshControl
		
		if runSchedule == nil {
			loadRuns()
		}
		
		updateNoDataLabel()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		tabBarController?.tabBar.tintColor = #colorLiteral(red: 0.9867637753, green: 0.2715459905, blue: 0.03388012111, alpha: 1)
	}
	
	func updateNoDataLabel() {
		if let schedule = runSchedule, !schedule.shifts.isEmpty {
			self.tableView.tableHeaderView = nil
		} else {
			self.tableView.tableHeaderView = noDataLabel
		}
	}
	
	@objc func loadRuns() {
		self.tableView.refreshControl?.beginRefreshing()
		getRuns { (result) in
			switch result {
			case .failure(let error):
				print("Error getting runs:", error.localizedDescription)
			case .success(var r):
				r.removeExpiredShifts()
				r.sort()
				runSchedule = r
				DispatchQueue.main.async {
					self.tableView.refreshControl?.endRefreshing()
					
					self.tableView.reloadData()
					self.updateNoDataLabel()
					
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
		
		return runs.shifts.count
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
			
			loadImage(withSplatNetID: stage.imageID) { image in
				DispatchQueue.main.async {
					(tableView.cellForRow(at: indexPath) as? SalmonRunCell)?.stageImageView?.image = image
				}
			}
			
			for (index, weapon) in run.weapons.prefix(4).enumerated() {
				guard let weapon = weapon else {
					cell.weaponImageViews[index].image = #imageLiteral(resourceName: "random weapon")
					continue
				}
				
				loadImage(withSplatNetID: weapon.imageID) { image in
					DispatchQueue.main.async {
						(tableView.cellForRow(at: indexPath) as? SalmonRunCell)?.weaponImageViews[index].image = image
					}
				}
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
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let weapons = runSchedule?.shifts[indexPath.row].weapons, !weapons.isEmpty else {
			return
		}
		
		let message = weapons.map { $0?.name ?? "?" }.joined(separator: "\n")
		
		let popup = PopupDialog(title: "Supplied Weapons", message: message)
		(popup.presentationController as? PresentationController)?.overlay.blurEnabled = false
		popup.modalPresentationCapturesStatusBarAppearance = false
		present(popup, animated: true, completion: nil)
		
//		let vc = storyboard!.instantiateViewController(withIdentifier: "WeaponInfo")
		
//		let popup = PopupDialog(viewController: vc, transitionStyle: .bounceDown, gestureDismissal: true, hideStatusBar: false, completion: nil)
//		(popup.presentationController as? PresentationController)?.overlay.blurEnabled = false
//
//		present(popup, animated: true, completion: nil)
		
//		let alert = UIAlertController(title: "Supplied Weapons", message: message, preferredStyle: .alert)
//		let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//		alert.addAction(okAction)
//		present(alert, animated: true, completion: nil)
		
	}
	
}
