//
//  PlaceDetailsViewModel.swift
//  VessyPlaces
//
//  Created by Vesela Stamenova on 19.03.23.
//

import Foundation

final class PlaceDetailsViewModel: ObservableObject {

	private enum Constant {
		static let defaultValue = "No Information"
	}

	struct Details {
		let name: String
		let cuisine: String
		let capacity: String
		let email: String
		let phone: String
		let openingHours: String
		let website: String
		let latitude: Double
		let longitude: Double
	}

	private let placeId: Int
	@Published private(set) var details: Details?

	init(placeId: Int) {
		self.placeId = placeId
	}

	func getDetails() {
		let placesService = PlacesService()
		placesService.getDetails(for: placeId) { [weak self] details, error in
			if let details {
				self?.setDetails(place: details)
			}
		}
	}

	private func setDetails(place: PlaceDetails) {
		let name = place.localname
		let cuisine = place.extratags.cuisine ?? Constant.defaultValue
		let capacity = place.extratags.capacity ?? Constant.defaultValue
		let email = place.extratags.contactEmail ?? Constant.defaultValue
		let phone = place.extratags.phone ?? Constant.defaultValue
		let openingHours = place.extratags.opening_hours ?? Constant.defaultValue
		let website = place.extratags.website ?? place.extratags.contactWebsite ?? Constant.defaultValue
		let latitude = place.geometry.coordinates.last ?? 0
		let longitude = place.geometry.coordinates.first ?? 0
		details = Details(
			name: name,
			cuisine: cuisine,
			capacity: capacity,
			email: email,
			phone: phone,
			openingHours: openingHours,
			website: website,
			latitude: latitude,
			longitude: longitude
		)
	}
}
