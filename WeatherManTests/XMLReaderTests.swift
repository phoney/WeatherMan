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
		let path2 = pathForResourceTest("simple.xml", ofType: nil)
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
		let path2 = pathForResourceTest("string.xml", ofType: nil)
		if let path = path2 {
			let xmlString = try? String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
			if let xmlString = xmlString {
				xmlDictionary = XMLReader.dictionaryForXMLString(xmlString)
			}
		}
		
		XCTAssertNotNil(xmlDictionary, "Fail")
	}
	
	func pathForResourceTest(name: String?, ofType ext: String?) -> String? {
		let bundle = NSBundle(forClass: self.dynamicType)
		let path2 = bundle.pathForResource(name, ofType: ext)
		return path2
	}
	

}
