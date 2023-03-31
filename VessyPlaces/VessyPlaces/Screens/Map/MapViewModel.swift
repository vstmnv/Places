//
//  MapViewModel.swift
//  VessyPlaces
//
//  Created by Vesela Stamenova on 17.03.23.
//

import Foundation
import CoreLocation
import Combine

final class MapViewModel: ObservableObject {

	struct PlaceAnnotation {
		let placeId: Int
		let coordinate: CLLocationCoordinate2D
		let name: String
	}

	@Published private(set) var coordinate: CLLocationCoordinate2D?
	@Published private(set) var selectedDetails: PlaceDetailsViewModel.Details?
	@Published private(set) var isNearMeButtonHidden: Bool = true
	@Published private(set) var isSearchFieldHidden: Bool = false
	@Published private(set) var isClearButtonHidden: Bool = false
	@Published private(set) var isCloseButtonHidden: Bool = true
	@Published private(set) var placeAnnotations: [PlaceAnnotation] = []
	private var cancellables: [AnyCancellable] = []

	init() {
		LocationManager.shared.$userCoordinate
			.receive(on: DispatchQueue.main)
			.sink { [weak self] userCoordinate in
				if self?.selectedDetails == nil {
					self?.coordinate = userCoordinate
					self?.getLocalRestaurants()
				}
			}
			.store(in: &cancellables)
	}

	func setSelectedRestaurant(details: PlaceDetailsViewModel.Details) {
		self.selectedDetails = details
		isSearchFieldHidden = true
		isClearButtonHidden = true
		isCloseButtonHidden = false
	}

	func requestLocationPermission() {
		LocationManager.shared.requestLocationPermission()
	}

	func setCoordinateToMyLocation() {
		coordinate = LocationManager.shared.userCoordinate
	}

	func getPlaceId(latitude: Double, longitude: Double) -> Int? {
		let place = placeAnnotations.first { $0.coordinate.latitude == latitude && $0.coordinate.longitude == longitude }
		return place?.placeId
	}

	func getLocalRestaurants() {
		guard let userCoordinate = LocationManager.shared.userCoordinate, selectedDetails == nil else {
			return
		}
		let placesServices = PlacesService()
		placesServices.getRestaurantsNearMe(lat: userCoordinate.latitude, lon: userCoordinate.longitude) { [weak self] places, error in
			if let places {
				let filteredPlaces = places.filter { $0.address.amenity != nil }
				self?.placeAnnotations = filteredPlaces.map({ place in
					let coordinate = CLLocationCoordinate2D(latitude: Double(place.lat) ?? 0, longitude: Double(place.lon) ?? 0)
					return PlaceAnnotation(placeId: place.place_id, coordinate: coordinate, name: place.address.amenity ?? "")
				})
				self?.isNearMeButtonHidden = true
				self?.isClearButtonHidden = false
			}
		}
	}
}

