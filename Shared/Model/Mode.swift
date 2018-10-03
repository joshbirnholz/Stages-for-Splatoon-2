//
//  Mode.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 9/10/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit

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
	
	var shortDescription: String {
		switch self {
		case .league: return "League"
		case .ranked: return "Ranked"
		case .regular: return "Regular"
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
	
	var shortcutIcon: UIImage {
		switch self {
		case .league: return #imageLiteral(resourceName: "League Battle Shortcut")
		case .ranked: return #imageLiteral(resourceName: "Ranked Battle Shortcut")
		case .regular: return #imageLiteral(resourceName: "Regular Battle Shortcut")
		}
	}
}

@available(iOS 12.0, *)
@available(watchOSApplicationExtension 5.0, *)
@available(iOSApplicationExtension 12.0, *)
extension ViewBattleScheduleBattleMode {
	var nativeMode: Mode? {
		switch self {
		case .gachi:
			return .ranked
		case .league:
			return .league
		case .regular:
			return .regular
		case .unknown:
			return nil
		}
	}
	
	init(nativeMode mode: Mode?) {
		if let mode = mode {
			switch mode {
			case .regular:
				self = .regular
			case .ranked:
				self = .gachi
			case .league:
				self = .league
			}
		} else {
			self = .unknown
		}
	}
}
