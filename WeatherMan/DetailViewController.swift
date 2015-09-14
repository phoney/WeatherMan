//
//  DetailViewController.swift
//  WeatherMan
//
//  Created by Brian Stern on 8/8/15.
//  Copyright (c) 2015 Brian Stern. All rights reserved.
//
//	TableView of the weather forecast for the next seven days.

import UIKit
import Haneke

class DetailViewController: UITableViewController {

	var detailItem: String? = nil {
		didSet {
			print("zipcode \(detailItem)")
			self.fetchWeather()
		}
	}
	private var objects = [Weather]()
	private lazy var weatherFetcher:WeatherFetcher = WeatherFetcher()

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		print("zipcode \(detailItem)")
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
		
		if let url = NSURL(string: weather.conditionsIconLink) {
			cell.iconView.hnk_setImageFromURL(url)
		} else {
			cell.iconView.image = nil
		}

		return cell
	}
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if let zipcode = detailItem {
			return "Weather for " + zipcode
		}
		return nil
	}
	
	// MARK: - Weather
	
	private func fetchWeather() {
		// on iPhone the DetailViewController isn't shown without a valid zipcode
		// on iPad the DetailViewController is always shown
		if let zipcode = detailItem {
			let startDate = NSDate()
			let endDate = NSDate()
			
			weatherFetcher.fetchWeatherForZipCode(zipcode, startDate: startDate, endDate: endDate, completion: { (result: Array<Weather>?, error: NSError?) -> Void in
				
				if (error == nil) {
					self.objects = result!
					self.tableView.reloadData()
				} else {
					self.objects = [Weather]()
					self.tableView.reloadData()

					print(error!)
					AlertHelper.showErrorAlert(error!)
				}
			})
		}
	}

}

