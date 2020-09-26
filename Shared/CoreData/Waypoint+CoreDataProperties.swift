//
//  Waypoint+CoreDataProperties.swift
//  
//
//  Created by Oleg Komaristy on 26.07.2020.
//
//

import Foundation
import CoreData
import CoreLocation

extension Waypoint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Waypoint> {
        return NSFetchRequest<Waypoint>(entityName: "Waypoint")
    }

    @NSManaged public var comment: String?
    @NSManaged public var elevation: Float
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var speed: Float
    @NSManaged public var time: Int64
    @NSManaged public var desc: String?
    @NSManaged public var gpxEntity: GPXEntity?

}

extension Waypoint: PointProtocol {
	var coordinate: CLLocationCoordinate2D {
		get { return CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
		set {  }
	}
}
