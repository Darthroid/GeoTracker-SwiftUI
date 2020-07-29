//
//  PointProtocol.swift
//  GeoTracker-SwiftUI
//
//  Created by Oleg Komaristy on 25.07.2020.
//

import Foundation
import CoreLocation

protocol PointProtocol {
	var coordinate: CLLocationCoordinate2D { get set }
}
