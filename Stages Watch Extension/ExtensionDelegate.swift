 //
//  ExtensionDelegate.swift
//  Stages Watch Extension
//
//  Created by Josh Birnholz on 8/30/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import WatchKit
//import WatchConnectivity

var battleSchedule: BattleSchedule?
var runSchedule: SalmonRunSchedule?

var timer: Timer? {
	willSet {
		timer?.invalidate()
	}
}

func reloadControllers(mode: AppSection) {
	switch mode {
	case .battle(let mode):
		DispatchQueue.main.async {
			guard var schedule = battleSchedule else {
				WKInterfaceController.reloadRootControllers(withNames: ["Initial"], contexts: nil)
				return
			}
			
			schedule.removeExpiredEntries()
			
			let fullPageCount = schedule[mode].count
			
			var names = Array(repeating: "Stages", count: min(fullPageCount, schedule[mode].count))
			let contexts: [Any] = Array(schedule[mode].prefix(names.count))
			
			if schedule[mode].count > fullPageCount {
				names.append("ViewFull")
			}
			
			if #available(watchOSApplicationExtension 4.0, *) {
				WKInterfaceController.reloadRootPageControllers(withNames: names,
				                                                contexts: contexts,
				                                                orientation: .vertical,
				                                                pageIndex: 0)
			} else {
				WKInterfaceController.reloadRootControllers(withNames: names, contexts: contexts)
			}
		}
	case .salmonRun:
		guard var schedule = runSchedule else {
			WKInterfaceController.reloadRootControllers(withNames: ["Initial"], contexts: nil)
			return
		}
		
		schedule.removeExpiredShifts()
		schedule.sort()
		
		WKInterfaceController.reloadRootControllers(withNames: ["SalmonRun"], contexts: nil)
	}
	
	
}

var selectedMode: AppSection {
	set {
		UserDefaults.standard.set(newValue.rawValue, forKey: "selectedMode")
		reloadControllers(mode: newValue)
	}
	get {
		guard let str = UserDefaults.standard.string(forKey: "selectedMode") else {
			return .battle(.regular)
		}
		return AppSection(rawValue: str) ?? .battle(.regular)
	}
}

class ExtensionDelegate: NSObject, WKExtensionDelegate {
	
	private static let updateTimeInterval: TimeInterval = 300
	
	weak var initialInterfaceController: InitialInterfaceController?
	
	func applicationDidFinishLaunching() {
		// Perform any final initialization of your application.
		
		registerAppSettings(to: .group)
		
//		let session = WCSession.default
//		session.delegate = self
//		session.activate()
		
		if !UserDefaults.group.bool(forKey: "ShowSalmonRun") && selectedMode == .salmonRun {
			selectedMode = .battle(.regular)
		}
		
		loadSchedule(displayMode: selectedMode)
		
	}
	
	func loadSchedule(displayMode: AppSection) {
		print("Loading schedules")
		
		var errorToShow: Error?
		let group = DispatchGroup()
		
		group.enter()
		getSchedule { (result) in
			switch result {
			case .failure(let error):
				switch selectedMode {
				case .battle(_):
					errorToShow = error
				default:
					break
				}
			case .success(var sch):
				sch.removeExpiredEntries()
				battleSchedule = sch
			}
			group.leave()
		}
		
		group.enter()
		getRuns { (result) in
			switch result {
			case .failure(let error):
				switch selectedMode {
				case .battle(_):
					errorToShow = error
				default:
					break
				}
			case .success(var r):
				r.removeExpiredShifts()
				r.sort()
				runSchedule = r
			}
			group.leave()
		}
		
		group.wait()
		
		if let error = errorToShow {
			if let initial = initialInterfaceController {
				initial.showError(error)
			} else {
				DispatchQueue.main.async {
					WKInterfaceController.reloadRootControllers(withNames: ["Initial"], contexts: [error])
				}
			}
		} else {
			reloadControllers(mode: displayMode)
			self.extendComplicationTimelines()
			self.scheduleBackgroundRefresh()
		}
	
	}
	
	func scheduleBackgroundRefresh() {
		// Schedule next update
		
		guard let refreshDate: Date = {
			switch complicationMode {
			case .battle(let mode):
				return battleSchedule?[mode].first?.endTime.addingTimeInterval(ExtensionDelegate.updateTimeInterval)
			case .salmonRun:
				return runSchedule?.shifts.first?.endTime.addingTimeInterval(ExtensionDelegate.updateTimeInterval)
			}
		}() else {
				return
		}
		
		WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: refreshDate, userInfo: nil) { error in
			if let error = error {
				print("Error scheduling background task:", error.localizedDescription)
			} else {
				print("Successfully scheduled background task")
			}
			
		}
	}
	
	func scheduleSnapshot() {
		let fireDate = Date()
		WKExtension.shared().scheduleSnapshotRefresh(withPreferredDate: fireDate, userInfo: nil) { error in
			if let error = error {
				print("Error scheduling snapshot:", error.localizedDescription)
			} else {
				print("Successfully scheduled snapshot.  All background work completed.")
			}
		}
	}
	
	func scheduleForegroundReload() {
		guard let updateTime: Date = {
			switch selectedMode {
			case .battle(let mode):
				return battleSchedule?[mode].first?.endTime
			case .salmonRun:
				return runSchedule?.shifts.first?.endTime
			}
			}() else {
			self.loadSchedule(displayMode: selectedMode)
				return
		}
		
		timer = Timer(fire: updateTime, interval: 0, repeats: false) { [weak self] timer in
			if WKExtension.shared().applicationState == .active {
				self?.loadSchedule(displayMode: selectedMode)
			}
			self?.scheduleForegroundReload()
		}
	}
	
	func scheduleBackgroundURLSession(backgroundTask: WKRefreshBackgroundTask) {
		let backgroundConfigObject = URLSessionConfiguration.background(withIdentifier: UUID().uuidString)
		backgroundConfigObject.sessionSendsLaunchEvents = true
		let backgroundSession = URLSession(configuration: backgroundConfigObject)
		
		let downloadScheduleTask = backgroundSession.downloadTask(with: BattleSchedule.downloadURL)
		downloadScheduleTask.resume()
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
				print("Received refresh task")
				// Be sure to complete the background task once you’re done.
				if WKExtension.shared().applicationState == .background {
					scheduleBackgroundURLSession(backgroundTask: backgroundTask)
				} else {
					loadSchedule(displayMode: selectedMode)
				}
				
				if #available(watchOSApplicationExtension 4.0, *) {
					backgroundTask.setTaskCompletedWithSnapshot(false)
				} else {
					backgroundTask.setTaskCompleted()
				}
				
			case let snapshotTask as WKSnapshotRefreshBackgroundTask:
				print("Received snapshot task")
				// Snapshot tasks have a unique completion call, make sure to set your expiration date
				
				let expirationDate: Date = {
					switch complicationMode {
					case .battle(let mode):
						return battleSchedule?[mode].first?.endTime ?? .distantFuture
					case .salmonRun:
						return runSchedule?.shifts.first?.endTime ?? .distantFuture
					}
				}()
				
				snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: expirationDate, userInfo: nil)
				
			case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
				// Be sure to complete the connectivity task once you’re done.
				if #available(watchOSApplicationExtension 4.0, *) {
					connectivityTask.setTaskCompletedWithSnapshot(false)
				} else {
					connectivityTask.setTaskCompleted()
				}
			case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
				print("Received URL session task")
				// Be sure to complete the URL session task once you’re done.
				let backgroundConfigObject = URLSessionConfiguration.background(withIdentifier: urlSessionTask.sessionIdentifier)
				let backgroundSession = URLSession(configuration: backgroundConfigObject, delegate: self, delegateQueue: nil)
				
				print("Rejoining session ", backgroundSession)
				
				if #available(watchOSApplicationExtension 4.0, *) {
					urlSessionTask.setTaskCompletedWithSnapshot(true)
				} else {
					urlSessionTask.setTaskCompleted()
					scheduleSnapshot()
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
	
	func extendComplicationTimelines() {
		let complicationAction: (CLKComplication) -> ()
		let updateTimeInterval = Date().timeIntervalSince(complicationUpdateDate)
		if updateTimeInterval < 7200 {
			// Updated under two hours ago
			return
		} else if updateTimeInterval < 14400 {
			// Updated between two and four hours ago
			complicationAction = CLKComplicationServer.sharedInstance().extendTimeline
		} else {
			// Updated four or more hours ago
			complicationAction = CLKComplicationServer.sharedInstance().reloadTimeline
		}
		
		for complication in CLKComplicationServer.sharedInstance().activeComplications ?? [] where complication.family == .modularLarge || complication.family == .utilitarianLarge {
			complicationAction(complication)
		}
		
		complicationUpdateDate = Date()
	}
	
}

extension ExtensionDelegate: URLSessionDownloadDelegate {
	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
		print(#function)
		
		func completion(result: ScheduleResult) {
			switch result {
			case .failure(let error):
				print("Failed to load stages:", error.localizedDescription)
			case .success(var sch):
				sch.removeExpiredEntries()
				battleSchedule = sch
				extendComplicationTimelines()
				
				self.scheduleBackgroundRefresh()
			}
		}
		
		do {
			try FileManager.default.moveItem(at: location, to: scheduleURL)
			let data = try Data(contentsOf: scheduleURL)
			
			getScheduleFinished(data: data, response: downloadTask.response, error: nil, completion: completion)
		} catch {
			getScheduleFinished(data: nil, response: downloadTask.response, error: error, completion: completion)
		}
	}
}

//extension ExtensionDelegate: WCSessionDelegate {
//	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
//		switch activationState {
//		case .activated:
//			print("WCSessionActivationState changed to activated")
//		case .inactive:
//			print("WCSessionActivationState changed to inactive")
//		case .notActivated:
//			print("WCSessionActivationState changed to not activated")
//		}
//
//		if let error = error {
//			print("WCSession Activation error: \(error.localizedDescription)")
//		}
//	}
//
//
//}

