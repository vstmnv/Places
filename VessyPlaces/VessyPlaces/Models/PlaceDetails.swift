//
//  PlaceDetails.swift
//  VessyPlaces
//
//  Created by Vesela Stamenova on 19.03.23.
//

import Foundation

struct PlaceDetails: Decodable {
	let localname: String
	let geometry: Geometry
	let extratags: ExtraTags
}

struct Geometry: Decodable {
	let coordinates: [Double]
}

struct ExtraTags: Decodable {

	enum CodingKeys: String, CodingKey {
		case cuisine
		case capacity
		case contactEmail = "contact:email"
		case phone = "contact:phone"
		case opening_hours
		case contactWebsite = "contact:website"
		case website
	}

	let cuisine: String?
	let capacity: String?
	let contactEmail: String?
	let phone: String?
	let opening_hours: String?
	let contactWebsite: String?
	let website: String?
}
