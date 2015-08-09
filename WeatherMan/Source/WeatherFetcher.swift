//
//  WeatherFetcher.swift
//  WeatherMan
//
//  Created by Brian Stern on 8/8/15.
//  Copyright (c) 2015 Brian Stern. All rights reserved.
//

import UIKit

let maxTemp = "maxt"
let minTemp = "mint"
let temperature = "temp"
let icons = "wx"

public class WeatherFetcher: NSObject {
	
	let noaaURL = "http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdXMLclient.php"
	var session:NSURLSession
	var dateFormatter:NSDateFormatter!

	// example
	// http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdXMLclient.php?zipCodeList=40324&product=glance&begin=2015-08-08T00:00:00&end=2015-08-10T00:00:00&maxt=maxt&mint=mint&temp=temp&wx=wx

//	let noaaURL = "http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdXMLclient.php?zipCodeList=40324&product=glance&begin=2015-08-09T00:00:00&end=2015-08-10T00:00:00&maxt=maxt&mint=mint&temp=temp&wx=wx"
	
	public override init() {
		session = NSURLSession.sharedSession()
		super.init()
		buildDateFormatter()
	}
	
	func buildDateFormatter() {
		
		dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-ddTHH:mm:ss"
	}
	
	public func fetchWeatherForZipCode(zipcode: String, startDate: NSDate, endDate:NSDate, completion: (Array<Weather>?, NSError?) -> Void) {
		
		let begin = dateFormatter.stringFromDate(startDate)
		let end = dateFormatter.stringFromDate(endDate)
		let parameters = [ "zipCodeList" : zipcode, "product" : "glance", "begin" : begin, "end" : end,
			maxTemp : maxTemp, minTemp : minTemp, temperature : temperature, icons : icons]
		let urlString = noaaURL + parameterStringFromDictionary(parameters)
		
		println("\(urlString)")
		
		if let url = NSURL(string: urlString) {
			let request = NSURLRequest(URL: url)
			
			let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
				println("error : \(error)")
				
				if error == nil {
					
					let result = NSString(data: data, encoding: NSUTF8StringEncoding)
					completion(nil, nil)
					
				} else {
					println("error : \(error)")
					completion(nil, error)
					
				}
				
			})
			
			task.resume()
		}
	}
	
	public func parameterStringFromDictionary(parameters: Dictionary<String, String>) -> String {
		
		var parameterString = ""
		
		for (key, value) in parameters {
			if count(parameterString) == 0 {
				parameterString += "?\(key)=\(value)"
			} else {
				parameterString += "&\(key)=\(value)"
			}
		}
		
		return parameterString
	}
	
	
	
	
	
}
