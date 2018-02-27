//
//  AlertTime.swift
//  Countdowns
//
//  Created by Josh Birnholz on 1/16/18.
//  Copyright © 2018 Joshua Birnholz. All rights reserved.
//

import Foundation

enum AlertTime: CustomStringConvertible {
	
	case timeOfEvent
	case timeIntervalBeforeEvent(TimeInterval)
	case minutesBeforeEvent(Int)
	case hoursBeforeEvent(Int)
	case daysBeforeEvent(Int)
	case weeksBeforeEvent(Int)
	
	init(timeInterval: TimeInterval) {
		if timeInterval == 0 {
			self = .timeOfEvent
			return
		}
		
		let weeks = timeInterval / .oneWeek
		if floor(weeks) == weeks {
			self = .weeksBeforeEvent(Int(weeks))
			return
		}
		
		let days = timeInterval / .oneDay
		if floor(days) == days {
			self = .daysBeforeEvent(Int(days))
			return
		}
		
		let hours = timeInterval / .oneHour
		if floor(hours) == hours {
			self = .hoursBeforeEvent(Int(hours))
			return
		}
		
		let minutes = timeInterval / .oneMinute
		if floor(minutes) == minutes {
			self = .minutesBeforeEvent(Int(minutes))
			return
		}
		
		self = .timeIntervalBeforeEvent(timeInterval)
	}
	
	var timeInterval: TimeInterval {
		// I don't know why dividing by two is necessary... but without it, notifications get scheduled for twice as long before the event as necessary
		
		switch self {
		case .timeOfEvent:
			return 0
		case .timeIntervalBeforeEvent(let seconds):
			return seconds * -1 / 2
		case .minutesBeforeEvent(let minutes):
			return TimeInterval(minutes) * .oneMinute * -1 / 2
		case .hoursBeforeEvent(let hours):
			return TimeInterval(hours) * .oneHour * -1 / 2
		case .daysBeforeEvent(let days):
			return TimeInterval(days) * .oneDay * -1 / 2
		case .weeksBeforeEvent(let weeks):
			return TimeInterval(weeks) * .oneWeek * -1 / 2
		}
	}
	
	func notificationDate(for date: Date) -> Date {
		
		return date.addingTimeInterval(timeInterval)
	}
	
	var description: String {
		switch self {
		case .timeOfEvent:
			return "When available"
		case .timeIntervalBeforeEvent(let seconds):
			if seconds == 1 {
				return "1 second before"
			} else if floor(seconds) == seconds {
				return "\(Int(seconds)) seconds before"
			} else {
				return "\(seconds) seconds before"
			}
		case .minutesBeforeEvent(let minutes):
			return minutes == 1 ? "1 minute before" : "\(minutes) minutes before"
		case .hoursBeforeEvent(let hours):
			return hours == 1 ? "1 hour before" : "\(hours) hours before"
		case .daysBeforeEvent(let days):
			return days == 1 ? "1 day before" : "\(days) days before"
		case .weeksBeforeEvent(let weeks):
			return weeks == 1 ? "1 week before" : "\(weeks) weeks before"
		}
		
	}
	
	var timeString: String {
		switch self {
		case .timeOfEvent:
			return "now"
		case .timeIntervalBeforeEvent(let seconds):
			if seconds == 1 {
				return "in 1 second"
			} else if floor(seconds) == seconds {
				return "in \(Int(seconds)) seconds"
			} else {
				return "in \(seconds) seconds"
			}
		case .minutesBeforeEvent(let minutes):
			return minutes == 1 ? "in 1 minute" : "in \(minutes) minutes"
		case .hoursBeforeEvent(let hours):
			return hours == 1 ? "in 1 hour" : "in \(hours) hours"
		case .daysBeforeEvent(let days):
			return days == 1 ? "in 1 day" : "in \(days) days"
		case .weeksBeforeEvent(let weeks):
			return weeks == 1 ? "in 1 week" : "in \(weeks) weeks"
		}
	}
}

extension AlertTime: Equatable {
	
	static func == (lhs: AlertTime, rhs: AlertTime) -> Bool {
		switch (lhs, rhs) {
		case (.timeOfEvent, .timeOfEvent):
			return true
		case (.timeIntervalBeforeEvent(let l), .timeIntervalBeforeEvent(let r)):
			return l == r
		case (.minutesBeforeEvent(let l), .minutesBeforeEvent(let r)):
			return l == r
		case (.hoursBeforeEvent(let l), .hoursBeforeEvent(let r)):
			return l == r
		case (.daysBeforeEvent(let l), .daysBeforeEvent(let r)):
			return l == r
		case (.weeksBeforeEvent(let l), .weeksBeforeEvent(let r)):
			return l == r
		default:
			return false
		}
	}
	
}

extension AlertTime: Comparable {
	static func <(lhs: AlertTime, rhs: AlertTime) -> Bool {
		return lhs.timeInterval < rhs.timeInterval
	}
}

extension TimeInterval {
	static var oneMinute: TimeInterval {
		return 60
	}
	
	static var oneHour: TimeInterval {
		return 3600
	}
	
	static var oneDay: TimeInterval {
		return 86400
	}
	
	static var oneWeek: TimeInterval {
		return 604800
	}
}
