//
//  ImageLoader.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 11/14/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit

public let baseImageURL = URL(string: "https://splatoon2.ink/assets/img/splatnet/")!

fileprivate let cache = NSCache<NSString, UIImage>()

//fileprivate var cache = [String: UIImage]()
//extension Dictionary {
//	func object(forKey key: Key) -> Value? {
//		return self[key]
//	}
//
//	mutating func setObject(_ obj: Value, forKey key: Key) {
//		self[key] = obj
//	}
//}

fileprivate let sharedCacheDirectory = documentDirectory.appendingPathComponent("Library").appendingPathComponent("Caches")

/// Attempts to use a cached version first, otherwise it downloads it from https://splatoon2.ink
///
/// You probably want to call the completion handler from the main queue.
func loadImage(withSplatNetID id: String, completion: @escaping (UIImage?) -> ()) {
	DispatchQueue.global(qos: .userInitiated).async {
		
		// Attempt to load the image from memory
		
		if let image = cache.object(forKey: id as NSString) {
			print("Loaded image \(id) from memory")
			completion(image)
			return
		}
		
		// Attempt to load the image from a local file
		
		let fileName = id + ".png"
		let localImageURL = sharedCacheDirectory.appendingPathComponent(fileName)
		let remoteImageURL = baseImageURL.appendingPathComponent(fileName)
		
		if let image = UIImage(contentsOfFile: localImageURL.path) {
			print("Loaded local image \(localImageURL)")
			cache.setObject(image, forKey: id as NSString)
			completion(image)
			return
		}
		
		// Load the image remotely
		
		URLSession.shared.dataTask(with: remoteImageURL){ (data, response, error) in
			guard let data = data, error == nil else {
				print("Error loading remote image from \(remoteImageURL) - \(error!.localizedDescription)")
				completion(nil)
				return
			}
			
			if let image = UIImage(data: data) {
				completion(image)
				print("Loaded remote image from \(remoteImageURL)")
				
				cache.setObject(image, forKey: id as NSString)
				
				do {
					try data.write(to: localImageURL, options: [.atomic])
					print("Wrote image to \(localImageURL) successfully")
				} catch {
					print("Error writing image to \(localImageURL) - \(error.localizedDescription)")
				}
			}
			
		}.resume()
		
	}
	
}

struct ImageRequest: Hashable {
	public var isCancelled: Bool = false
	
	private let id = UUID()
	
	// MARK: Equatable
	
	static func ==(lhs: ImageRequest, rhs: ImageRequest) -> Bool {
		return lhs.id == rhs.id
	}
	
	// MARK: Hashable
	
	var hashValue: Int {
		return id.hashValue
	}
	
}
