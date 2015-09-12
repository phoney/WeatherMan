//
//  XMLReaderTests.swift
//  WeatherMan
//
//  Created by Brian Stern on 8/9/15.
//  Copyright (c) 2015 Brian Stern. All rights reserved.
//

import UIKit
import XCTest
import WeatherMan

class XMLReaderTests: XCTestCase {
	
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testParseString() {
		
		var xmlDictionary: Dictionary<NSObject, AnyObject>?
		let bundle = NSBundle(forClass: self.dynamicType)
		let path2 = bundle.pathForResource("simple.xml", ofType: nil)
		if let path = path2 {
			let xmlString = try? String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
			if let xmlString = xmlString {
				xmlDictionary = XMLReader.dictionaryForXMLString(xmlString)
			}
		}
		
		XCTAssertNotNil(xmlDictionary, "Fail")
    }
	
	
	func testParseWeatherData() {
		
		var xmlDictionary: Dictionary<NSObject, AnyObject>?
		let bundle = NSBundle(forClass: self.dynamicType)
		let path2 = bundle.pathForResource("string.xml", ofType: nil)
		if let path = path2 {
			let xmlString = try? String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
			if let xmlString = xmlString {
				xmlDictionary = XMLReader.dictionaryForXMLString(xmlString)
			}
		}
		
		XCTAssertNotNil(xmlDictionary, "Fail")
	}
	

}
