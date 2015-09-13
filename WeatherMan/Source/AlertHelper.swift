//
//  AlertHelper.swift
//  WeatherMan
//
//  Created by Brian Stern on 9/13/15.
//  Copyright © 2015 Brian Stern. All rights reserved.
//
//	Helper class to display alerts.

import UIKit


class AlertHelper : NSObject {

	class func showAlertWithTitle(title:String, message: String) {
		let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK" )
		alert.show()
	}
	
	class func showErrorAlert(error: NSError) {
		if let userInfo = error.userInfo as? [NSString : NSObject] {
			if let message = userInfo[NSLocalizedDescriptionKey] as? String {
				let title = "Error"
				showAlertWithTitle(title, message: message)
			}
		}
	}

}

