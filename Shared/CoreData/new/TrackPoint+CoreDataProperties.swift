//
//  TrackPoint+CoreDataProperties.swift
//  
//
//  Created by Oleg Komaristy on 17.07.2020.
//
//

import Foundation
import CoreData


extension TrackPoint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackPoint> {
        return NSFetchRequest<TrackPoint>(entityName: "TrackPoint")
    }

    @NSManaged public var elevation: Float
    @NSManaged public var speed: Float
    @NSManaged public var trackSegment: TrackSegment?

}
