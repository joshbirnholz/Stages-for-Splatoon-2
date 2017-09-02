//
//  AppDelegate.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 8/28/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit

var schedule: Schedule?

var runs: Runs? {
	didSet {
		if let runs = runs {
			do {
				let data = try encoder.encode(runs)
				try data.write(to: runsURL, options: .atomic)
			} catch {
				print("Error writing schedule:", error.localizedDescription)
			}
		}
	}
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "JapanYoshiSplatoon", size: 22)!]
		
		UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Splatoon2", size: 9)!], for: .normal)
		
		//UITabBarItem.appearance().setBadgeTextAttributes([NSAttributedStringKey.font.rawValue: UIFont(name: "Splatoon2", size: 10)!], for: .normal)
		//UITabBarItem.appearance().setBadgeTextAttributes([NSAttributedStringKey.font.rawValue: UIFont(name: "Splatoon2", size: 10)!], for: .selected)
		
		guard let tab = window?.rootViewController as? SplatoonTabBarController,
			let storyboard = tab.storyboard else {
			return false
		}
		
		var vcs: [UIViewController] = []
		
		let preferLargeTitles = false
		
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
		
		let salmonRun = UINavigationController(rootViewController: storyboard.instantiateViewController(withIdentifier: "SalmonRun"))
		salmonRun.tabBarItem = UITabBarItem(title: "Salmon Run", image: #imageLiteral(resourceName: "Salmon Tab"), tag: 0)
		salmonRun.tabBarItem.selectedImage = #imageLiteral(resourceName: "Salmon Tab Selected")
		salmonRun.navigationBar.barStyle = .black
		if #available(iOS 11.0, *) {
			salmonRun.navigationBar.prefersLargeTitles = preferLargeTitles
		}
		vcs.append(salmonRun)
		
		tab.viewControllers = vcs
		
		return true
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


}

