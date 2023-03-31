//
//  ListViewModel.swift
//  VessyPlaces
//
//  Created by Vesela Stamenova on 17.03.23.
//

import Foundation
import CoreLocation

final class ListViewModel: ObservableObject {

	@Published private(set) var places: [Place] = []

	func getRestaurantsNearMe() {
		guard let coordinate = LocationManager.shared.userCoordinate else {
			return
		}
		PlacesService().getRestaurantsNearMe(lat: coordinate.latitude, lon: coordinate.longitude) { [weak self] places, error in
			if let error {
				print("Error: \(error.localizedDescription)")
				return
			}

			if let places {
				DispatchQueue.main.async {
					let filteredPlaces = places.filter { $0.address.amenity != nil }
					if let userCoordinate = LocationManager.shared.userCoordinate {
						let sortedPlaces = filteredPlaces.sorted(by: { place1, place2 in
							let placeLocation1 = CLLocationCoordinate2D(latitude: Double(place1.lat) ?? 0.0, longitude: Double(place1.lon) ?? 0.0)
							let placeLocation2 = CLLocationCoordinate2D(latitude: Double(place2.lat) ?? 0.0, longitude: Double(place2.lon) ?? 0.0)
							let distanceInMeters1 = userCoordinate.distance(to: placeLocation1)
							let distanceInMeters2 = userCoordinate.distance(to: placeLocation2)
							return distanceInMeters1 < distanceInMeters2
						})
						self?.places = sortedPlaces
					} else {
						self?.places = filteredPlaces
					}
				}
			}
		}
	}

	func requestLocationPermission() {
		LocationManager.shared.requestLocationPermission()
	}

	func cellViewModel(indexPath: IndexPath) -> PlaceCellViewModel {
		PlaceCellViewModel(place: places[indexPath.row])
	}
}
