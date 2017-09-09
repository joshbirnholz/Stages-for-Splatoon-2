//
//  SettingsTableViewController.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 9/8/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit
import WatchConnectivity

class SettingsTableViewController: UITableViewController {
	
	private var complicationMode: Mode {
		get {
			if let str = UserDefaults.group.string(forKey: "complicationMode"),
				let mode = Mode(rawValue: str) {
				return mode
			}
			return .regular
		}
		set {
			UserDefaults.group.set(newValue.rawValue, forKey: "complicationMode")
		}
	}
	
	@IBOutlet weak var regularBattleStagesCell: UITableViewCell!
	@IBOutlet weak var rankedBattleStagesCell: UITableViewCell!
	@IBOutlet weak var leagueBattleStagesCell: UITableViewCell!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationController?.view.backgroundColor = .clear
		tableView.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
		
		updateCheckedCell()
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if indexPath.section == 0 {
			
			tableView.deselectRow(at: indexPath, animated: true)
			
			if indexPath == tableView.indexPath(for: regularBattleStagesCell) {
				complicationMode = .regular
			} else if indexPath == tableView.indexPath(for: rankedBattleStagesCell) {
				complicationMode = .ranked
			} else if indexPath == tableView.indexPath(for: leagueBattleStagesCell) {
				complicationMode = .league
			}
			
			updateCheckedCell()
			
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		
		if cellShouldBeChecked(at: indexPath) {
			cell.accessoryType = .checkmark
		} else if indexPath.section == 0 {
			cell.accessoryType = .none
		}
		
		return cell
	}
	
	private func cellShouldBeChecked(at indexPath: IndexPath) -> Bool {
		guard indexPath.section == 0 else {
			return false
		}
		
		switch complicationMode {
		case .regular:
			return indexPath.row == 0
		case .ranked:
			return indexPath.row == 1
		case .league:
			return indexPath.row == 2
		}
	}
	
	private func updateCheckedCell() {
		
		for (row, cell) in (0...2).map({ tableView.cellForRow(at: IndexPath(row: $0, section: 0)) }).enumerated() {
			cell?.accessoryType = cellShouldBeChecked(at: IndexPath(row: row, section: 0)) ? .checkmark : .none
		}
	}
	
}
