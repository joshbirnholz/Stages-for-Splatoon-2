//
//  AlertPickerViewController.swift
//  Countdowns
//
//  Created by Josh Birnholz on 5/4/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit

protocol AlertPickerTableViewControllerDelegate: class {
	
	func alertPicker(_ alertPicker: AlertPickerTableViewController, didPick alertTime: AlertTime?)
	
}

class AlertPickerTableViewController: UITableViewController {
	
	weak var delegate: AlertPickerTableViewControllerDelegate?
	
	var selectedAlertTimeOption: AlertTime?
	
	private var selectedIndex: Int?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView = UITableView(frame: .zero, style: .grouped)
		tableView.register(RightDetailCell.self, forCellReuseIdentifier: "alertOptionCell")
		
		if let selectedAlertTimeOption = selectedAlertTimeOption,
			let selectedIndex = alertTimeOptions.index(of: selectedAlertTimeOption) {
			self.selectedIndex = selectedIndex
		}
	}
	
	private let alertTimeOptions: [AlertTime] = [
		.timeOfEvent,
		.minutesBeforeEvent(5),
		.minutesBeforeEvent(10),
		.minutesBeforeEvent(15),
		.minutesBeforeEvent(30),
		.hoursBeforeEvent(1),
		.hoursBeforeEvent(2),
	]
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 1
		case 1:
			return alertTimeOptions.count
		default:
			return 0
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "alertOptionCell", for: indexPath)
		
		switch indexPath.section {
		case 0:
			cell.textLabel?.text = "None"
			if selectedIndex == nil {
				cell.accessoryType = .checkmark
			}
		case 1:
			cell.textLabel?.text = alertTimeOptions[indexPath.row].description
			if let index = selectedIndex, index == indexPath.row {
				cell.accessoryType = .checkmark
			}
			
		default:
			break
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.section {
		case 0:
			delegate?.alertPicker(self, didPick: nil)
		case 1:
			delegate?.alertPicker(self, didPick: alertTimeOptions[indexPath.row])
		default:
			tableView.deselectRow(at: indexPath, animated: true)
		}
	}
	
}
