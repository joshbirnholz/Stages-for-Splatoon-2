//
//  NotificationsViewController.swift
//  Countdowns
//
//  Created by Josh Birnholz on 5/4/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit
import UserNotifications

class RightDetailCell: UITableViewCell {
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .value1, reuseIdentifier: reuseIdentifier)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}

class NotificationsViewController: UITableViewController, AlertPickerTableViewControllerDelegate {

	var subject: AlertSubject!
	
	var firstAlertTime: AlertTime?
	var secondAlertTime: AlertTime?
	
	var currentPickingAlertNumber: Int?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard subject.alertEventDate != nil else {
			print("Tried to set notifications for date item with no date")
			return
		}
		
		tableView = UITableView(frame: .zero, style: .grouped)
		
		tableView.register(RightDetailCell.self, forCellReuseIdentifier: "notificationOptionCell")
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed))
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
		
		navigationItem.title = "Notifications"
	
		subject.getPendingNotificationRequestsAlertTimes { alertTimes in
			print(alertTimes)
			
			var mutableAlertTimes = alertTimes
			
			if !mutableAlertTimes.isEmpty {
				self.firstAlertTime = mutableAlertTimes.removeFirst()
			}
			
			if !mutableAlertTimes.isEmpty {
				self.secondAlertTime = mutableAlertTimes.removeFirst()
			}
			
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}
	
	// MARK: UITableView methods
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "notificationOptionCell", for: indexPath)
		
		switch indexPath.row {
		case 0:
			cell.textLabel?.text = "Alert"
			cell.detailTextLabel?.text = firstAlertTime?.description ?? "None"
		case 1:
			cell.textLabel?.text = "Second Alert"
			cell.detailTextLabel?.text = secondAlertTime?.description ?? "None"
		default:
			cell.textLabel?.text = ""
			cell.detailTextLabel?.text = ""
		}
		
		return cell
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? 2 : 0
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

//		guard let alertPicker = UIStoryboard(name: "Detail", bundle: .main).instantiateViewController(withIdentifier: "alertOptionsVC") as? AlertPickerTableViewController else {
//			return
//		}
		
		let alertPicker = AlertPickerTableViewController()
		
		alertPicker.delegate = self
		
		switch indexPath.row {
		case 0:
			alertPicker.selectedAlertTimeOption = firstAlertTime
			currentPickingAlertNumber = 0
		case 1:
			alertPicker.selectedAlertTimeOption = secondAlertTime
			currentPickingAlertNumber = 1
		default:
			return
		}
		
		navigationController?.pushViewController(alertPicker, animated: true)
		
	}
	
	func alertPicker(_ alertPicker: AlertPickerTableViewController, didPick alertTime: AlertTime?) {
		navigationController?.popViewController(animated: true)
		
		guard let alertNumber = currentPickingAlertNumber else {
			return
		}
		
		if alertNumber == 0 {
			firstAlertTime = alertTime
		} else if alertNumber == 1 {
			secondAlertTime = alertTime
		}
		
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
		currentPickingAlertNumber = nil
		
	}
	
	@objc func cancelButtonPressed() {
		dismiss(animated: true, completion: nil)
	}
	
	@objc func doneButtonPressed() {
		subject.removeAllPendingNotificationRequests() {
			self.subject.scheduleAlerts([self.firstAlertTime, self.secondAlertTime].flatMap { $0 })
		}
		dismiss(animated: true, completion: nil)
	}
}

extension AlertTime {
	
	
	
}
