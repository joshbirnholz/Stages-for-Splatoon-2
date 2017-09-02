//
//  ExtensionDelegate.swift
//  Stages Watch Extension
//
//  Created by Josh Birnholz on 8/30/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import WatchKit

var schedule: Schedule?

func reloadControllers(mode: Mode) {
	DispatchQueue.main.async {
		guard let schedule = schedule else {
			WKInterfaceController.reloadRootControllers(withNames: ["Initial"], contexts: nil)
			return
		}
		
		let names = Array(repeating: "Stages", count: min(4, schedule[mode].count))
		
		if #available(watchOSApplicationExtension 4.0, *) {
			WKInterfaceController.reloadRootPageControllers(withNames: names,
			                                                contexts: Array(schedule[mode].prefix(names.count)),
			                                                orientation: .vertical,
			                                                pageIndex: 0)
		} else {
			WKInterfaceController.reloadRootControllers(withNames: names, contexts: schedule[mode])
		}
	}
}

var selectedMode: Mode {
	set {
		UserDefaults.standard.set(newValue.rawValue, forKey: "selectedMode")
		reloadControllers(mode: newValue)
	}
	get {
		guard let str = UserDefaults.standard.string(forKey: "selectedMode") else {
			return .regular
		}
		return Mode(rawValue: str) ?? .regular
	}
}

weak var initialInterfaceController: InitialInterfaceController?

class ExtensionDelegate: NSObject, WKExtensionDelegate {
	
	func applicationDidFinishLaunching() {
		// Perform any final initialization of your application.
		
		loadSchedule()
		
	}
	
	func loadSchedule() {
		getSchedule { (result) in
			switch result {
			case .failure(let error):
				let okAction = WKAlertAction(title: "OK", style: .default) { }
				DispatchQueue.main.async {
					print(error)
					initialInterfaceController?.presentAlert(withTitle: "An error occurred loading stages.", message: error.localizedDescription, preferredStyle: WKAlertControllerStyle.alert, actions: [okAction])
					initialInterfaceController?.label.setText("No Data")
					initialInterfaceController?.retryButton.setEnabled(true)
					initialInterfaceController?.label.setHidden(false)
					initialInterfaceController?.retryButton.setHidden(false)
					initialInterfaceController?.buttonAction = self.loadSchedule
				}
			case .success(let sch):
				schedule = sch
				reloadControllers(mode: selectedMode)
			}
		}
	}
	
	func applicationDidBecomeActive() {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}
	
	func applicationWillResignActive() {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, etc.
	}
	
	func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
		// Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
		for task in backgroundTasks {
			// Use a switch statement to check the task type
			switch task {
			case let backgroundTask as WKApplicationRefreshBackgroundTask:
				// Be sure to complete the background task once you’re done.
				if #available(watchOSApplicationExtension 4.0, *) {
					backgroundTask.setTaskCompletedWithSnapshot(false)
				} else {
					backgroundTask.setTaskCompleted()
				}
			case let snapshotTask as WKSnapshotRefreshBackgroundTask:
				// Snapshot tasks have a unique completion call, make sure to set your expiration date
				snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
			case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
				// Be sure to complete the connectivity task once you’re done.
				if #available(watchOSApplicationExtension 4.0, *) {
					connectivityTask.setTaskCompletedWithSnapshot(false)
				} else {
					connectivityTask.setTaskCompleted()
				}
			case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
				// Be sure to complete the URL session task once you’re done.
				if #available(watchOSApplicationExtension 4.0, *) {
					urlSessionTask.setTaskCompletedWithSnapshot(false)
				} else {
					urlSessionTask.setTaskCompleted()
				}
			default:
				// make sure to complete unhandled task types
				if #available(watchOSApplicationExtension 4.0, *) {
					task.setTaskCompletedWithSnapshot(false)
				} else {
					task.setTaskCompleted()
				}
			}
		}
	}
	
}
