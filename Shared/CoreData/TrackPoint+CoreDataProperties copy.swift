//
//  TrackPoint+CoreDataProperties.swift
//  
//
//  Created by Oleg Komaristy on 21.07.2020.
//
//

import Foundation
import CoreData
import CoreLocation

extension TrackPoint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackPoint> {
        return NSFetchRequest<TrackPoint>(entityName: "TrackPoint")
    }

    @NSManaged public var elevation: Float
    @NSManaged public var speed: Float
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var trackSegment: TrackSegment?

}

extension TrackPoint: PointProtocol {
	var coordinate: CLLocationCoordinate2D {
		get { return CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
		set {  }
	}
}
