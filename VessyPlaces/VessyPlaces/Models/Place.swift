//
//  Place.swift
//  VessyPlaces
//
//  Created by Vesela Stamenova on 17.03.23.
//

import Foundation

struct Place: Decodable {
	let place_id: Int
	let display_name: String
	let lat: String
	let lon: String
	let address: Address
}

struct Address: Decodable {
	let amenity: String?
}
