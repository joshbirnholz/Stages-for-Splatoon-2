//
//  IntentViewController.swift
//  ViewSalmonRunScheduleIntentsUIExtension
//
//  Created by Josh Birnholz on 6/6/18.
//  Copyright © 2018 Joshua Birnholz. All rights reserved.
//

import IntentsUI

// As an example, this extension's Info.plist has been configured to handle interactions for INSendMessageIntent.
// You will want to replace this or add other intents as appropriate.
// The intents whose interactions you wish to handle must be declared in the extension's Info.plist.

// You can test this example integration by saying things to Siri like:
// "Send a message using <myApp>"

class SalmonRunWidgetTableViewController: SalmonRunWidgetTableViewControllerBase, INUIHostedViewControlling {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
        
    // MARK: - INUIHostedViewControlling
    
    // Prepare your view controller for the interaction to handle.
    func configureView(for parameters: Set<INParameter>, of interaction: INInteraction, interactiveBehavior: INUIInteractiveBehavior, context: INUIHostedViewContext, completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {
        // Do configuration here, including preparing views and calculating a desired size for presentation.
		
		getRuns { (result) in
			switch result {
			case .failure(let error):
				print("Error getting runs:", error.localizedDescription)
				completion(false, Set(), .zero)
			case .success(var r):
				r.removeExpiredShifts()
				r.sort()
				self.runSchedule = r
				DispatchQueue.main.async {
					self.tableView.reloadData()
					self.updateNoDataLabel()
					
					completion(true, parameters, self.desiredSize)
				}
			}
		}
		
    }
	
	var desiredSize: CGSize {
		let width = self.extensionContext!.hostedViewMaximumAllowedSize.width
		let height: CGFloat = Array((0 ..< tableView.numberOfRows(inSection: 0))).reduce(0) { result, row in
			return result + self.tableView(tableView, heightForRowAt: IndexPath(row: row, section: 0))
		}
		let size = CGSize(width: width, height: height)
		
		if size.height > self.extensionContext!.hostedViewMaximumAllowedSize.height {
			return self.extensionContext!.hostedViewMaximumAllowedSize
		} else {
			return size
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let width = self.extensionContext!.hostedViewMaximumAllowedSize.width
		return width / 16 * 9 / 2
	}
    
}
