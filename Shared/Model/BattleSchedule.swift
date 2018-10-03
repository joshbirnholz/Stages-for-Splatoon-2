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
public let runsURL = documentDirectory.appendingPathComponent("coop-schedules.json")
public let scheduleURL = documentDirectory.appendingPathComponent("schedules.json")
public let festivalsURL = documentDirectory.appendingPathComponent("festivals.json")

let dateFormatter: DateFormatter = {
	let df = DateFormatter()
	df.setLocalizedDateFormatFromTemplate("Mdhmma")
	return df
}()

struct BattleSchedule: Codable {
	
	private static let encoder: JSONEncoder = {
		let e = JSONEncoder()
		e.dateEncodingStrategy = .secondsSince1970
		return e
	}()
	
	static let downloadURL = URL(string: "https://splatoon2.ink/data/schedules.json")!
	
	struct Entry: Codable {
		
		var startTime: Date
		
		struct GameMode: Codable {
			var name: String
			var key: String
		}
		
		var gameMode: GameMode
		var endTime: Date
		
		struct Stage: Codable {
			var name: String
			fileprivate var image: URL
			
			lazy var imageID: String = image.deletingPathExtension().lastPathComponent
			
			init(name: String) {
				self.name = name
				image = URL(string: "file://")!
			}
		}
		
		var stageA: Stage
		var stageB: Stage
		
		struct Rule: Codable {
			var key: String
			var name: String
			
			private enum CodingKeys: String, CodingKey {
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
		let firstEntries = [leagueEntries.first, regularEntries.first, rankedEntries.first].compactMap { $0 }
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
	case success(BattleSchedule)
	case failure(Error)
	
	var validSchedule: BattleSchedule? {
		switch self {
		case .success(var schedule) where schedule.isValid:
			schedule.removeExpiredEntries()
			return schedule
		default:
			return nil
		}
	}
}

func getScheduleFinished(data: Data?, response: URLResponse?, error: Error?, completion: @escaping (ScheduleResult) -> ()) {
	guard let data = data, error == nil else {
		completion(.failure(error!))
		return
	}
	
	do {
		var schedule = try decoder.decode(BattleSchedule.self, from: data)
		schedule.removeExpiredEntries()
		
		completion(.success(schedule))
	} catch {
		completion(.failure(error))
	}
	
	do {
		try data.write(to: scheduleURL)
		print("Wrote schedule to ", scheduleURL)
	} catch {
		print("Error writing schedule:", error.localizedDescription)
	}
}

func getSchedule(session: URLSession = .shared, completion: @escaping (ScheduleResult) -> ()) {
	
	do {
		let data = try Data(contentsOf: scheduleURL)
		let schedule = try decoder.decode(BattleSchedule.self, from: data)
		
		if schedule.isValid {
			print("Previous schedule was valid, using that one")
			completion(.success(schedule))
			return
		}
		
	} catch {
		print("Error reading schedule data:", error.localizedDescription)
	}
	
	print("Downloading updated schedule")
	
	session.dataTask(with: BattleSchedule.downloadURL) { data, response, error in
		getScheduleFinished(data: data, response: response, error: error, completion: completion)
	}.resume()
}


