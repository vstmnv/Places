//
//  APIManager.swift
//  VessyPlaces
//
//  Created by Vesela Stamenova on 17.03.23.
//

import Foundation

final class APIManager {

	private enum Constant {
		static let apiUrl = "https://nominatim.openstreetmap.org/"
	}

	private let session = URLSession(configuration: .default)
	private var dataTask: URLSessionDataTask?

	func run(path: String, queryItems: [URLQueryItem] = [], completion: @escaping (Data?, Error?) -> Void) {
		guard let url = URL(string: Constant.apiUrl) else {
			completion(nil, InternalError())
			return
		}
		let urlWithPathAndQuery = url.appending(path: path).appending(queryItems: queryItems)
		run(url: urlWithPathAndQuery, completion: completion)
	}

	func run(url: URL, completion: @escaping (Data?, Error?) -> Void) {
		dataTask?.cancel()
		let request = URLRequest(url: url)
		dataTask = session.dataTask(with: request) { data, _, error in
			DispatchQueue.main.async {
				completion(data, error)
			}
		}
		dataTask?.resume()
	}
}

final class InternalError: Error {}
