//
//  Runs.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 9/10/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import Foundation

fileprivate let salmonRunStagesURL = URL(string: "https://splatoon2.ink/data/coop-schedules.json")!

struct SalmonRunSchedule: Codable {
    struct Shift: Codable {
		
        struct Weapon: Codable {
            var name: String
            var special: String?
            var sub: String?
			var imageID: String
			
			var isGrizzcoRandom: Bool
        }
		
		struct Stage: Codable {
			var name: String
			var imageID: String
		}
        
        enum Status {
            case notStarted, open, ended
        }
        
        var startTime: Date
        var endTime: Date
        
		var stage: Stage?
        var weapons: [Weapon?]
        
        var currentStatus: Status {
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
    var shifts: [Shift]
    
    var isValid: Bool {
        var temp = self
        temp.sort()
        
        guard let first = temp.shifts.first else {
            return false
        }
        
        return first.currentStatus == .open || first.currentStatus == .notStarted
    }
    
    mutating func removeExpiredShifts() {
        let now = Date()
        shifts = shifts.filter { $0.endTime > now }
    }
    
    mutating func sort() {
        shifts.sort { $0.startTime < $1.startTime }
    }
    
    func badgeText(forRowAt index: Int) -> String? {
        if shifts[index].currentStatus == .open {
            return "Open!"
        }
        
        if index == 0 {
            return "Next"
        }
        
        let previous = index - 1
        if previous >= 0 && shifts[previous].currentStatus == .open {
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
            schedule.removeExpiredShifts()
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

fileprivate struct SplatNetSalmonRunSchedule: Codable {
    
    struct Schedule: Codable {
        var startTime: Date
        var endTime: Date
        
        private enum CodingKeys: String, CodingKey {
            case startTime = "start_time"
            case endTime = "end_time"
        }
    }
    
    struct Detail: Codable {
		struct WeaponItem: Codable {
			struct Weapon: Codable {
				struct Special: Codable {
					var name: String
				}
				struct Sub: Codable {
					var name: String
				}
				
				var name: String
				var special: Special?
				var sub: Sub?
				var image: URL
			}
			
			var weapon: Weapon?
			var id: String
		}
        
        struct Stage: Codable {
            var name: String
			var image: URL
        }
        
        var weapons: [WeaponItem?]
        var startTime: Date
        var endTime: Date
        var stage: Stage
        
        private enum CodingKeys: String, CodingKey {
            case startTime = "start_time"
            case endTime = "end_time"
            case weapons
            case stage
        }
    }
    
    var schedules: [Schedule]
    var details: [Detail]
    
}

fileprivate func decodeRuns(fromSplatNetJSON json: Data) -> SalmonRunSchedule {
    
    do {
        let splatNetSchedule = try decoder.decode(SplatNetSalmonRunSchedule.self, from: json)
        
        var runs: [SalmonRunSchedule.Shift] = splatNetSchedule.schedules.map { scheduledRun in
			return SalmonRunSchedule.Shift(startTime: scheduledRun.startTime,
										 endTime: scheduledRun.endTime,
										 stage: nil,
										 weapons: [])
        }
        
        for detailedRun in splatNetSchedule.details {
			
			let weapons: [SalmonRunSchedule.Shift.Weapon?] = detailedRun.weapons.compactMap { weaponItem in
				
				guard let weaponItem = weaponItem else {
					return nil
				}
				
				if weaponItem.id == "-2" {
					return SalmonRunSchedule.Shift.Weapon(name: "Random",
														  special: nil,
														  sub: nil,
														  imageID: "7076c8181ab5c49d2ac91e43a2d945a46a99c17d",
														  isGrizzcoRandom: true)
				}
				
				guard let weapon = weaponItem.weapon else {
					return nil
				}
				
				return SalmonRunSchedule.Shift.Weapon(name: weapon.name,
													  special: weapon.special?.name,
													  sub: weapon.sub?.name,
													  imageID: weapon.image.deletingPathExtension().lastPathComponent,
													  isGrizzcoRandom: false)
			}
			
			let stage = SalmonRunSchedule.Shift.Stage(name: detailedRun.stage.name, imageID: detailedRun.stage.image.deletingPathExtension().lastPathComponent)
			
			let run = SalmonRunSchedule.Shift(startTime: detailedRun.startTime,
											endTime: detailedRun.endTime,
											stage: stage,
											weapons: weapons)
            
            if let index = runs.index(where: { $0.startTime == run.startTime && $0.endTime == run.endTime }) {
                runs[index] = run
            } else {
                runs.insert(run, at: 0)
            }
        }
        
        return SalmonRunSchedule(shifts: runs)
        
	} catch let error as DecodingError {
		print("Error decoding SplatNet coop JSON:", error.localizedDescription)
		return SalmonRunSchedule(shifts: [])
	} catch {
		print("Error decoding SplatNet coop JSON:", error.localizedDescription)
		return SalmonRunSchedule(shifts: [])
	}
    
}

enum RunReadError: Error {
    case incorrectFormat
}

func getRuns(session: URLSession = URLSession(configuration: .default), completion: @escaping (RunResult) -> ()) {
    do {
        let data = try Data(contentsOf: runsURL)
        let runs = decodeRuns(fromSplatNetJSON: data)
        
        if runs.isValid {
            print("Previous salmon run schedule was valid, using that one")
            completion(.success(runs))
            return
        }
    } catch {
		print("Error decoding local salmon run data:", error.localizedDescription)
	}
	
	print("Loading salmon run data from the Internet")
    
    session.dataTask(with: salmonRunStagesURL) { data, response, error in
		guard let data = data, error == nil else {
			completion(.failure(error!))
			return
		}
		
		let runs = decodeRuns(fromSplatNetJSON: data)
		completion(.success(runs))
		
		do {
			try data.write(to: runsURL)
			print("Wrote salmon runs to ", runsURL)
		} catch {
			print("Error writing salmon run schedule:", error.localizedDescription)
		}
	}.resume()
	
}

//func getRuns(session: URLSession = URLSession(configuration: .default), completion: @escaping (RunResult) -> ()) {
//
//    do {
//        let str = try String.init(contentsOf: runsURL)
//        let runs = parseRunSchedule(fromICSString: str)
//
//        if runs.isValid {
//            print("Previous salmon run schedule was valid, using that one")
//            completion(.success(runs))
//            return
//        }
//
//    } catch {
//        print("Error reading salmon run data:", error.localizedDescription)
//    }
//
//    let stagesURL = URL(string: "https://calendar.google.com/calendar/ical/7e5g474p0ng7vaejkg3mkomhks%40group.calendar.google.com/public/basic.ics")!
//
//    session.dataTask(with: stagesURL) { data, response, error in
//        guard let data = data, error == nil else {
//            completion(.failure(error!))
//            return
//        }
//
//        guard let str = String(data: data, encoding: .utf8) else {
//            completion(.failure(RunReadError.incorrectFormat))
//            return
//        }
//
//        let runs = parseRunSchedule(fromICSString: str)
//        completion(.success(runs))
//
//        do {
//            try data.write(to: runsURL)
//            print("Wrote salmon runs to ", runsURL)
//        } catch let error {
//            print("Error writing salmon run schedule:", error.localizedDescription)
//        }
//        }.resume()
//}

