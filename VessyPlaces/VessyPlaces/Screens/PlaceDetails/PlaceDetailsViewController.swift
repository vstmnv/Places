//
//  PlaceDetailsViewController.swift
//  VessyPlaces
//
//  Created by Vesela Stamenova on 19.03.23.
//

import UIKit
import Combine

final class PlaceDetailsViewController: UIViewController {

	private var viewModel: PlaceDetailsViewModel?
	private var cancellables: [AnyCancellable] = []

	@IBOutlet private weak var nameLabel: UILabel!
	@IBOutlet private weak var cuisineLabel: UILabel!
	@IBOutlet private weak var capacityLabel: UILabel!
	@IBOutlet private weak var emailLabel: UILabel!
	@IBOutlet private weak var phoneLabel: UILabel!
	@IBOutlet private weak var hoursLabel: UILabel!
	@IBOutlet private weak var websiteLabel: UILabel!

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.placeDetailsViewController.showMap.identifier:
			if let mapViewController = segue.destination as? MapViewController,
			   let details = sender as? PlaceDetailsViewModel.Details {
				mapViewController.configure(details: details)
			}
		default:
			break
		}
	}

	func configure(viewModel: PlaceDetailsViewModel) {
		self.viewModel = viewModel
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if let viewModel {
			viewModel.$details
				.receive(on: DispatchQueue.main)
				.sink { [weak self] details in
					self?.nameLabel.text = details?.name
					self?.cuisineLabel.text = details?.cuisine
					self?.capacityLabel.text = details?.capacity
					self?.emailLabel.text = details?.email
					self?.phoneLabel.text = details?.phone
					self?.hoursLabel.text = details?.openingHours
					self?.websiteLabel.text = details?.website
				}
				.store(in: &cancellables)
			viewModel.getDetails()
		}
	}

	@IBAction private func findOnMap(sender: UIButton) {
		if let details = viewModel?.details {
			performSegue(withIdentifier: R.segue.placeDetailsViewController.showMap, sender: details)
		}
	}
}
