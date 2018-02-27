//
//  AppDelegate.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 8/28/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit
import WatchConnectivity
import OneSignal

var battleSchedule: BattleSchedule?
var runSchedule: SalmonRunSchedule?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		registerAppSettings(to: .group)
		
		setupAttributes()
		
//		print("Will activate WCSession")
//		if WCSession.isSupported() {
//			print("Activating WCSession")
//			WCSession.default.delegate = self
//			WCSession.default.activate()
//		}
		
//		setupOneSignal(launchOptions: launchOptions)
		
		return setupTabBar()
	}
	
	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}
	
	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}
	
	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
			let host = components.host else {
				return false
		}
		
		switch host {
		case "openMode":
			guard let str = components.queryItems?.dictionary["mode"],
				let mode = AppSection(rawValue: str) else {
					return false
			}
			return showScreen(mode)
		default:
			return false
		}
	}
	
	func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
		switch userActivity.activityType {
		case "com.josh.birnholz.Splatoon-2-Stages.openMode":
			if let modeString = userActivity.userInfo?["mode"] as? String,
				let mode = AppSection(rawValue: modeString) {
				return showScreen(mode)
			}
		default:
			break
		}
		
		return false
	}
	
	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		guard shortcutItem.type == "openMode", let str = shortcutItem.userInfo?["mode"] as? String, let mode = AppSection(rawValue: str) else {
			completionHandler(false)
			return
		}
		
		completionHandler(showScreen(mode))
	}
	
	func showScreen(_ mode: AppSection) -> Bool {
		print("Opening to mode:", mode)
		
		guard let tabBarController = window?.rootViewController as? UITabBarController,
			let tab = tabBarController.tabBar.items?.first(where: { (item) -> Bool in
				item.title == mode.description
			}),
			let index = tabBarController.tabBar.items?.index(of: tab) else {
				
				
				return false
		}
		
		tabBarController.selectedIndex = index
		return true
	}
	
	private func setupTabBar() -> Bool {
		guard let tab = window?.rootViewController as? SplatoonTabBarController,
			let storyboard = tab.storyboard else {
				return false
		}
		
		tab.delegate = self
		
		let preferLargeTitles = UserDefaults.group.bool(forKey: "PreferLargeTitles")
		
		var vcs: [UIViewController] = []
		
		let currentStages = UINavigationController(rootViewController: storyboard.instantiateViewController(withIdentifier: "CurrentStages"))
		currentStages.tabBarItem = UITabBarItem(title: "Now", image: #imageLiteral(resourceName: "stages"), tag: 0)
		currentStages.navigationBar.barStyle = .black
		if #available(iOS 11.0, *) {
			currentStages.navigationBar.prefersLargeTitles = preferLargeTitles
		}
		vcs.append(currentStages)
		
		for mode: Mode in [.regular, .ranked, .league] {
			let upcomingStagesVC = UINavigationController(rootViewController: storyboard.instantiateViewController(withIdentifier: "UpcomingStages"))
			(upcomingStagesVC.viewControllers[0] as! UpcomingStagesViewController).mode = mode
			upcomingStagesVC.tabBarItem = UITabBarItem(title: mode.description, image: mode.tabBarIcon, tag: 0)
			upcomingStagesVC.tabBarItem.selectedImage = mode.selectedTabBarIcon
			upcomingStagesVC.navigationBar.barStyle = .black
			if #available(iOS 11.0, *) {
				upcomingStagesVC.navigationBar.prefersLargeTitles = preferLargeTitles
			}
			vcs.append(upcomingStagesVC)
		}
		
		let shouldShowSalmonRun = UserDefaults.group.bool(forKey: "ShowSalmonRun")
		
		if shouldShowSalmonRun {
			
			let salmonRun = UINavigationController(rootViewController: storyboard.instantiateViewController(withIdentifier: "SalmonRun"))
			salmonRun.tabBarItem = UITabBarItem(title: "Salmon Run", image: #imageLiteral(resourceName: "Salmon Tab"), tag: 0)
			salmonRun.tabBarItem.selectedImage = #imageLiteral(resourceName: "Salmon Tab Selected")
			salmonRun.navigationBar.barStyle = .black
			if #available(iOS 11.0, *) {
				salmonRun.navigationBar.prefersLargeTitles = preferLargeTitles
			}
			vcs.append(salmonRun)
			
		}
		
		tab.viewControllers = vcs
		
		return true
	}
	
	private func setupAttributes() {
		UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "JapanYoshiSplatoon", size: 22)!]
		
		UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Splatoon2", size: 9)!], for: .normal)
		
		UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Splatoon2", size: 19)!], for: .normal)
		UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Splatoon2", size: 19)!], for: .selected)
		UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Splatoon2", size: 19)!], for: .highlighted)
		UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Splatoon2", size: 19)!], for: .disabled)
		
		//UITabBarItem.appearance().setBadgeTextAttributes([NSAttributedStringKey.font.rawValue: UIFont(name: "Splatoon2", size: 10)!], for: .normal)
		//UITabBarItem.appearance().setBadgeTextAttributes([NSAttributedStringKey.font.rawValue: UIFont(name: "Splatoon2", size: 10)!], for: .selected)
	}
	
	// MARK: OneSignal
	
	private func setupOneSignal(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
		let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
		
		// Replace 'YOUR_APP_ID' with your OneSignal App ID.
		OneSignal.initWithLaunchOptions(launchOptions,
										appId: "58e66b0d-3dfc-4b04-90e6-14e872a959da",
										handleNotificationAction: nil,
										settings: onesignalInitSettings)
		
		OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
		
		// Recommend moving the below line to prompt for push after informing the user about
		//   how your app will use them.
		OneSignal.promptForPushNotifications(userResponse: { accepted in
			print("User accepted notifications: \(accepted)")
		})
		
		// Sync hashed email if you have a login system or collect it.
		//   Will be used to reach the user at the most optimal time of day.
		// OneSignal.syncHashedEmail(userEmail)
	}
	
	// MARK: UITabBarControllerDelegate
	weak var previousController: UIViewController?
	
	func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
		let topVC = ((viewController as? UINavigationController)?.topViewController ?? viewController) as? UITableViewController
		if topVC == previousController {
			topVC?.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
		}
		previousController = topVC
	}
	
	
}

extension AppDelegate: WCSessionDelegate {
	
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		if activationState == .activated {
			print("Watch session activated")
		}
		
		if let error = error {
			print("Error activating WCSession:", error.localizedDescription)
		}
	}
	
	func sessionDidBecomeInactive(_ session: WCSession) {
		print("Watch session became inactive")
	}
	
	func sessionDidDeactivate(_ session: WCSession) {
		print("Watch Session deactivated")
	}
	
}
