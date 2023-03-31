//
//  VessyPlacesService.swift
//  VessyPlaces
//
//  Created by Vesela Stamenova on 17.03.23.
//

import Foundation

final class PlacesService {

	private enum Constant {
		static let format = "format"
		static let limit = "limit"
		static let query = "q"
		static let jsonFormat = "json"
		static let extraTags = "extratags"
		static let addressDetails = "addressdetails"
		static let placeId = "place_id"
		static let restaurant = "restaurant"
		static let limitValue = "50"
		static let enabled = "1"
		static let viewBox = "viewbox"
		static let bounded = "bounded"
		static let order = "order"
	}

	func getRestaurantsNearMe(lat: Double, lon: Double, completion: @escaping ([Place]?, Error?) -> Void) {
		let apiManager = APIManager()

		let radius = 0.01
		let left = lon - radius
		let bottom = lat - radius
		let right = lon + radius
		let top = lat + radius

		apiManager.run(
			path: "search",
			queryItems: [
				URLQueryItem(name: Constant.format, value: Constant.jsonFormat),
				URLQueryItem(name: Constant.limit, value: Constant.limitValue),
				URLQueryItem(name: Constant.query, value: Constant.restaurant),
				URLQueryItem(name: Constant.viewBox, value: "\(left),\(top),\(right),\(bottom)"),
				URLQueryItem(name: Constant.bounded, value: Constant.enabled),
				URLQueryItem(name: Constant.addressDetails, value: Constant.enabled),
				URLQueryItem(name: Constant.order, value: "distance")
			]
		) { data, error in
			guard let data = data else {
				completion(nil, error)
				return
			}
			let decoder = JSONDecoder()
			do {
				let locations = try decoder.decode([Place].self, from: data)
				completion(locations, nil)
			} catch {
				completion(nil, error)
			}
		}
	}

	func getDetails(for placeId: Int, completion: @escaping (PlaceDetails?, Error?) -> Void) {
		let apiManager = APIManager()
		apiManager.run(
			path: "details",
			queryItems: [
				URLQueryItem(name: Constant.format, value: Constant.jsonFormat),
				URLQueryItem(name: Constant.addressDetails, value: Constant.enabled),
				URLQueryItem(name: Constant.extraTags, value: Constant.enabled),
				URLQueryItem(name: Constant.placeId, value: "\(placeId)")
			]
		) { data, error in
			guard let data = data else {
				completion(nil, error)
				return
			}
			let decoder = JSONDecoder()
			do {
				let details = try decoder.decode(PlaceDetails.self, from: data)
				completion(details, nil)
			} catch {
				completion(nil, error)
			}
		}
	}
}
