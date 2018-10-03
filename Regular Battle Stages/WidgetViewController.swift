//
//  RegularWidgetViewController.swift
//  Salmon Run Schedule
//
//  Created by Josh Birnholz on 8/29/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit

class WidgetViewController: WidgetStagesViewController {
	override var mode: Mode! {
		return .regular
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return extensionContext?.widgetMaximumSize(for: .compact).height ?? 44
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard !entries.isEmpty else {
			extensionContext?.widgetLargestAvailableDisplayMode = .compact
			return 0
		}
		
		if entries.count >= 2 {
			extensionContext?.widgetLargestAvailableDisplayMode = .expanded
		} else {
			extensionContext?.widgetLargestAvailableDisplayMode = .compact
		}
		
		return min(2, entries.count)
	}
}
