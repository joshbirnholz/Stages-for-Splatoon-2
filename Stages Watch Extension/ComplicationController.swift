//
//  ComplicationController.swift
//  Stages Watch Extension
//
//  Created by Josh Birnholz on 8/30/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

// Human Interface Guidelines:
// Complications: https://developer.apple.com/watchos/human-interface-guidelines/app-components/
// Complication Images: https://developer.apple.com/watchos/human-interface-guidelines/icons-and-images/#complication-images

import WatchKit
import ClockKit


@objc fileprivate protocol LargeStandardBodyComplication: class {
	var headerTextProvider: CLKTextProvider { get set }
	var body1TextProvider: CLKTextProvider { get set }
	var body2TextProvider: CLKTextProvider? { get set }
	var tintColor: UIColor? { get set }
	func setHeaderImage(_ image: UIImage?)
}

@available(watchOSApplicationExtension 5.0, *)
extension CLKComplicationTemplateGraphicRectangularStandardBody: LargeStandardBodyComplication {
	func setHeaderImage(_ image: UIImage?) {
		headerImageProvider = image.map(CLKFullColorImageProvider.init)
	}
	
	
}
extension CLKComplicationTemplateModularLargeStandardBody: LargeStandardBodyComplication {
	func setHeaderImage(_ image: UIImage?) {
		headerImageProvider = image.map(CLKImageProvider.init)
	}
}

var complicationMode: AppSection {
	get {
		guard let str = UserDefaults.group.string(forKey: "complicationMode") else {
			return .battle(.regular)
		}
		return AppSection(rawValue: str) ?? .battle(.regular)
	}
}

var complicationUpdateDate: Date {
	set {
		UserDefaults.standard.set(newValue, forKey: "complicationUpdateDate")
	}
	get {
		return (UserDefaults.standard.object(forKey: "complicationUpdateDate") as? Date) ?? .distantPast
	}
}

class ComplicationController: NSObject, CLKComplicationDataSource {
	
	static let tintColor = #colorLiteral(red: 0.95014292, green: 0.2125228047, blue: 0.5165724158, alpha: 1)
	
	// Calls the completion handler with the loaded (valid) schedule, if any, otherwise it downloads the schedule, saves it to disk, and calls the completion handler with that. This avoids redownloading the schedule when the current schedule is valid.
	func loadBattleSchedule(completion: @escaping (BattleSchedule?) -> Void) {
		if let schedule = battleSchedule, schedule.isValid {
			completion(schedule)
			return
		}
		
		getSchedule { result in
			switch result {
			case .failure(let error):
				print("Failed to get schedule", error.localizedDescription)
				completion(nil)
			case .success(var sch):
				sch.removeExpiredEntries()
				battleSchedule = sch
				completion(sch)
			}
		}
		
	}
	
	func loadSalmonRunSchedule(completion: @escaping (SalmonRunSchedule?) -> Void) {
		if let schedule = runSchedule, schedule.isValid {
			completion(schedule)
			return
		}
		
		getRuns { result in
			switch result {
			case .failure(let error):
				print("Failed to get salmon run schedule", error.localizedDescription)
				completion(nil)
			case .success(var r):
				r.removeExpiredShifts()
				r.sort()
				runSchedule = r
				completion(r)
			}
		}
	}
	
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward, .backward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
		switch complicationMode {
		case .battle(let mode):
			loadBattleSchedule { schedule in
				guard let firstEntry = schedule?[mode].first else {
					handler(nil)
					return
				}
				
				handler(firstEntry.startTime)
				
			}
		case .salmonRun:
			loadSalmonRunSchedule { runs in
				guard let firstRun = runs?.shifts.first else {
					handler(nil)
					return
				}
				
				handler(firstRun.startTime)
			}
		}
		
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
		switch complicationMode {
		case .battle(let mode):
			loadBattleSchedule { schedule in
				guard let lastEntry = schedule?[mode].last else {
					handler(nil)
					return
				}
			
				handler(lastEntry.endTime)
			}
		case .salmonRun:
			loadSalmonRunSchedule { runs in
				guard let lastRun = runs?.shifts.last else {
					handler(nil)
					return
				}
				
				handler(lastRun.endTime)
			}
		}
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
		switch complicationMode {
		case .battle(let mode):
			loadBattleSchedule { schedule in
				guard let scheduleEntry = schedule?[mode].first else {
					handler(nil)
					return
				}
				
				if let template = self.battleTemplate(for: complication.family, scheduleEntry: scheduleEntry) {
					let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
					handler(entry)
					return
				}
				
				handler(nil)
			}
		case .salmonRun:
			loadSalmonRunSchedule { schedule in
				guard let run = schedule?.shifts.first else {
					handler(nil)
					return
				}
				
				if let template = self.salmonRunTemplate(for: complication.family, run: run) {
					let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
					handler(entry)
					return
				}
				
				handler(nil)
			}
		}
		
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
		handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
		switch complicationMode {
		case .battle(let mode):
				loadBattleSchedule { schedule in
					guard let entries = schedule?[mode] else {
						handler(nil)
						return
					}
					
					let timelineEntries: [CLKComplicationTimelineEntry] = entries.compactMap { scheduleEntry in
						guard let template = self.battleTemplate(for: complication.family, scheduleEntry: scheduleEntry) else {
							return nil
						}
						let timelineEntry = CLKComplicationTimelineEntry(date: scheduleEntry.startTime, complicationTemplate: template)
						return timelineEntry
					}
					
					handler(timelineEntries)
			}
		case .salmonRun:
			loadSalmonRunSchedule { schedule in
				guard let runs = schedule?.shifts, !runs.isEmpty else {
					handler(nil)
					return
				}
				
				// TODO: Create timeline entries for during and between salmon runs

				handler(nil)
				
			}
		}
		
		
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
		let start = Date().addingTimeInterval(-2700)
		let end = start.addingTimeInterval(7200)
		
		let gameMode = BattleSchedule.Entry.GameMode(name: "Regular", key: "regular")
		let stageA = BattleSchedule.Entry.Stage(name: "Stage A")
		let stageB = BattleSchedule.Entry.Stage(name: "Stage B")
		
		let rule = BattleSchedule.Entry.Rule(key: "turfwar", name: "Turf War")
		
		let sampleScheduleEntry = BattleSchedule.Entry(startTime: start,
		                                               gameMode: gameMode,
		                                               endTime: end,
		                                               stageA: stageA,
		                                               stageB: stageB,
		                                               rule: rule)
		
		handler(battleTemplate(for: complication.family, scheduleEntry: sampleScheduleEntry))
		
    }
	
	func battleTemplate(for complicationFamily: CLKComplicationFamily, scheduleEntry: BattleSchedule.Entry) -> CLKComplicationTemplate? {
		
		let gameMode = Mode(rawValue: scheduleEntry.gameMode.key) ?? .regular
		
		var endTimeRelativeDateTextProvider: CLKRelativeDateTextProvider {
			return CLKRelativeDateTextProvider(date: scheduleEntry.endTime, style: .timer, units: [.hour, .minute, .second])
		}
		
		var stageATextProvider: CLKSimpleTextProvider {
			return CLKSimpleTextProvider(text: scheduleEntry.stageA.name)
		}
		
		var stageBTextProvider: CLKSimpleTextProvider {
			return CLKSimpleTextProvider(text: scheduleEntry.stageB.name)
		}
		
		var ruleTextProvider: CLKSimpleTextProvider {
			return CLKSimpleTextProvider(text: scheduleEntry.rule.name)
		}
		
		var timeLeftGaugeProvider: CLKGaugeProvider {
			return CLKTimeIntervalGaugeProvider(style: .fill,
												gaugeColors: [gameMode.color],
												gaugeColorLocations: nil,
												start: scheduleEntry.startTime,
												end: scheduleEntry.endTime)
		}
		
		switch complicationFamily {
		case .circularSmall:
			let template = CLKComplicationTemplateCircularSmallStackImage()
			let dimension = WKInterfaceDevice.current().screenBounds.width > 136.0 ? 16 : 14
			let size = CGSize(width: dimension, height: dimension)
			template.line1ImageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "stages").scaled(toFit: size))
			template.line2TextProvider = endTimeRelativeDateTextProvider
			template.tintColor = ComplicationController.tintColor
			return template
		case .extraLarge:
			let template = CLKComplicationTemplateExtraLargeStackImage()
			let dimension = WKInterfaceDevice.current().screenBounds.width > 136.0 ? 90 : 84
			let size = CGSize(width: dimension, height: dimension)
			template.line1ImageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "stages").scaled(toFit: size))
			template.line2TextProvider = endTimeRelativeDateTextProvider
			template.tintColor = ComplicationController.tintColor
			return template
		case .modularLarge, .graphicRectangular:
			let template: LargeStandardBodyComplication = {
				if #available(watchOSApplicationExtension 5.0, *) {
					if complicationFamily == .graphicRectangular {
						return CLKComplicationTemplateGraphicRectangularStandardBody()
					}
				}
				return CLKComplicationTemplateModularLargeStandardBody()
			}()
			
			let dimension: CGFloat = {
				switch WKInterfaceDevice.current().screenBounds.width {
				case 136: // 38mm
					return 22
				case 156, 162: // 42mm, 40mm
					return 24
				case _ where complicationFamily == .modularLarge: // 44mm
					return 28
				default: // 44mm
					return 27
				}
			}()
			let size = CGSize(width: dimension, height: dimension)
			template.setHeaderImage(gameMode.tabBarIcon.scaled(toFit: size))
			template.headerTextProvider = ruleTextProvider
			template.body1TextProvider = stageATextProvider
			template.body2TextProvider = stageBTextProvider
			template.tintColor = gameMode.color
			return template as? CLKComplicationTemplate
		case .modularSmall:
			let template = CLKComplicationTemplateModularSmallStackImage()
			let dimension = WKInterfaceDevice.current().screenBounds.width > 136.0 ? 30 : 28
			let size = CGSize(width: dimension, height: dimension)
			template.line1ImageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "stages").scaled(toFit: size))
			template.line2TextProvider = endTimeRelativeDateTextProvider
			template.tintColor = ComplicationController.tintColor
			return template
		case .utilitarianLarge:
			let template = CLKComplicationTemplateUtilitarianLargeFlat()
			let dimension = WKInterfaceDevice.current().screenBounds.width > 136.0 ? 20 : 18
			let size = CGSize(width: dimension, height: dimension)
			template.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "stages").scaled(toFit: size))
			template.textProvider = endTimeRelativeDateTextProvider
			template.tintColor = ComplicationController.tintColor
			return template
		case .utilitarianSmall:
			return genericTemplate(for: complicationFamily)
		case .utilitarianSmallFlat:
			let template = CLKComplicationTemplateUtilitarianSmallFlat()
			let dimension = WKInterfaceDevice.current().screenBounds.width > 136.0 ? 20 : 18
			let size = CGSize(width: dimension, height: dimension)
			template.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "stages").scaled(toFit: size))
			template.textProvider = endTimeRelativeDateTextProvider
			template.tintColor = ComplicationController.tintColor
			return template
		case .graphicCorner:
			if #available(watchOSApplicationExtension 5.0, *) {
				let template = CLKComplicationTemplateGraphicCornerGaugeText()
				template.gaugeProvider = timeLeftGaugeProvider
				
//				let dimension: CGFloat = {
//					switch WKInterfaceDevice.current().screenBounds.width {
//					case 162: // 40mm
//						return 20
//					default: // 44mm
//						return 22
//					}
//				}()
				
				template.outerTextProvider = endTimeRelativeDateTextProvider
//				template.imageProvider = CLKFullColorImageProvider(fullColorImage: gameMode.shortcutIcon.scaled(toFit: CGSize(width: dimension, height: dimension)))
				
				return template
				
			} else {
				return nil
			}
		case .graphicBezel:
			if #available(watchOSApplicationExtension 5.0, *) {
				let template = CLKComplicationTemplateGraphicBezelCircularText()
				template.textProvider = CLKSimpleTextProvider(text: "\(scheduleEntry.stageA.name) • \(scheduleEntry.stageB.name)", shortText: "\(scheduleEntry.stageA.name.split(separator: " ").first ?? "") • \(scheduleEntry.stageB.name.split(separator: " ").first ?? "")")
				template.circularTemplate = {
					let template = CLKComplicationTemplateGraphicCircularClosedGaugeImage()
					
					let dimension: CGFloat = {
						switch WKInterfaceDevice.current().screenBounds.width {
						case 162: // 40mm
							return 28
						default: // 44mm
							return 32
						}
					}()
					
					template.gaugeProvider = timeLeftGaugeProvider
					
					let size = CGSize(width: dimension, height: dimension)
					let image = gameMode.shortcutIcon.scaled(toFit: size)
					template.imageProvider = CLKFullColorImageProvider(fullColorImage: image)
					
					return template
				}()
				
				return template
			}
			return nil
		case .graphicCircular:
			if #available(watchOSApplicationExtension 5.0, *) {
				return genericTemplate(for: .graphicCircular)
			} else {
				return nil
			}
		}
		
	}
	
	func salmonRunTemplate(for complicationFamily: CLKComplicationFamily, run: SalmonRunSchedule.Shift) -> CLKComplicationTemplate? {
		// TODO: return Salmon Run template
		return nil
	}
	
	func genericTemplate(for complicationFamily: CLKComplicationFamily) -> CLKComplicationTemplate? {
		switch complicationFamily {
		case .circularSmall:
			let template = CLKComplicationTemplateCircularSmallSimpleImage()
			template.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Complication/Circular"))
			template.tintColor = ComplicationController.tintColor
			return template
		case .extraLarge:
			let template = CLKComplicationTemplateExtraLargeSimpleImage()
			template.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Complication/Extra Large"))
			template.tintColor = ComplicationController.tintColor
			return template
		case .modularSmall:
			let template = CLKComplicationTemplateModularSmallSimpleImage()
			template.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Complication/Modular"))
			template.tintColor = ComplicationController.tintColor
			return template
		case .utilitarianLarge:
			let template = CLKComplicationTemplateUtilitarianLargeFlat()
			let dimension = WKInterfaceDevice.current().screenBounds.width > 136.0 ? 20 : 18
			let size = CGSize(width: dimension, height: dimension)
			template.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "stages").scaled(toFit: size))
			template.textProvider = CLKSimpleTextProvider(text: "Stages")
			template.tintColor = ComplicationController.tintColor
			return template
		case .utilitarianSmall:
			let template = CLKComplicationTemplateUtilitarianSmallSquare()
			template.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Complication/Utilitarian"))
			template.tintColor = ComplicationController.tintColor
			return template
		case .utilitarianSmallFlat:
			let template = CLKComplicationTemplateUtilitarianSmallFlat()
			let dimension = WKInterfaceDevice.current().screenBounds.width > 136.0 ? 20 : 18
			let size = CGSize(width: dimension, height: dimension)
			template.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "stages").scaled(toFit: size))
			template.textProvider = CLKSimpleTextProvider(text: "Stages")
			template.tintColor = ComplicationController.tintColor
			return template
		case .graphicCircular:
			if #available(watchOSApplicationExtension 5.0, *) {
				let template = CLKComplicationTemplateGraphicCircularImage()
				
				let dimension: CGFloat = {
					switch WKInterfaceDevice.current().screenBounds.width {
					case 162: // 40mm
						return 42
					default: // 44mm
						return 47
					}
				}()
				
				let size = CGSize(width: dimension, height: dimension)
				template.imageProvider = CLKFullColorImageProvider(fullColorImage: #imageLiteral(resourceName: "Overview Shortcut").scaled(toFit: size))
				
				return template
			}
			return nil
		case .graphicCorner:
			if #available(watchOSApplicationExtension 5.0, *) {
				let template = CLKComplicationTemplateGraphicCornerCircularImage()
				
				let dimension: CGFloat = {
					switch WKInterfaceDevice.current().screenBounds.width {
					case 162: // 40mm
						return 32
					default: // 44mm
						return 36
					}
				}()
				
				let size = CGSize(width: dimension, height: dimension)
				template.imageProvider = CLKFullColorImageProvider(fullColorImage: #imageLiteral(resourceName: "Overview Shortcut").scaled(toFit: size))
				
				return template
			}
			return nil
		default:
			return nil
		}
	}
	
}
