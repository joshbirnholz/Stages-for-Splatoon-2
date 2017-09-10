//
//  Runs.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 9/10/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import Foundation

struct Runs: Codable {
	struct Run: Codable {
		enum Status {
			case notStarted, open, ended
		}
		
		private var end: String
		
		var startTime: Date
		var endTime: Date {
			let endStr = end.replacingCharacters(in: end.index(end.startIndex, offsetBy: 8) ... end.index(end.startIndex, offsetBy: 9), with: "")
			let endDate = runDateFormatter.date(from: endStr)!
			var endComps = Calendar.current.dateComponents([.hour, .minute, .month, .day], from: endDate)
			let startComps = Calendar.current.dateComponents([.year, .month], from: startTime)
			endComps.year = startComps.year!
			if startComps.month == 12 && startComps.month == 1 {
				endComps.year! += 1
			}
			let endTime = Calendar.current.date(from: endComps)!
			return endTime
		}
		
		private enum CodingKeys: String, CodingKey {
			case startTime = "unix_start"
			case end
		}
		
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
}


enum RunResult {
	case failure(Error)
	case success(Runs)
}

fileprivate let runDateFormatter: DateFormatter = {
	let df = DateFormatter()
	df.dateFormat = "HH:mm dd MMMM"
	return df
}()

func getRuns(session: URLSession = URLSession(configuration: .default), completion: @escaping (RunResult) -> ()) {
	
	do {
		let data = try Data(contentsOf: runsURL)
		let runs = try decoder.decode(Runs.self, from: data)
		
		if runs.isValid {
			print("Previous salmon run schedule was valid, using that one")
			completion(.success(runs))
			return
		}
		
	} catch {
		print("Error reading salmon run data:", error.localizedDescription)
	}
	
	let timezoneOffset = -Calendar.current.timeZone.secondsFromGMT()/60
	let stagesURL = URL(string: "http://splatooniverse.com/ajax/get-salmon.php?timezone=\(timezoneOffset)")!
	
	session.dataTask(with: stagesURL) { data, response, error in
		guard let data = data, error == nil else {
			completion(.failure(error!))
			return
		}
		
		do {
			let runs = try decoder.decode(Runs.self, from: data)
			completion(.success(runs))
		} catch {
			completion(.failure(error))
		}
		
		do {
			try data.write(to: runsURL)
			print("Wrote salmon runs to ", runsURL)
		} catch let error {
			print("Error writing salmon run schedule:", error.localizedDescription)
		}
		}.resume()
}
