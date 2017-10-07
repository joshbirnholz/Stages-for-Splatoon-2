//
//  ComplicationMode.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 9/10/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import Foundation

enum WatchScreen: RawRepresentable, CustomStringConvertible {

	private static let salmonRunRawValue = "salmonRun"
	
	var rawValue: String {
		switch self {
		case .battle(let mode):
			return mode.rawValue
		case .salmonRun:
			return WatchScreen.salmonRunRawValue
		}
	}
	
	typealias RawValue = String
	
	case battle(Mode)
	case salmonRun
	
	init?(rawValue: WatchScreen.RawValue) {
		if let mode = Mode(rawValue: rawValue) {
			self = .battle(mode)
		} else if rawValue == WatchScreen.salmonRunRawValue {
			self = .salmonRun
		} else {
			return nil
		}
	}
	
	var description: String {
		switch self {
		case .battle(let mode):
			return mode.description
		case .salmonRun:
			return "Salmon Run"
		}
	}
	
}
