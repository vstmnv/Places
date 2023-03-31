//
//  ViewController.swift
//  VessyPlaces
//
//  Created by Vesela Stamenova on 17.03.23.
//

import UIKit
import MapKit
import Combine

final class ListViewController: UITableViewController {

	@IBOutlet private weak var loadingBar: UIActivityIndicatorView!

	private let viewModel = ListViewModel()
	private var cancellables: [AnyCancellable] = []

	override func viewDidLoad() {
		super.viewDidLoad()

		viewModel.$places
			.receive(on: DispatchQueue.main)
			.sink { [weak self] places in
				self?.tableView.reloadData()
				self?.loadingBar.isHidden = true
			}
			.store(in: &cancellables)

		viewModel.getRestaurantsNearMe()
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.listViewController.showPlaceDetails.identifier:
			if let detailsController = segue.destination as? PlaceDetailsViewController,
			   let selectedPlace = sender as? Place {
				let viewModel = PlaceDetailsViewModel(placeId: selectedPlace.place_id)
				detailsController.configure(viewModel: viewModel)
			}
		default:
			break
		}
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedPlace = viewModel.places[indexPath.row]
		performSegue(withIdentifier: R.segue.listViewController.showPlaceDetails, sender: selectedPlace)
	}


	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.places.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.placeCell, for: indexPath) else {
			return UITableViewCell()
		}

		cell.configure(placeCellViewModel: viewModel.cellViewModel(indexPath: indexPath))
		return cell
	}
}
