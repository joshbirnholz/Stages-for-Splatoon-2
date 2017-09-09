//
//  UserDefaults+Group.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 9/9/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import Foundation

extension UserDefaults {
	
	static var group: UserDefaults {
		return UserDefaults(suiteName: "group.com.josh.birnholz.Splatoon-2-Stages")!
	}
	
}
