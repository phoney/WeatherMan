//
//  WeatherFetcher.swift
//  WeatherMan
//
//  Created by Brian Stern on 8/8/15.
//  Copyright (c) 2015 Brian Stern. All rights reserved.
//
// http://graphical.weather.gov/xml/rest.php

import UIKit

let maxTemp = "maxt"
let minTemp = "mint"
let temperature = "temp"
let icons = "wx"
let format = "24+hourly"
let numDays = "10"


public class WeatherFetcher: NSObject {
	
	let noaaURL = "http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdBrowserClientByDay.php"
	var session:NSURLSession
	var dateFormatter:NSDateFormatter!

	// example
	// http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdXMLclient.php?zipCodeList=40324&product=glance&begin=2015-08-08T00:00:00&end=2015-08-10T00:00:00&maxt=maxt&mint=mint&temp=temp&wx=wx

	// let noaaURL = "http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdBrowserClientByDay.php?zipCodeList=20910+25414&format=24+hourly&numDays=7"
	
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
		
		let parameters = [ "zipCodeList" : zipcode, "format" : format, "numDays" : numDays ]
		let urlString = noaaURL + parameterStringFromDictionary(parameters)

#if DEBUG
		println("\(urlString)")
#endif
		
		if let url = NSURL(string: urlString) {
			let request = NSURLRequest(URL: url)
			
			let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
				
				if error == nil {
					
					var resultList:Array<Weather>
					
					if let dictionary = XMLReader.dictionaryForXMLData(data) as? Dictionary<NSObject, NSObject> {
						resultList = self.weatherListFromWeatherDictionary(dictionary)
						completion(resultList, nil)
					} else {
						// TODO: Need to get the parse error
						completion(nil, nil)
					}
					
				} else {
					print("error : \(error)")
					completion(nil, error)
				}
				
			})
			
			task.resume()
		}
	}
	
	func weatherListFromWeatherDictionary(weatherDictionary: Dictionary<NSObject, NSObject>) -> Array<Weather> {
		
		let parameters = parametersFromWeatherDictionary(weatherDictionary)
		let maximumTemperatures = temperatureFromParametersDictionary(parameters, index: 0)
		let minimumTemperatures = temperatureFromParametersDictionary(parameters, index: 1)
		let iconLinks = iconLinksFromParametersDictionary(parameters)
		let weatherSummaries = weatherSummariesFromParametersDictionary(parameters)
		
		var resultList:Array<Weather> = []
		let count = minimumTemperatures.count - 1
		
		for i in 0...count {
			let weather = Weather()

			if let minTemp = minimumTemperatures[i] as? NSString {
				weather.minTemp = minTemp.integerValue
			}

			if let maxTemp = maximumTemperatures[i] as? NSString {
				weather.maxTemp = maxTemp.integerValue
			}

			if let conditionsIconLink = iconLinks[i] as? NSString {
				weather.conditionsIconLink = conditionsIconLink as String
			}

			if let weatherSummary = weatherSummaries[i] as? Dictionary<NSObject, NSObject> {
				if let weatherSummary = weatherSummary["@weather-summary"] as? NSString {
					weather.weatherSummary = weatherSummary as String
				}
			}

			resultList.append(weather)
		}
		
		return resultList
	}
	
	func parametersFromWeatherDictionary(weatherDictionary: Dictionary<NSObject, NSObject>) -> Dictionary<NSObject, NSObject> {
		if let dwml = weatherDictionary["dwml"] as? Dictionary<NSObject, NSObject> {
			// Convert Dictionary to array of Weather
			if let data:Dictionary<NSObject, NSObject> = dwml["data"] as? Dictionary<NSObject, NSObject> {
				if let parameters = data["parameters"] as? Dictionary<NSObject, NSObject> {
					return parameters
				}
			}
		}
		
		return [:]
	}

	func temperatureFromParametersDictionary(parameters: Dictionary<NSObject, NSObject>, index:Int) -> NSArray {
		if let temperatures = parameters["temperature"] as? NSArray {
			if (temperatures.count > index && index >= 0) {
				if let temperatureInfo = temperatures[index] as? Dictionary<NSObject, NSObject> {
					if let values = temperatureInfo["value"] as? NSArray {
						return values
					}
				}
			}
		}
		
		return []
	}

	func iconLinksFromParametersDictionary(parameters: Dictionary<NSObject, NSObject>) -> NSArray {
		if let conditions = parameters["conditions-icon"] as? NSDictionary {
			if let iconLinks = conditions["icon-link"] as? NSArray {
				return iconLinks
			}
		}
		
		return []
	}

	func weatherSummariesFromParametersDictionary(parameters: Dictionary<NSObject, NSObject>) -> NSArray {
		if let weather = parameters["weather"] as? NSDictionary {
			if let weatherSummaries = weather["weather-conditions"] as? NSArray {
				return weatherSummaries
			}
		}
		
		return []
	}

	public func parameterStringFromDictionary(parameters: Dictionary<String, String>) -> String {
		
		var parameterString = ""
		
		for (key, value) in parameters {
			if parameterString.characters.count == 0 {
				parameterString += "?\(key)=\(value)"
			} else {
				parameterString += "&\(key)=\(value)"
			}
		}
		
		return parameterString
	}
	
	// For debugging
	func saveXMLToFile(data:NSData) {
		
		let result = NSString(data: data, encoding: NSUTF8StringEncoding)
		
		let documentsPath: AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
		let datapath = documentsPath.stringByAppendingPathComponent("data.xml")
		data.writeToFile(datapath, atomically: false)
		let stringPath = documentsPath.stringByAppendingPathComponent("string.xml")
		do {
			try result?.writeToFile(stringPath, atomically: false, encoding: NSUTF8StringEncoding)
		} catch _ {
		}
		
		print("\(stringPath)")
	}
	
	
	
	
	
}
