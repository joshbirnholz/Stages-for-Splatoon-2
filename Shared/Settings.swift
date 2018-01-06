//
//  Settings.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 11/1/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import Foundation

private let appSettings: [String: Any] = {
	guard let appSettingsURL = Bundle.main.url(forResource: "App Settings", withExtension: "plist") else {
		return [:]
	}
	
	return NSDictionary(contentsOf: appSettingsURL) as? [String: Any] ?? [:]
	
}()

public func registerAppSettings(to defaults: UserDefaults = .standard) {
	defaults.register(defaults: appSettings)
}
