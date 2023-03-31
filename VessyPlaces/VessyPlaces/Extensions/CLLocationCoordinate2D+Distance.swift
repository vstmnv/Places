//
//  CLLocationCoordinate2D+Distance.swift
//  VessyPlaces
//
//  Created by Vesela Stamenova on 20.03.23.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
	func distance(to: CLLocationCoordinate2D) -> Double {
		let firstLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
		let secondLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
		return firstLocation.distance(from: secondLocation)
	}
}
