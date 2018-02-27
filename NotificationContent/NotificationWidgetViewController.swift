//
//  RegularWidgetViewController.swift
//  Salmon Run Schedule
//
//  Created by Josh Birnholz on 8/29/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class WidgetViewController: WidgetStagesViewController, UNNotificationContentExtension {
	
	private var _entry: BattleSchedule.Entry!
	
	override var entries: [BattleSchedule.Entry] {
		return [_entry]
	}
	
	override var mode: Mode! {
		return Mode(rawValue: _entry.gameMode.key)
	}
	
	func didReceive(_ notification: UNNotification) {
		if let jsonString = notification.request.content.userInfo["entryJSON"] as? String,
			let entry = try? decoder.decode(BattleSchedule.Entry.self, from: jsonString.data(using: .utf8)!) {
			_entry = entry
		}
		
	}
}
