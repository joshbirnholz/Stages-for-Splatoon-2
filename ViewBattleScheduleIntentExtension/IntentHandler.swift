//
//  IntentHandler.swift
//  ViewBattleScheduleIntentExtension
//
//  Created by Josh Birnholz on 6/5/18.
//  Copyright © 2018 Joshua Birnholz. All rights reserved.
//

import Intents

fileprivate let shortTimeFormatter: DateFormatter = {
	let df = DateFormatter()
	df.dateStyle = .none
	df.timeStyle = .short
	return df
}()

fileprivate let shortDateFormatter: DateFormatter = {
	let df = DateFormatter()
	df.locale = Locale.current
	df.setLocalizedDateFormatFromTemplate("MMMMd")
	
	return df
}()

fileprivate let relativeDateFormatter: DateFormatter = {
	let df = DateFormatter()
	df.timeStyle = .none
	df.dateStyle = .short
	df.doesRelativeDateFormatting = true
	return df
}()

fileprivate let numbers: [Character] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

func shortDateTime(for date: Date) -> String {
	var str = shortTimeFormatter.string(from: date)
	
	let isToday: Bool = {
		let todayComponents = Calendar.current.dateComponents([.day, .month, .year], from: Date())
		let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: date)
		
		return todayComponents == dateComponents
	}()
	
	if isToday {
		return str
	}
	
	let dateString = shortDateFormatter.string(from: date)
	let relativeDateString = relativeDateFormatter.string(from: date)
	
	if relativeDateString.contains(where: { numbers.contains($0) }) {
		str += " on " + dateString
	} else {
		str += " " + relativeDateString.lowercased()
	}
	
	return str
}

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
		switch intent {
		case is ViewBattleScheduleIntent:
			return ViewBattleScheduleIntentHandler()
		case is ViewSalmonRunScheduleIntent:
			return ViewSalmonRunScheduleIntentHandler()
		default:
			fatalError("Unhandled Intent type")
		}
    }
    
}

class ViewSalmonRunScheduleIntentHandler: NSObject, ViewSalmonRunScheduleIntentHandling {
	func handle(intent: ViewSalmonRunScheduleIntent, completion: @escaping (ViewSalmonRunScheduleIntentResponse) -> Void) {
		getRuns { (result) in
			switch result {
			case .failure(let error):
				print("Error getting runs:", error.localizedDescription)
				let response = ViewSalmonRunScheduleIntentResponse(code: .failureRequiringAppLaunch, userActivity: nil)
				completion(response)
			case .success(var r):
				r.removeExpiredShifts()
				r.sort()
				
				guard !r.shifts.isEmpty else {
					let response = ViewSalmonRunScheduleIntentResponse(code: .failureRequiringAppLaunch, userActivity: nil)
					completion(response)
					return
				}
				
				let shift = r.shifts.first!
				
				let nextString: String = {
					guard r.shifts.count > 1 else {
						return ""
					}
					
					let nextShift = r.shifts[1]
					
					let startTime = shortDateTime(for: nextShift.startTime)
					if let stageName = nextShift.stage?.name {
						return "\n\nThe next shift is on \(stageName) and starts at \(startTime)."
					} else {
						return "\n\nThe next shift starts at \(startTime)."
					}
				}()
				
				let startTime = shortDateTime(for: shift.startTime)
				let endTime = shortDateTime(for: shift.endTime)
				
				switch shift.currentStatus {
				case .notStarted:
					if let name = shift.stage?.name {
						let response = ViewSalmonRunScheduleIntentResponse.successNotStarted(stageName: name, startTime: startTime, endTime: endTime)
						completion(response)
					} else {
						let response = ViewSalmonRunScheduleIntentResponse.successNotStartedNoName(startTime: startTime, endTime: endTime)
						completion(response)
					}
				case .open:
					if let name = shift.stage?.name {
						let response = ViewSalmonRunScheduleIntentResponse.successOpen(stageName: name, endTime: endTime, nextString: nextString)
						completion(response)
					} else {
						let response = ViewSalmonRunScheduleIntentResponse.successOpenNoName(endTime: endTime, nextString: nextString)
						completion(response)
					}
				case .ended:
					let response = ViewSalmonRunScheduleIntentResponse(code: .failureRequiringAppLaunch, userActivity: nil)
					completion(response)
				}
				
			}
		}
	}
}

class ViewBattleScheduleIntentHandler: NSObject, ViewBattleScheduleIntentHandling {
	func handle(intent: ViewBattleScheduleIntent, completion: @escaping (ViewBattleScheduleIntentResponse) -> Void) {
		
		getSchedule { result in
			switch result {
			case .success(var schedule):
				schedule.removeExpiredEntries()
				
				if let mode = intent.mode.nativeMode, let currentEntry = schedule[mode].first {
					// Specific mode
					
					let response = ViewBattleScheduleIntentResponse.success(mode: mode.description,
																			rule: currentEntry.rule.name,
																			stageNames: "\(currentEntry.stageA.name) and \(currentEntry.stageB.name)",
																			endTime: shortTimeFormatter.string(from: currentEntry.endTime))
					completion(response)
				} else {
					// Current stages overview
					let entries = ([schedule[.ranked].first] + [schedule[.league].first]).compactMap { $0 }
					
					guard !entries.isEmpty else {
						let response = ViewBattleScheduleIntentResponse(code: .failureRequiringAppLaunch, userActivity: nil)
						completion(response)
						return
					}
					
					var overview = "Until \(shortTimeFormatter.string(from: entries.first!.endTime)), "
					var firstAdded = false
					
					if let entry = schedule[.regular].first {
						overview += "the \(entry.rule.name) stages are \(entry.stageA.name) and \(entry.stageB.name)."
						
						firstAdded = true
					}
					
					for (index, entry) in entries.enumerated() {
						let isLast = index == entries.count - 1
						
						if firstAdded {
							overview += "\n\n"
							
							if isLast {
								overview += "And f"
							} else {
								overview += "F"
							}
						} else {
							overview += "f"
						}
						
						overview += "or \(entry.gameMode.name), you can play \(entry.rule.name) on \(entry.stageA.name) and \(entry.stageB.name)."
						
						firstAdded = true
					}
					
					let response = ViewBattleScheduleIntentResponse.overview(overview: overview)
					completion(response)
				}
			case .failure:
				let response = ViewBattleScheduleIntentResponse(code: .failureRequiringAppLaunch, userActivity: nil)
				completion(response)
			}
		}
		
	}
}
