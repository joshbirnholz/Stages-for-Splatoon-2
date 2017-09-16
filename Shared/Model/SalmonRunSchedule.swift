//
//  Runs.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 9/10/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import Foundation

struct SalmonRunSchedule: Codable {
	struct Run: Codable {
		enum Status {
			case notStarted, open, ended
		}
		
		var startTime: Date
		var endTime: Date
		
		var status: Status {
			let now = Date()
			if endTime < now {
				return .ended
			} else if startTime > now {
				return .notStarted
			} else {
				return .open
			}
		}
	}
	var runs: [Run]
	
	var isValid: Bool {
		guard let first = runs.first else {
			return false
		}
		
		return first.status == .open || first.endTime < Date()
	}
	
	mutating func removeExpiredRuns() {
		let now = Date()
		runs = runs.filter { $0.endTime > now }
	}
	
	mutating func sort() {
		runs.sort { $0.startTime < $1.startTime }
	}
	
	func badgeText(forRowAt index: Int) -> String? {
		if runs[index].status == .open {
			return "Open!"
		}
		
		if index == 0 {
			return "Next"
		}
		
		let previous = index - 1
		if previous >= 0 && runs[previous].status == .open {
			return "Next"
		}
		
		return nil
	}
}


enum RunResult {
	case failure(Error)
	case success(SalmonRunSchedule)
	
	var validSchedule: SalmonRunSchedule? {
		switch self {
		case .success(var schedule) where schedule.isValid:
			schedule.removeExpiredRuns()
			schedule.sort()
			return schedule
		default:
			return nil
		}
	}
}

fileprivate let runDateFormatter: DateFormatter = {
	let df = DateFormatter()
	df.dateFormat = "yyyyLLdd'T'HHmmssZ"
	return df
}()

fileprivate func parseRunSchedule(fromICSString str: String) -> SalmonRunSchedule {
	var runs: [SalmonRunSchedule.Run] = []
	let separator = "•"
	let events = str.replacingOccurrences(of: "\r", with: "").replacingOccurrences(of: "BEGIN:VEVENT", with: separator).split(separator: Character(separator))
	for eventStr in events {
		let dict: [String: String] = {
			var d: [String: String] = [:]
			for line in eventStr.split(separator: "\n") {
				let info = line.split(separator: ":")
				guard info.count == 2 else {
					continue
				}
				let key = String(info[0])
				let value = String(info[1])
				d[key] = value
			}
			return d
		}()
		
		if let startDateStr = dict["DTSTART"],
			let endDateStr = dict["DTEND"],
			let startDate = runDateFormatter.date(from: startDateStr),
			let endDate = runDateFormatter.date(from: endDateStr) {
			print(startDate)
			print(endDate)
			
			let run = SalmonRunSchedule.Run(startTime: startDate, endTime: endDate)
			runs.append(run)
		}
		
	}
	
	return SalmonRunSchedule(runs: runs)
}

enum RunReadError: Error {
	case incorrectFormat
}

func getRuns(session: URLSession = URLSession(configuration: .default), completion: @escaping (RunResult) -> ()) {
	
	do {
		let str = try String.init(contentsOf: runsURL)
		let runs = parseRunSchedule(fromICSString: str)
		
		if runs.isValid {
			print("Previous salmon run schedule was valid, using that one")
			completion(.success(runs))
			return
		}
		
	} catch {
		print("Error reading salmon run data:", error.localizedDescription)
	}
	
	let stagesURL = URL(string: "https://calendar.google.com/calendar/ical/7e5g474p0ng7vaejkg3mkomhks%40group.calendar.google.com/public/basic.ics")!
	
	session.dataTask(with: stagesURL) { data, response, error in
		guard let data = data, error == nil else {
			completion(.failure(error!))
			return
		}
		
		guard let str = String(data: data, encoding: .utf8) else {
			completion(.failure(RunReadError.incorrectFormat))
			return
		}
		
		let runs = parseRunSchedule(fromICSString: str)
		completion(.success(runs))
		
		do {
			try data.write(to: runsURL)
			print("Wrote salmon runs to ", runsURL)
		} catch let error {
			print("Error writing salmon run schedule:", error.localizedDescription)
		}
		}.resume()
}
