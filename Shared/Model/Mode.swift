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
