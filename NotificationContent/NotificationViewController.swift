//
//  NotificationViewController.swift
//  NotificationContent
//
//  Created by Josh Birnholz on 1/31/18.
//  Copyright © 2018 Joshua Birnholz. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

	var entry: BattleSchedule.Entry!
	
    @IBOutlet var label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
		guard let jsonString = notification.request.content.userInfo["entryJSON"] as? String,
			let entry = try? decoder.decode(BattleSchedule.Entry.self, from: jsonString.data(using: .utf8)!) else {
			return
		}
		
		self.entry = entry
    }

}
