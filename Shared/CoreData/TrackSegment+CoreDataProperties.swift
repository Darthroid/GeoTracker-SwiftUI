//
//  TrackSegment+CoreDataProperties.swift
//  
//
//  Created by Oleg Komaristy on 17.07.2020.
//
//

import Foundation
import CoreData


extension TrackSegment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackSegment> {
        return NSFetchRequest<TrackSegment>(entityName: "TrackSegment")
    }

    @NSManaged public var track: Track?
    @NSManaged public var trackpoints: NSOrderedSet?

}

// MARK: Generated accessors for trackpoints
extension TrackSegment {

    @objc(insertObject:inTrackpointsAtIndex:)
    @NSManaged public func insertIntoTrackpoints(_ value: TrackPoint, at idx: Int)

    @objc(removeObjectFromTrackpointsAtIndex:)
    @NSManaged public func removeFromTrackpoints(at idx: Int)

    @objc(insertTrackpoints:atIndexes:)
    @NSManaged public func insertIntoTrackpoints(_ values: [TrackPoint], at indexes: NSIndexSet)

    @objc(removeTrackpointsAtIndexes:)
    @NSManaged public func removeFromTrackpoints(at indexes: NSIndexSet)

    @objc(replaceObjectInTrackpointsAtIndex:withObject:)
    @NSManaged public func replaceTrackpoints(at idx: Int, with value: TrackPoint)

    @objc(replaceTrackpointsAtIndexes:withTrackpoints:)
    @NSManaged public func replaceTrackpoints(at indexes: NSIndexSet, with values: [TrackPoint])

    @objc(addTrackpointsObject:)
    @NSManaged public func addToTrackpoints(_ value: TrackPoint)

    @objc(removeTrackpointsObject:)
    @NSManaged public func removeFromTrackpoints(_ value: TrackPoint)

    @objc(addTrackpoints:)
    @NSManaged public func addToTrackpoints(_ values: NSOrderedSet)

    @objc(removeTrackpoints:)
    @NSManaged public func removeFromTrackpoints(_ values: NSOrderedSet)

}
