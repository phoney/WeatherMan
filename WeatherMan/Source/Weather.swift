//
//  Weather.swift
//  WeatherMan
//
//  Created by Brian Stern on 8/8/15.
//  Copyright (c) 2015 Brian Stern. All rights reserved.
//
// This is a simple data model object to represent a day's weather forecast.

import UIKit

public class Weather: NSObject {
	
	var minTemp:Int = 0
	var maxTemp:Int = 0
	var weatherSummary:String = ""
	var conditionsIconLink:String = ""
	var time:String = ""

}
