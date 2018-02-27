//
//  AlertSubject.swift
//  Countdowns
//
//  Created by Josh Birnholz on 1/31/18.
//  Copyright © 2018 Joshua Birnholz. All rights reserved.
//

import UserNotifications

protocol AlertSubject {
	var alertEventDate: Date? { get }
	var alertEventID: String { get }
	func alertContent(_ alertTime: AlertTime) -> UNNotificationContent?
	
	func scheduleAlerts(_ alertTimes: [AlertTime])
}

extension AlertSubject {
	
	func getPendingNotificationRequestsAlertTimes(completion: @escaping ([AlertTime]) -> Void) {
		
		guard let alertEventDate = alertEventDate else {
			completion([])
			return
		}
		
		getPendingNotificationRequests { requests in
			
			var alertTimes: [AlertTime] = []
			
			for request in requests {
				if let firstRequestTrigger = request.trigger as? UNCalendarNotificationTrigger {
					let dateComponents = firstRequestTrigger.dateComponents
					if let alertDate = Calendar.current.date(from: dateComponents) {
						
						let timeInterval = alertEventDate.timeIntervalSince(alertDate)
						
						let alertTime = AlertTime(timeInterval: timeInterval)
						alertTimes.append(alertTime)
					}
				}
			}
			
			alertTimes.sort(by: <)
			
			completion(alertTimes)
			
		}
		
	}
	
	func getPendingNotificationRequests(completion: @escaping ([UNNotificationRequest]) -> Void) {
		
		UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
			let requests = requests.filter {
				$0.identifier.contains(self.alertEventID)
			}
			
			completion(requests)
			
		}
		
	}
	
	func removeAllPendingNotificationRequests (completion: (() -> Void)? = nil) {
		getPendingNotificationRequests { requests in
			
			let center = UNUserNotificationCenter.current()
			
			let ids = requests.map { $0.identifier }
			
			center.removePendingNotificationRequests(withIdentifiers: ids)
			
			completion?()
			
		}
	}
	
	func scheduleAlerts(_ alertTimes: [AlertTime]) {
		
		let center = UNUserNotificationCenter.current()
		
		// Then schedule the new times
		for (alertNumber, alertTime) in alertTimes.enumerated() {
			
			let alertID = "\(self.alertEventID)-alert\(alertNumber)"
			
			guard let alertEventDate = alertEventDate, let content = alertContent(alertTime) else {
				continue
			}
			
//			let trigger = alertTime.calendarNotificationTrigger(for: alertEventDate)
//			print("Scheduling notification for", Calendar.current.date(from: trigger.dateComponents) ?? "nil")
			
			let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
			
			let request = UNNotificationRequest(identifier: alertID , content: content, trigger: trigger)
			
			center.add(request) { error in
				if let error = error {
					print("Error scheduling notification", error.localizedDescription)
				}
			}
			
		}
		
	}
	
}

extension AlertTime {
	
	func calendarNotificationTrigger(for date: Date) -> UNCalendarNotificationTrigger {
		let components = Calendar.current.dateComponents([.hour, .minute, .second, .year, .month, .day], from:  notificationDate(for: notificationDate(for: date)))
		return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
	}
	
}
