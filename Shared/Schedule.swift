//
//  Schedule.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 8/27/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit

public let decoder: JSONDecoder = {
	let d = JSONDecoder()
	d.dateDecodingStrategy = .secondsSince1970
	return d
}()
//public let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
public let documentDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.josh.birnholz.Splatoon-2-Stages")!
public let runsURL = documentDirectory.appendingPathComponent("salmonruns.json")
public let scheduleURL = documentDirectory.appendingPathComponent("schedule.json")

let dateFormatter: DateFormatter = {
	let df = DateFormatter()
	df.setLocalizedDateFormatFromTemplate("Mdhmma")
	return df
}()

struct Schedule: Codable {
	
	static let downloadURL = URL(string: "http://squidkidsfeed.azurewebsites.net/Schedule.json")!
	
	struct Entry: Codable {
		
		var startTime: Date
		var id: Int64
		
		struct GameMode: Codable {
			var name: String
			var key: String
		}
		
		var gameMode: GameMode
		var endTime: Date
		
		struct Stage: Codable {
			var id: String
			var name: String
			var image: String
		}
		
		var stageA: Stage
		var stageB: Stage
		
		struct Rule: Codable {
			var multilineName: String
			var key: String
			var name: String
			
			private enum CodingKeys: String, CodingKey {
				case multilineName = "multiline_name"
				case key
				case name
			}
		}
		
		var rule: Rule
		
		var isCurrent: Bool {
			let now = Date()
			return startTime < now && endTime > now
		}
		
		private enum CodingKeys: String, CodingKey {
			case startTime = "start_time"
			case id
			case gameMode = "game_mode"
			case endTime = "end_time"
			case stageA = "stage_a"
			case stageB = "stage_b"
			case rule
		}
		
	}
	
	var leagueEntries: [Entry]
	var regularEntries: [Entry]
	var rankedEntries: [Entry]

	private enum CodingKeys: String, CodingKey {
		case leagueEntries = "league"
		case regularEntries = "regular"
		case rankedEntries = "gachi"
	}
	
	subscript (_ mode: Mode) -> [Entry] {
		switch mode {
		case .regular:
			return regularEntries
		case .league:
			return leagueEntries
		case .ranked:
			return rankedEntries
		}
	}
	
	var isValid: Bool {
		let firstEntries = [leagueEntries.first, regularEntries.first, rankedEntries.first].flatMap { $0 }
		guard !firstEntries.isEmpty else {
			return false
		}
		
		let now = Date()
		
		for entry in firstEntries {
			if entry.endTime < now {
				return false
			}
		}
		
		return true
	}
	
	mutating func removeExpiredEntries() {
		let now = Date()
		func isIncluded(entry: Entry) -> Bool {
			return entry.endTime > now
		}
		
		regularEntries = regularEntries.filter(isIncluded)
		rankedEntries = rankedEntries.filter(isIncluded)
		leagueEntries = leagueEntries.filter(isIncluded)
	}
}

enum ScheduleResult {
	case success(Schedule)
	case failure(Error)
}

enum Mode: String, CustomStringConvertible {
	case regular, ranked = "gachi", league
	
	var color: UIColor {
		switch self {
		case .regular: return #colorLiteral(red: 0.1253578663, green: 0.9081364274, blue: 0.08959365636, alpha: 1)
		case .ranked: return #colorLiteral(red: 0.9625250697, green: 0.3669919372, blue: 0.1715939343, alpha: 1)
		case .league: return #colorLiteral(red: 0.9654037356, green: 0.144708246, blue: 0.7567376494, alpha: 1)
		}
	}
	
	var description: String {
		switch self {
		case .league: return "League Battle"
		case .ranked: return "Ranked Battle"
		case .regular: return "Regular Battle"
		}
	}
	
	var icon: UIImage {
		switch self {
		case .league: return #imageLiteral(resourceName: "League Battle")
		case .ranked: return #imageLiteral(resourceName: "Ranked Battle")
		case .regular: return #imageLiteral(resourceName: "Regular Battle")
		}
	}
	
	var tabBarIcon: UIImage {
		switch self {
		case .league: return #imageLiteral(resourceName: "League Battle Tab")
		case .ranked: return #imageLiteral(resourceName: "Ranked Battle Tab")
		case .regular: return #imageLiteral(resourceName: "Regular Battle Tab")
		}
	}
	
	var selectedTabBarIcon: UIImage {
		switch self {
		case .league: return #imageLiteral(resourceName: "League Battle Tab Selected")
		case .ranked: return #imageLiteral(resourceName: "Ranked Battle Tab Selected")
		case .regular: return #imageLiteral(resourceName: "Regular Battle Tab").withRenderingMode(.alwaysOriginal)
		}
	}
}

func getScheduleFinished(data: Data?, response: URLResponse?, error: Error?, completion: @escaping (ScheduleResult) -> ()) {
	guard let data = data, error == nil else {
		completion(.failure(error!))
		return
	}
	
	do {
		let schedule = try decoder.decode(Schedule.self, from: data)
		completion(.success(schedule))
	} catch {
		completion(.failure(error))
	}
	
	do {
		try data.write(to: scheduleURL)
		print("Wrote schedule to ", scheduleURL)
	} catch let error {
		print("Error writing schedule:", error.localizedDescription)
	}
}

func getSchedule(session: URLSession = URLSession(configuration: .default), completion: @escaping (ScheduleResult) -> ()) {
	
	do {
		let data = try Data(contentsOf: scheduleURL)
		let schedule = try decoder.decode(Schedule.self, from: data)
		
		if schedule.isValid {
			print("Previous schedule was valid, using that one")
			completion(.success(schedule))
			return
		}
		
	} catch {
		print("Error reading schedule data:", error.localizedDescription)
	}
	
	print("Downloading updated schedule")
	
	session.dataTask(with: Schedule.downloadURL) { data, response, error in
		getScheduleFinished(data: data, response: response, error: error, completion: completion)
	}.resume()
}

struct Runs: Codable {
	struct Run: Codable {
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
		
		var isOpen: Bool {
			let now = Date()
			return startTime < now && endTime > now
		}
	}
	var runs: [Run]
	
	var isValid: Bool {
		guard let first = runs.first else {
			return false
		}
		
		return first.isOpen || first.endTime < Date()
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
