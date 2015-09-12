//
//  DetailViewController.swift
//  WeatherMan
//
//  Created by Brian Stern on 8/8/15.
//  Copyright (c) 2015 Brian Stern. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {

	var objects = [AnyObject]()
	
	var weatherFetcher:WeatherFetcher?

	var detailItem: String? {
		didSet {
		    // Update the view.
			print("zipcode \(detailItem)")
			self.fetchWeather()
		    self.configureView()
		}
	}

	func configureView() {
		// Update the user interface for the detail item.
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.configureView()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: - Table View
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return objects.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
		
		let object = objects[indexPath.row] as! NSDate
		cell.textLabel!.text = object.description
		return cell
	}

	// MARK: - Weather
	
	func fetchWeather() {
		if weatherFetcher == nil {
			weatherFetcher = WeatherFetcher()
		}
		
		let startDate = NSDate()
		let endDate = NSDate()
		let zipcode = detailItem!
		
		weatherFetcher?.fetchWeatherForZipCode(zipcode, startDate: startDate, endDate: endDate, completion: { (result: Array<Weather>?, error: NSError?) -> Void in
			
			if (error == nil) {
				
			} else {

			}
			
		})
	}
	

}

