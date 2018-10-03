//
//  Festivals.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 11/14/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit

struct Festival: Codable {
	
	struct Names: Codable {
		var alphaShort: String
		var alphaLong: String
		var bravoShort: String
		var bravoLong: String
		
		private enum CodingKeys: String, CodingKey {
			case alphaShort = "alpha_short"
			case alphaLong = "alpha_long"
			case bravoShort = "bravo_short"
			case bravoLong = "bravo_long"
		}
	}
	
	struct Images: Codable {
		fileprivate let panel: URL
		fileprivate let alpha: URL
		fileprivate let bravo: URL
		
		lazy var panelImageID: String = panel.deletingPathExtension().lastPathComponent
		lazy var alphaImageID: String = alpha.deletingPathExtension().lastPathComponent
		lazy var bravoImageID: String = bravo.deletingPathExtension().lastPathComponent
	}
	
	struct Colors: Codable {
		struct TeamColor: Codable {
			fileprivate var r: CGFloat
			fileprivate var g: CGFloat
			fileprivate var b: CGFloat
			fileprivate var a: CGFloat
			
			var uiColor: UIColor {
				return UIColor(red: r, green: g, blue: b, alpha: a)
			}
		}
		
		var alpha: TeamColor
		var bravo: TeamColor
		var middle: TeamColor
	}
	
	struct Times: Codable {
		var start, end, result, announce: Date
	}
	
	var names: Names
	var images: Images
	var colors: Colors
	var festival_id: Int
	var times: Times
	
	var specialStage: BattleSchedule.Entry.Stage
	
}
//
//func getFestivals(session: URLSession = URLSession(configuration: .default), completion: @escaping (RunResult) -> ()) {
//	do {
//		let data = try Data(contentsOf: festivalsURL)
//		let runs = decodeRuns(fromSplatNetJSON: data)
//		
//		if runs.isValid {
//			print("Previous salmon run schedule was valid, using that one")
//			completion(.success(runs))
//			return
//		}
//	} catch {
//		print("Error decoding local salmon run data:", error.localizedDescription)
//	}
//	
//	print("Loading salmon run data from the Internet")
//	
//	session.dataTask(with: salmonRunStagesURL) { data, response, error in
//		guard let data = data, error == nil else {
//			completion(.failure(error!))
//			return
//		}
//		
//		let runs = decodeRuns(fromSplatNetJSON: data)
//		completion(.success(runs))
//		
//		do {
//			try data.write(to: runsURL)
//			print("Wrote salmon runs to ", runsURL)
//		} catch {
//			print("Error writing salmon run schedule:", error.localizedDescription)
//		}
//		}.resume()
//	
//}
