//
//  ComplicationController.swift
//  Stages Watch Extension
//
//  Created by Josh Birnholz on 8/30/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import WatchKit
import ClockKit

var complicationMode: Mode {
	get {
		guard let str = UserDefaults.group.string(forKey: "complicationMode") else {
			return .regular
		}
		return Mode(rawValue: str) ?? .regular
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
	
	override init() {
		super.init()
	}
	
	// Calls the completion handler with the loaded (valid) schedule, if any, otherwise it downloads the schedule, saves it to disk, and calls the completion handler with that. This avoids redownloading the schedule when the current schedule is valid.
	func loadSchedule(completion: @escaping (Schedule?) -> Void) {
		if let schedule = schedule, schedule.isValid {
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
				schedule = sch
				completion(sch)
			}
		}
		
		
	}
	
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward, .backward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
		loadSchedule { schedule in
			guard let firstEntry = schedule?[complicationMode].first else {
				handler(nil)
				return
			}
			
			handler(firstEntry.startTime)
			
		}
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
		loadSchedule { schedule in
			guard let lastEntry = schedule?[complicationMode].last else {
				handler(nil)
				return
			}
			
			handler(lastEntry.endTime)
			
		}
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
		loadSchedule { schedule in
			guard let scheduleEntry = schedule?[complicationMode].first else {
				handler(nil)
				return
			}
			
			if let template = self.template(for: complication.family, scheduleEntry: scheduleEntry) {
				let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
				handler(entry)
				return
			}
			
			handler(nil)
		}
		
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
		handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
		loadSchedule { schedule in
			guard let entries = schedule?[complicationMode] else {
				handler(nil)
				return
			}
			
			let timelineEntries: [CLKComplicationTimelineEntry] = entries.flatMap { scheduleEntry in
				guard let template = self.template(for: complication.family, scheduleEntry: scheduleEntry) else {
					return nil
				}
				let timelineEntry = CLKComplicationTimelineEntry(date: scheduleEntry.startTime, complicationTemplate: template)
				return timelineEntry
			}
			
			handler(timelineEntries)
		}
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
		let start = Date()
		let end = start.addingTimeInterval(7200)
		
		let gameMode = Schedule.Entry.GameMode(name: "Regular", key: "regular")
		let stageA = Schedule.Entry.Stage(id: "", name: "Stage A", image: "")
		let stageB = Schedule.Entry.Stage(id: "", name: "Stage B", image: "")
		
		let rule = Schedule.Entry.Rule(multilineName: "", key: "turfwar", name: "Turf War")
		
		let sampleScheduleEntry = Schedule.Entry(startTime: start,
		                                         id: 0,
		                                         gameMode: gameMode,
		                                         endTime: end,
		                                         stageA: stageA,
		                                         stageB: stageB,
		                                         rule: rule)
		
        handler(template(for: complication.family, scheduleEntry: sampleScheduleEntry))
    }
	
	func template(for complicationFamily: CLKComplicationFamily, scheduleEntry: Schedule.Entry) -> CLKComplicationTemplate? {
		
		let gameMode = Mode(rawValue: scheduleEntry.gameMode.key) ?? .regular
		let tintColor = #colorLiteral(red: 0.95014292, green: 0.2125228047, blue: 0.5165724158, alpha: 1)
		
		switch complicationFamily {
		case .circularSmall:
			let template = CLKComplicationTemplateCircularSmallSimpleImage()
			template.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Complication/Circular"))
			template.tintColor = tintColor
			return template
		case .extraLarge:
			let template = CLKComplicationTemplateExtraLargeSimpleImage()
			template.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Complication/Extra Large"))
			template.tintColor = tintColor
			return template
		case .modularLarge:
			let template = CLKComplicationTemplateModularLargeStandardBody()
			let dimension = WKInterfaceDevice.current().screenBounds.width > 136.0 ? 24 : 22
			let size = CGSize(width: dimension, height: dimension)
			template.headerImageProvider = CLKImageProvider(onePieceImage: gameMode.tabBarIcon.scaled(toFit: size))
			template.headerTextProvider = CLKSimpleTextProvider(text: scheduleEntry.rule.name)
			template.body1TextProvider = CLKSimpleTextProvider(text: scheduleEntry.stageA.name)
			template.body2TextProvider = CLKSimpleTextProvider(text: scheduleEntry.stageB.name)
			template.tintColor = gameMode.color
			return template
		case .modularSmall:
			let template = CLKComplicationTemplateModularSmallSimpleImage()
			template.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Complication/Modular"))
			template.tintColor = tintColor
			return template
		case .utilitarianLarge:
			let template = CLKComplicationTemplateUtilitarianLargeFlat()
			template.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Complication/Utilitarian"))
			template.textProvider = CLKSimpleTextProvider(text: scheduleEntry.rule.name)
			template.tintColor = gameMode.color
			return template
		case .utilitarianSmall:
			let template = CLKComplicationTemplateUtilitarianSmallSquare()
			template.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Complication/Utilitarian"))
			template.tintColor = tintColor
			return template
		case .utilitarianSmallFlat:
			let template = CLKComplicationTemplateUtilitarianSmallFlat()
			template.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Complication/Utilitarian"))
			template.textProvider = CLKSimpleTextProvider(text: "Stages", shortText: "Stages")
			template.tintColor = tintColor
			return template
		}
		
	}
    
}
