//
//  SearchTableViewCell.swift
//  VessyPlaces
//
//  Created by Vesela Stamenova on 18.03.23.
//

import UIKit

final class SearchTableViewCell: UITableViewCell {

	@IBOutlet private weak var addressLabel: UILabel!

	func configure(with address: String) {
		addressLabel.text = address
	}
}
