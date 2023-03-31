//
//  placeCell.swift
//  VessyPlaces
//
//  Created by Vesela Stamenova on 17.03.23.
//
import Foundation
import UIKit

final class PlaceCell: UITableViewCell {

	@IBOutlet private weak var placeLabel: UILabel!
	@IBOutlet private weak var distanceLabel: UILabel!

	func configure(placeCellViewModel: PlaceCellViewModel) {
		placeLabel.text = placeCellViewModel.placeName
		distanceLabel.text = placeCellViewModel.distance
	}
}
