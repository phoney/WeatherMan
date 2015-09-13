//
//  DetailViewController.swift
//  WeatherMan
//
//  Created by Brian Stern on 8/8/15.
//  Copyright (c) 2015 Brian Stern. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {

	var detailItem: String?
	var objects = [Weather]()
	lazy var weatherFetcher:WeatherFetcher = WeatherFetcher()

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		print("zipcode \(detailItem)")
		self.fetchWeather()
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
		let cell = tableView.dequeueReusableCellWithIdentifier("WeatherCell", forIndexPath: indexPath) as! WeatherCell
		
		let weather = objects[indexPath.row]
		cell.timeLabel.text = weather.time
		cell.forecastLabel.text = weather.weatherSummary
		cell.highTempLabel.text = "High " + String(weather.maxTemp)
		cell.lowTempLabel.text = "Low " + String(weather.minTemp)

		return cell
	}

	// MARK: - Weather
	
	func fetchWeather() {
		let startDate = NSDate()
		let endDate = NSDate()
		let zipcode = detailItem!
		
		weatherFetcher.fetchWeatherForZipCode(zipcode, startDate: startDate, endDate: endDate, completion: { (result: Array<Weather>?, error: NSError?) -> Void in
			
			if (error == nil) {
				dispatch_async(dispatch_get_main_queue()) {
					self.objects = result!
					self.tableView.reloadData()
				}
			} else {
				// TODO: Display error alert 
				dispatch_async(dispatch_get_main_queue()) {
					self.objects = [Weather]()
					self.tableView.reloadData()

					print(error!)
					AlertHelper.showErrorAlert(error!)
				}
			}
		})
	}

}

