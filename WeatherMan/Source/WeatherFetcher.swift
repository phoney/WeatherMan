//
//  WeatherFetcher.swift
//  WeatherMan
//
//  Created by Brian Stern on 8/8/15.
//  Copyright (c) 2015 Brian Stern. All rights reserved.
//
// http://graphical.weather.gov/xml/rest.php
// There are a number of different REST endpoints available at the NOAA site.
// BrowserClientByDay is the simplest one. Others can provide more data.
// This class fetches the data and parses the resulting xml into an array 
// of Weather objects.

import UIKit

let maxTemp = "maxt"
let minTemp = "mint"
let temperature = "temp"
let icons = "wx"
let format = "24+hourly"
let numDays = "10"


public class WeatherFetcher: NSObject {
	
	let noaaURL = "http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdBrowserClientByDay.php"
	private var session:NSURLSession
	private var dateFormatter:NSDateFormatter!
	private var weekdayFormatter:NSDateFormatter!

	// example
	// http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdXMLclient.php?zipCodeList=40324&product=glance&begin=2015-08-08T00:00:00&end=2015-08-10T00:00:00&maxt=maxt&mint=mint&temp=temp&wx=wx

	// let noaaURL = "http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdBrowserClientByDay.php?zipCodeList=20910+25414&format=24+hourly&numDays=7"
	
	public override init() {
		session = NSURLSession.sharedSession()
		super.init()
		buildDateFormatter()
	}
	
	private func buildDateFormatter() {
		
		dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-ddTHH:mm:ss"

		weekdayFormatter = NSDateFormatter()
		weekdayFormatter.dateFormat = "EEEE"
	}

	func fetchWeatherForZipCode(zipcode: String, startDate: NSDate, endDate:NSDate, completion: (Array<Weather>?, NSError?) -> Void) {
		
		let parameters = [ "zipCodeList" : zipcode, "format" : format ]
		let urlString = noaaURL + parameterStringFromDictionary(parameters)

#if DEBUG
	print("\(urlString)")
#endif
		
		if let url = NSURL(string: urlString) {
			let request = NSURLRequest(URL: url)
			
			let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
				
				var theError:NSError?
				var resultList:Array<Weather>?
				
				if error == nil {
					
					// The xml parser seems to fail intermittently with an 'Extra data at the end of the xml' error
					// when using the NSData that's returned from dataTaskWithRequest and converting to a
					// string seems to fix this.
					// The NSData object is an OS_Dispatch_data object and maybe there is some incompatibility between that
					// and the xml parser.
					let dataAsString = String(data: data!, encoding: NSUTF8StringEncoding)
					
					if let dictionary = XMLReader.dictionaryForXMLString(dataAsString!) as? Dictionary<NSObject, NSObject> {
						// Handle error response from server for bad zip code
						if !self.isErrorResponse(dictionary, error: &theError) {
							resultList = self.weatherListFromWeatherDictionary(dictionary)
						}
					} else {
						theError = self.unknownError()
					}
				} else {
					print("error : \(error)")
					theError = error
				}

				dispatch_async(dispatch_get_main_queue()) {
					completion(resultList, theError)
				}
			})
			
			task.resume()
		}
	}

	/*
		{
			error =     {
				h2 = ERROR;
				pre = "Point with latitude \"\" longitude \"\" is not on an NDFD grid";
			};
		}
	*/
	
	private func isErrorResponse(weatherDictionary: Dictionary<NSObject, NSObject>, error: NSErrorPointer) -> Bool {
		if let errorDictionary = weatherDictionary["error"] as? Dictionary<NSObject, NSObject> {
			if let errorText = errorDictionary["pre"] {
				if error != nil {
					error.memory = NSError(domain: "Weather", code: -2, userInfo: [NSLocalizedDescriptionKey : errorText])
				}
			} else {
				if error != nil {
					error.memory = unknownError()
				}
			}
			
			return true
		}
		return false
	}
	
	private func unknownError() -> NSError {
		return NSError(domain: "Weather", code: -1, userInfo: [NSLocalizedDescriptionKey : "Unknown Error"])
	}
	
	// MARK: - XML spelunking

	private func weatherListFromWeatherDictionary(weatherDictionary: Dictionary<NSObject, NSObject>) -> Array<Weather> {
		
		let parameters = parametersFromWeatherDictionary(weatherDictionary)
		let maximumTemperatures = temperatureFromParametersDictionary(parameters, index: 0)
		let minimumTemperatures = temperatureFromParametersDictionary(parameters, index: 1)
		let iconLinks = iconLinksFromParametersDictionary(parameters)
		let weatherSummaries = weatherSummariesFromParametersDictionary(parameters)
		let dayNames = dateListFromDate(NSDate(), numberOfDays: 10)
		
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

			if (i < iconLinks.count) {
				// Occasionally the icon links and weather summaries are missing from the xml
				if let conditionsIconLink = iconLinks[i] as? NSString {
					weather.conditionsIconLink = conditionsIconLink as String
				}
			}

			if (i < weatherSummaries.count) {
				if let weatherSummary = weatherSummaries[i] as? Dictionary<NSObject, NSObject> {
					if let weatherSummary = weatherSummary["@weather-summary"] as? NSString {
						weather.weatherSummary = weatherSummary as String
					}
				}
			}
			
			weather.time = dayNames[i]

			if (weather.maxTemp != 0 && weather.minTemp != 0) {
				// Sometimes the last weather data doesn't have the maxTemp or minTemp
				//  so it's better not to display it
				resultList.append(weather)				
			}
		}
		
		return resultList
	}
	
	private func parametersFromWeatherDictionary(weatherDictionary: Dictionary<NSObject, NSObject>) -> Dictionary<NSObject, NSObject> {
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

	private func temperatureFromParametersDictionary(parameters: Dictionary<NSObject, NSObject>, index:Int) -> NSArray {
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

	private func iconLinksFromParametersDictionary(parameters: Dictionary<NSObject, NSObject>) -> NSArray {
		if let conditions = parameters["conditions-icon"] as? NSDictionary {
			if let iconLinks = conditions["icon-link"] as? NSArray {
				return iconLinks
			}
		}
		
		return []
	}

	private func weatherSummariesFromParametersDictionary(parameters: Dictionary<NSObject, NSObject>) -> NSArray {
		if let weather = parameters["weather"] as? NSDictionary {
			if let weatherSummaries = weather["weather-conditions"] as? NSArray {
				return weatherSummaries
			}
		}
		
		return []
	}

	func parameterStringFromDictionary(parameters: Dictionary<String, String>) -> String {
		
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
	
	func dateListFromDate(date: NSDate, numberOfDays: Int) -> Array<String> {
		assert(numberOfDays > 0)
		var dates:Array<String> = []
		let calendar = NSCalendar.currentCalendar()
		let calendarUnits: NSCalendarUnit = [.Day, .Month, .Year]
		var day = date

		for _ in 0...numberOfDays {
			let dayOfWeek = weekdayFormatter.stringFromDate(day)
			dates.append(dayOfWeek)

			let dayInComponents = calendar.components(calendarUnits, fromDate: day)
			let dayOfMonth = dayInComponents.valueForComponent(.Day)
			
			dayInComponents.setValue(dayOfMonth + 1, forComponent: .Day)
			day = calendar.dateFromComponents(dayInComponents)!
		}
		
		if numberOfDays >= 1 {
			dates[0] = "Today"
			if numberOfDays >= 2 {
				dates[1] = "Tomorrow"
			}
		}
		
		return dates
	}
	
	// MARK: - Debugging

	private func saveXMLToFile(data:NSData) {
		
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
