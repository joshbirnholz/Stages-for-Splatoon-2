//
//  UIImage+Scaled.swift
//  Splatoon 2 Stages
//
//  Created by Josh Birnholz on 8/27/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import UIKit

extension UIImage {
	public func scaled(to size: CGSize, backgroundColor: UIColor? = nil) -> UIImage {
		//create drawing context
		UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
		
		let rect = CGRect(origin: .zero, size: size)
		
		if let backgroundColor = backgroundColor {
			let context = UIGraphicsGetCurrentContext()
			context?.setFillColor(backgroundColor.cgColor)
			context?.fill(rect)
		}
		
		//draw
		self.draw(in: rect)
		//capture resultant image
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image!
	}
	
	public func scaled(toFit size: CGSize, backgroundColor: UIColor? = nil) -> UIImage {
		//calculate rect
		let aspect: CGFloat = self.size.width / self.size.height
		if size.width / aspect <= size.height {
			return self.scaled(to: CGSize(width: size.width, height: size.width / aspect), backgroundColor: backgroundColor)
		}
		else {
			return self.scaled(to: CGSize(width: size.height * aspect, height: size.height), backgroundColor: backgroundColor)
		}
	}
	
	public func scaled(toWidth newWidth: CGFloat, backgroundColor: UIColor? = nil) -> UIImage {
		let aspect: CGFloat = self.size.width / newWidth
		let newHeight: CGFloat = self.size.height * aspect
		
		return self.scaled(to: CGSize(width: newWidth, height: newHeight))
	}

}
