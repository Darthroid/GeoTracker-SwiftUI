//
//  GPXEntity+CoreDataProperties.swift
//  
//
//  Created by Oleg Komaristy on 25.07.2020.
//
//

import Foundation
import CoreData


extension GPXEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GPXEntity> {
        return NSFetchRequest<GPXEntity>(entityName: "GPXEntity")
    }

    @NSManaged public var author: String?
    @NSManaged public var desc: String?
    @NSManaged public var email: String?
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var time: Int64
    @NSManaged public var url: String?
    @NSManaged public var tracks: NSSet?
    @NSManaged public var waypoints: NSOrderedSet?

}

// MARK: Generated accessors for tracks
extension GPXEntity {

    @objc(addTracksObject:)
    @NSManaged public func addToTracks(_ value: Track)

    @objc(removeTracksObject:)
    @NSManaged public func removeFromTracks(_ value: Track)

    @objc(addTracks:)
    @NSManaged public func addToTracks(_ values: NSSet)

    @objc(removeTracks:)
    @NSManaged public func removeFromTracks(_ values: NSSet)

}

// MARK: Generated accessors for waypoints
extension GPXEntity {

    @objc(insertObject:inWaypointsAtIndex:)
    @NSManaged public func insertIntoWaypoints(_ value: Waypoint, at idx: Int)

    @objc(removeObjectFromWaypointsAtIndex:)
    @NSManaged public func removeFromWaypoints(at idx: Int)

    @objc(insertWaypoints:atIndexes:)
    @NSManaged public func insertIntoWaypoints(_ values: [Waypoint], at indexes: NSIndexSet)

    @objc(removeWaypointsAtIndexes:)
    @NSManaged public func removeFromWaypoints(at indexes: NSIndexSet)

    @objc(replaceObjectInWaypointsAtIndex:withObject:)
    @NSManaged public func replaceWaypoints(at idx: Int, with value: Waypoint)

    @objc(replaceWaypointsAtIndexes:withWaypoints:)
    @NSManaged public func replaceWaypoints(at indexes: NSIndexSet, with values: [Waypoint])

    @objc(addWaypointsObject:)
    @NSManaged public func addToWaypoints(_ value: Waypoint)

    @objc(removeWaypointsObject:)
    @NSManaged public func removeFromWaypoints(_ value: Waypoint)

    @objc(addWaypoints:)
    @NSManaged public func addToWaypoints(_ values: NSOrderedSet)

    @objc(removeWaypoints:)
    @NSManaged public func removeFromWaypoints(_ values: NSOrderedSet)

}
