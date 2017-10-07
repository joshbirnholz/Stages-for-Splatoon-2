//
//  ArrayURLQueryItem+Dictionary.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 9/18/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import Foundation

extension Array where Element == URLQueryItem {
	
	var dictionary: [String: String] {
		var d: [String: String] = [:]
		for item in self {
			d[item.name] = item.value
		}
		return d
	}
	
}
