//
//  RemoteImageURL.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 4/19/18.
//  Copyright © 2018 Joshua Birnholz. All rights reserved.
//

import UIKit

fileprivate let imageBaseURL = URL(string: "https://splatoon2.ink/assets/img/splatnet/")!
public func remoteImageURL(forImageWithID splatnetID: String) -> URL {
	return imageBaseURL.appendingPathComponent(splatnetID + ".png")
}
