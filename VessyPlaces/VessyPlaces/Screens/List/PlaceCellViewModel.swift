//
//  PlaceCellViewModel.swift
//  VessyPlaces
//
//  Created by Vesela Stamenova on 19.03.23.
//

import Foundation
import CoreLocation

final class PlaceCellViewModel {

	let placeName: String
	let distance: String

	init(place: Place) {
		if let placeAmenity = place.address.amenity {
			placeName = placeAmenity
		} else {
			placeName = ""
		}
		if let userCoordinate = LocationManager.shared.userCoordinate {
			let placeLocation = CLLocationCoordinate2D(latitude: Double(place.lat) ?? 0.0, longitude: Double(place.lon) ?? 0.0)
			let distanceInMeters = userCoordinate.distance(to: placeLocation)
			let distanceInKilometers = distanceInMeters / 1000.0
			distance = String(format: "%.1fkm", distanceInKilometers)
		} else {
			distance = ""
		}
	}
}
