//
//  MapViewController.swift
//  VessyPlaces
//
//  Created by Vesela Stamenova on 17.03.23.
//

import UIKit
import MapKit
import CoreLocation
import Combine


final class MapViewController: UIViewController {

	@IBOutlet private weak var mapView: MKMapView!
	@IBOutlet private weak var searchField: UISearchBar!
	@IBOutlet private weak var searchResultsTable: UITableView!
	@IBOutlet private weak var getNearMeButton: UIButton!
	@IBOutlet private weak var clearButton: UIButton!
	@IBOutlet private weak var closeButton: UIButton!

	private let searchCompleter = MKLocalSearchCompleter()
	private let viewModel = MapViewModel()
	private var cancellables: [AnyCancellable] = []
	private var searchSuggestions: [MKLocalSearchCompletion] = []

	override func viewDidLoad() {
		super.viewDidLoad()

		mapView.delegate = self
		searchField.delegate = self
		searchCompleter.delegate = self
		viewModel.requestLocationPermission()

		viewModel.$coordinate
			.receive(on: DispatchQueue.main)
			.sink { [weak self] coordinate in
				self?.centerMap(on: coordinate)
			}
			.store(in: &cancellables)

		viewModel.$isSearchFieldHidden
			.receive(on: DispatchQueue.main)
			.sink { [weak self] isSearchFieldHidden in
				self?.searchField.isHidden = isSearchFieldHidden
			}
			.store(in: &cancellables)

		viewModel.$isClearButtonHidden
			.receive(on: DispatchQueue.main)
			.sink { [weak self] isClearButtonHidden in
				self?.clearButton.isHidden = isClearButtonHidden
			}
			.store(in: &cancellables)

		viewModel.$isCloseButtonHidden
			.receive(on: DispatchQueue.main)
			.sink { [weak self] isCloseButtonHidden in
				self?.closeButton.isHidden = isCloseButtonHidden
			}
			.store(in: &cancellables)

		viewModel.$isNearMeButtonHidden
			.receive(on: DispatchQueue.main)
			.sink { [weak self] isNearMeButtonHidden in
				self?.getNearMeButton.isHidden = isNearMeButtonHidden
			}
			.store(in: &cancellables)

		viewModel.$selectedDetails
			.receive(on: DispatchQueue.main)
			.sink { [weak self] selectedDetails in
				if let selectedDetails {
					let coordinate = CLLocationCoordinate2D(latitude: selectedDetails.latitude, longitude: selectedDetails.longitude)
					self?.addSingleAnnotation(coordinate: coordinate, title: selectedDetails.name)
					self?.centerMap(on: coordinate)
				}
			}
			.store(in: &cancellables)

		viewModel.$placeAnnotations
			.receive(on: DispatchQueue.main)
			.sink { [weak self] placeAnnotations in
				self?.addMultipleAnnotations(placeAnnotations: placeAnnotations)
			}
			.store(in: &cancellables)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case R.segue.mapViewController.showDetails.identifier:
			if let detailsController = segue.destination as? PlaceDetailsViewController,
			   let placeId = sender as? Int {
				let viewModel = PlaceDetailsViewModel(placeId: placeId)
				detailsController.configure(viewModel: viewModel)
			}
		default:
			break
		}
	}

	func configure(details: PlaceDetailsViewModel.Details) {
		viewModel.setSelectedRestaurant(details: details)
	}

	func search(for text: String) {
		setSearchSuggestions(to: [])
		searchField.text = text
		let searchRequest = MKLocalSearch.Request()
		searchRequest.naturalLanguageQuery = text
		searchRequest.region = mapView.region
		let search = MKLocalSearch(request: searchRequest)
		search.start { [weak self] (response, error) in
			if let error = error {
				print("Error searching: \(error.localizedDescription)")
				return
			}
			guard let response = response else {
				return
			}
			if !response.mapItems.isEmpty {
				self?.addMultipleAnnotations(mapItems: response.mapItems)
			} else if let coordinate = response.mapItems.first?.placemark.location?.coordinate,
					  let title = response.mapItems.first?.name {
				self?.addSingleAnnotation(coordinate: coordinate, title: title)
			}
		}
	}

	func addSingleAnnotation(coordinate: CLLocationCoordinate2D, title: String?) {
		let singleAnnotation = MKPointAnnotation()
		singleAnnotation.coordinate = coordinate
		singleAnnotation.title = title
		removePreviousAnnotations()
		mapView.addAnnotation(singleAnnotation)
	}

	func addMultipleAnnotations(placeAnnotations: [MapViewModel.PlaceAnnotation]) {
		var annotations = [MKAnnotation]()
		for item in placeAnnotations {
			let annotation = MKPointAnnotation()
			annotation.coordinate = item.coordinate
			annotation.title = item.name
			annotations.append(annotation)
		}
		mapView.addAnnotations(annotations)
		mapView.showAnnotations(annotations, animated: true)
	}

	func addMultipleAnnotations(mapItems: [MKMapItem]) {
		getNearMeButton.isHidden = true
		var annotations = [MKAnnotation]()
		for item in mapItems {
			let annotation = MKPointAnnotation()
			annotation.coordinate = item.placemark.coordinate
			annotation.title = item.name
			annotation.subtitle = item.placemark.title
			annotations.append(annotation)
		}
		mapView.addAnnotations(annotations)
		mapView.showAnnotations(annotations, animated: true)
	}


	func removePreviousAnnotations() {
		let previousAnnotations = mapView.annotations
		mapView.removeAnnotations(previousAnnotations)
	}

	func setSearchSuggestions(to suggestions: [MKLocalSearchCompletion]) {
		searchSuggestions = suggestions
		searchResultsTable.isHidden = searchSuggestions.isEmpty
		searchResultsTable.reloadData()
	}

	func centerMap(on coordinate: CLLocationCoordinate2D?) {
		if let coordinate {
			mapView.centerCoordinate = coordinate
			mapView.camera = .init(lookingAtCenter: coordinate, fromDistance: 5000, pitch: 0, heading: 0)
		}
	}

	@IBAction private func locateMe(sender: UIButton) {
		viewModel.setCoordinateToMyLocation()
	}

	@IBAction private func getNearMe(sender: UIButton) {
		viewModel.getLocalRestaurants()
	}

	@IBAction private func tabGesture(sender: UIButton) {
		searchField.endEditing(true)
		setSearchSuggestions(to: [])
	}

	@IBAction private func myButtonTapped(_ sender: UIButton) {
		mapView.removeAnnotations(mapView.annotations)
		clearButton.isHidden = true
		getNearMeButton.isHidden = false
	}

	@IBAction private func close(_ sender: UIButton) {
		dismiss(animated: true)
	}
}

extension MapViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		searchSuggestions.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.searchCell, for: indexPath) else {
			return UITableViewCell()
		}
		cell.configure(with: searchSuggestions[indexPath.row].title)
		return cell
	}
}

extension MapViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let searchText = searchSuggestions[indexPath.row].title
		search(for: searchText)
		searchField.endEditing(true)
		clearButton.isHidden = false
	}
}

extension MapViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchText.isEmpty {
			setSearchSuggestions(to: [])
		} else {
			searchCompleter.queryFragment = searchText
		}
	}
}

extension MapViewController: MKLocalSearchCompleterDelegate {
	func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
		setSearchSuggestions(to: completer.results)
	}
}

extension MapViewController: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
		if let placeId = viewModel.getPlaceId(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude) {
			performSegue(withIdentifier: R.segue.mapViewController.showDetails, sender: placeId)
		}
	}
}
