//
//  MasterViewController.swift
//  WeatherMan
//
//  Created by Brian Stern on 8/8/15.
//  Copyright (c) 2015 Brian Stern. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController, UITextFieldDelegate {

	@IBOutlet weak var zipcodeTextField: UITextField!
	@IBOutlet weak var fetchWeatherButton: UIButton!
	var detailViewController: DetailViewController? = nil

	override func awakeFromNib() {
		super.awakeFromNib()
		if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
		    self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		if let split = self.splitViewController {
		    let controllers = split.viewControllers
			let navigationController = controllers[controllers.count-1] as! UINavigationController
			self.detailViewController = navigationController.topViewController as? DetailViewController
		}
		
		updateFetchWeatherButton()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func updateFetchWeatherButton() {
		self.fetchWeatherButton.enabled = isValidZipCode(zipcodeTextField.text!)
	}

	// MARK: - Textfield

	// return NO to not change text
	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		// We're using the numberpad so no need to validate that the string is numbers only
		let zipcodeText = zipcodeTextField.text! as NSString
		let resultText = zipcodeText.stringByReplacingCharactersInRange(range, withString: string) as String
		let valid = resultText.characters.count <= 5
		
		return valid
	}

	@IBAction func textFieldDidChange(sender: UITextField) {
		updateFetchWeatherButton()
	}
	
	func isValidZipCode(zipcode: String ) -> Bool {
		let length = zipcode.characters.count
		return length == 5
	}

	// MARK: - Segues

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showDetail" {
			if let zipcode = self.zipcodeTextField.text {
		        let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
		        controller.detailItem = zipcode
		        controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
		        controller.navigationItem.leftItemsSupplementBackButton = true
		    }
		}
	}

}

