//
//  Track+CoreDataProperties.swift
//  
//
//  Created by Oleg Komaristy on 17.07.2020.
//
//

import Foundation
import CoreData


extension Track {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Track> {
        return NSFetchRequest<Track>(entityName: "Track")
    }

    @NSManaged public var desc: String?
    @NSManaged public var name: String?
    @NSManaged public var time: Int64
    @NSManaged public var url: String?
    @NSManaged public var gpxEntity: GPXEntity?
    @NSManaged public var segments: NSOrderedSet?

}

// MARK: Generated accessors for segments
extension Track {

    @objc(insertObject:inSegmentsAtIndex:)
    @NSManaged public func insertIntoSegments(_ value: TrackSegment, at idx: Int)

    @objc(removeObjectFromSegmentsAtIndex:)
    @NSManaged public func removeFromSegments(at idx: Int)

    @objc(insertSegments:atIndexes:)
    @NSManaged public func insertIntoSegments(_ values: [TrackSegment], at indexes: NSIndexSet)

    @objc(removeSegmentsAtIndexes:)
    @NSManaged public func removeFromSegments(at indexes: NSIndexSet)

    @objc(replaceObjectInSegmentsAtIndex:withObject:)
    @NSManaged public func replaceSegments(at idx: Int, with value: TrackSegment)

    @objc(replaceSegmentsAtIndexes:withSegments:)
    @NSManaged public func replaceSegments(at indexes: NSIndexSet, with values: [TrackSegment])

    @objc(addSegmentsObject:)
    @NSManaged public func addToSegments(_ value: TrackSegment)

    @objc(removeSegmentsObject:)
    @NSManaged public func removeFromSegments(_ value: TrackSegment)

    @objc(addSegments:)
    @NSManaged public func addToSegments(_ values: NSOrderedSet)

    @objc(removeSegments:)
    @NSManaged public func removeFromSegments(_ values: NSOrderedSet)

}
