//
//  PointViewModel.swift
//  Geotracker-SwiftUI
//
//  Created by Oleg Komaristy on 17.06.2020.
//  Copyright © 2020 Oleg Komaristy. All rights reserved.
//

import Foundation
import CoreLocation
//import GeoTrackerCore
//
//class PointViewModel {
////	private var point: TrackerPoint
//
//	public var latitude: Double {
//		return point.latitude
//	}
//
//	public var longitude: Double {
//		return point.longitude
//	}
//
//	public var timestamp: Int64 {
//		return point.timestamp
//	}
//
//	public var id: String {
//		return point.id
//	}
//
//	public var description: String {
//		return "Latitude: \(self.latitude)\nLongitude: \(self.longitude)"
//	}
//
////	public init(from point: TrackerPoint) {
////		self.point = point
////	}
//}
//
//extension PointViewModel {
//	public var toCLLocationCoordinate: CLLocationCoordinate2D {
//		return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
//	}
//
//	public func dateString() -> String {
//		return Date().stringfromTimeStamp(self.timestamp)
//	}
//}
//
//extension PointViewModel: Comparable {
//	static func < (lhs: PointViewModel, rhs: PointViewModel) -> Bool {
//		return lhs.timestamp < rhs.timestamp
//	}
//
//	static func == (lhs: PointViewModel, rhs: PointViewModel) -> Bool {
//		return lhs.id == rhs.id
//	}
//}
//
//extension PointViewModel: Hashable {
//	func hash(into hasher: inout Hasher) {
//		hasher.combine(self.latitude)
//		hasher.combine(self.longitude)
//		hasher.combine(self.timestamp)
//	}
//}
