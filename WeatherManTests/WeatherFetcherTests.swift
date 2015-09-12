//
//  WeatherFetcherTests.swift
//  WeatherMan
//
//  Created by Brian Stern on 8/8/15.
//  Copyright (c) 2015 Brian Stern. All rights reserved.
//

import UIKit
import XCTest
import WeatherMan

class WeatherFetcherTests: XCTestCase {

	let zipcode = "10011"
	var weatherFetcher:WeatherFetcher = WeatherFetcher()
	
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
//		weatherFetcher = WeatherFetcher()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFetchWeather() {

		let expectation = expectationWithDescription("testFetchWeather")
		let startDate = NSDate()
		let endDate = NSDate(timeIntervalSinceNow: 60 * 60 * 24)
		
		weatherFetcher.fetchWeatherForZipCode(zipcode, startDate: startDate, endDate: endDate, completion: { (result: Array<Weather>?, error: NSError?) -> Void in
				XCTAssertNil(error, "error can't be nil")
				
				expectation.fulfill()
		})

		waitForExpectationsWithTimeout(30) { error in
		}
    }

	func testParameterStringTwoParameters() {
		
		let parameters = ["one": "one-value", "two" : "two-value"]
		let expected = "?one=one-value&two=two-value"
		let parameterString = weatherFetcher.parameterStringFromDictionary(parameters)
		
		XCTAssert(parameterString == expected, "Parameter String failure")
	}

	func testParameterStringNoParameters() {
		
		let parameters:Dictionary<String, String> = Dictionary()
		let expected = ""
		let parameterString = weatherFetcher.parameterStringFromDictionary(parameters)

		XCTAssert(parameterString == expected, "Parameter String failure")
	}

}
