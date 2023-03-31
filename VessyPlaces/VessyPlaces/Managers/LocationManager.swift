//
//  LocationManager.swift
//  VessyPlaces
//
//  Created by Vesela Stamenova on 19.03.23.
//

import Foundation
import CoreLocation

final class LocationManager: NSObject, ObservableObject {

	private let locationManager = CLLocationManager()
	@Published private(set) var userCoordinate: CLLocationCoordinate2D?
	static let shared = LocationManager()

	override init() {
		super.init()
		locationManager.delegate = self
	}

	func requestLocationPermission() {
		locationManager.requestWhenInUseAuthorization()
	}
}

extension LocationManager: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .authorizedWhenInUse {
			locationManager.startUpdatingLocation()
		}
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		userCoordinate = locations.last?.coordinate
		locationManager.stopUpdatingLocation()
	}
}

