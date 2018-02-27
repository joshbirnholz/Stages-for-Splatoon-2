//
//  BattleSchedule+AlertSubject.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 1/31/18.
//  Copyright © 2018 Joshua Birnholz. All rights reserved.
//

import UserNotifications

fileprivate let encoder: JSONEncoder = {
	let enc = JSONEncoder()
	enc.dateEncodingStrategy = .secondsSince1970
	return enc
}()

extension BattleSchedule.Entry: AlertSubject {
	var alertEventDate: Date? {
		return startTime
	}
	
	var alertEventID: String {
		return rule.key + startTime.description + endTime.description
	}
	
	func alertContent(_ alertTime: AlertTime) -> UNNotificationContent? {
		let content = UNMutableNotificationContent()
		
		content.title = rule.name
		content.subtitle = gameMode.name
		content.body = [stageA, stageB].map { $0.name }.joined(separator: ", ") + "\n" + "\(dateFormatter.string(from: startTime)) - \(dateFormatter.string(from: endTime))"
		
		var attachments: [UNNotificationAttachment?] = []
		
		for stage in [stageA, stageB] {
			var mutableStage = stage
			let imageID = mutableStage.imageID
			do {
				let originalURL = localURL(forImageWithSplatnetID: imageID)
				let fileName = imageID + "-attachment.png"
				let duplicateURL = originalURL.deletingLastPathComponent().appendingPathComponent(fileName)
				
				try FileManager.default.copyItem(at: originalURL, to: duplicateURL)
				
				let attachment = try UNNotificationAttachment(identifier: imageID, url: duplicateURL, options: nil)
				attachments.append(attachment)
			} catch {
				print("Error creating attachment:", error.localizedDescription)
			}
			
		}
		
		content.attachments = attachments.flatMap { $0 }
		
		for attachment in content.attachments {
			print("Attachment ID: \(attachment.identifier)")
		}
		
		content.sound = .default()
		
		if let data = try? encoder.encode(self), let jsonString = String.init(data: data, encoding: .utf8) {
			content.categoryIdentifier = "battleStage"
			content.userInfo = ["entryJSON": jsonString]
		}
		
		return content
	}
	
}

extension SalmonRunSchedule.Shift: AlertSubject {
	var alertEventDate: Date? {
		return startTime
	}
	
	var alertEventID: String {
		return "salmonrun" + startTime.description + endTime.description
	}
	
	func alertContent(_ alertTime: AlertTime) -> UNNotificationContent? {
		guard let stage = stage else {
			return nil
		}
		
		let content = UNMutableNotificationContent()
		
		content.title = "Salmon Run"
		content.subtitle = stage.name
		content.body = "\(dateFormatter.string(from: startTime)) - \(dateFormatter.string(from: endTime))"
		
		do {
			let attachment = try UNNotificationAttachment(identifier: stage.imageID, url: localURL(forImageWithSplatnetID: stage.imageID), options: nil)
			content.attachments = [attachment]
		} catch {
			print("Error creating attachment:", error.localizedDescription)
		}
		
		return content
	}
	
	
	
	
}
