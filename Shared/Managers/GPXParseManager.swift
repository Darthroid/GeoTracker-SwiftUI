//
//  GPXParseManager.swift
//  getlocation
//
//  Created by Олег Комаристый on 05.01.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation
import CoreGPX
import CoreData

public class GPXParseManager {
	
	/// Creates GPXEntity from contents of file.
	/// - Parameter url: A URL where  GPX file located at.
	/// - Returns: GPXEntity created from file.
	public func parseGPX(fromUrl url: URL, context: NSManagedObjectContext) throws -> GPXEntity {
		_ = url.startAccessingSecurityScopedResource()
		guard let gpx = GPXParser(withURL: url)?.parsedData() else {
			throw NSError(domain: "Unable to parse gpx from path: \(url)", code: 1, userInfo: nil)
		}
		let entity = GPXEntity(context: context)
		let metadata = gpx.metadata
		
		entity.id = UUID().uuidString
		entity.name = metadata?.name ?? url.deletingPathExtension().lastPathComponent
		entity.author = metadata?.author?.email?.fullAddress ?? metadata?.author?.name
		entity.desc = metadata?.desc
		entity.email = metadata?.author?.email?.fullAddress
		entity.url = metadata?.author?.link?.text
		entity.time = Int64(metadata?.time?.timeIntervalSince1970 ?? Date().timeIntervalSince1970)
		
		entity.waypoints = NSOrderedSet(array: self.parseWaypoints(gpx, context: context))
		entity.tracks = NSSet(array: self.parseTracks(gpx, context: context))
		
		return entity
	}
	
	/// Creates GPX formatted string from GPXEntity and optionally saves to documents directory.
	/// - Parameters:
	///   - entity: GPX entity to parse.
	///   - save: Indicates whether result needs to be saved to file or not.
	public func createGPX(fromEntity entity: GPXEntity, save: Bool = false, completionHandler: @escaping (String, URL?) -> Void) {
		DispatchQueue.global(qos: .userInitiated).async {
			let root = GPXRoot(creator: Bundle.main.displayName)

			let waypoints = self.waypoints(for: entity)
			let tracks = self.tracks(for: entity)

			if !waypoints.isEmpty {
				root.add(waypoints: waypoints)
			}
			if !tracks.isEmpty {
				root.add(tracks: tracks)
			}
			
			root.metadata = self.metaData(for: entity)

			let gpxString = root.gpx()

			if save {
				let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
				do {
					let date = Date()
					let dateString = date.stringfromTimeStamp(Int64(date.timeIntervalSince1970))

					let fileName = entity.name ?? "GPX_" + dateString

					try root.outputToFile(saveAt: url, fileName: fileName)
					completionHandler(gpxString, url.appendingPathComponent(fileName).appendingPathExtension("gpx"))
				} catch {
					completionHandler(gpxString, nil)
				}
			} else {
				completionHandler(gpxString, nil)
			}
		}
	}
	
	// MARK: - Private methods for parsing from gpx to GPXEntity
	
	private func parseWaypoints(_ gpx: GPXRoot, context: NSManagedObjectContext) -> [Waypoint] {
		var waypoints = [Waypoint]()
		gpx.waypoints.forEach {
			let waypoint = Waypoint(context: context)
			guard let latitude = $0.latitude, let longitude = $0.longitude else { return }
			
			waypoint.latitude = latitude
			waypoint.longitude = longitude
			waypoint.elevation = Float($0.elevation ?? 0)
			waypoint.comment = $0.comment
			waypoint.desc = $0.desc
			waypoint.name = $0.name
			
			if let time = $0.time {
				waypoint.time = Int64(time.timeIntervalSince1970)
			}
			waypoints.append(waypoint)
		}
		
		return waypoints
	}
	
	private func parseTracks(_ gpx: GPXRoot, context: NSManagedObjectContext) -> [Track] {
		var tracks = [Track]()
		gpx.tracks.forEach {
			let track = Track(context: context)
			track.name = $0.name
			track.desc = $0.desc
			track.segments = NSOrderedSet(array: self.parseTrackSegments($0.tracksegments, context: context))
			
			tracks.append(track)
		}
		
		return tracks
	}
	
	private func parseTrackSegments(_ segments: [GPXTrackSegment], context: NSManagedObjectContext) -> [TrackSegment] {
		var _segments = [TrackSegment]()
		
		segments.forEach {
			let segment = TrackSegment(context: context)
			segment.trackpoints = NSOrderedSet(array: self.parseTrackPoints($0.trackpoints, context: context))
			
			_segments.append(segment)
		}
		
		return _segments
	}
	
	private func parseTrackPoints(_ trackPoints: [GPXTrackPoint], context: NSManagedObjectContext) -> [TrackPoint] {
		var _trackPoints = [TrackPoint]()
		
		trackPoints.forEach {
			let trackPoint = TrackPoint(context: context)
			guard let latitude = $0.latitude, let longitude = $0.longitude else { return }
			trackPoint.latitude = latitude
			trackPoint.longitude = longitude
			
			if let elevation = $0.elevation {
				trackPoint.elevation = Float(elevation)
			}
			
			_trackPoints.append(trackPoint)
		}
		
		return _trackPoints
	}
	
	// MARK: - Private methods for parsing from GPXEntity to gpx
	
	private func waypoints(for entity: GPXEntity) -> [GPXWaypoint] {
		guard let _waypoints = entity.waypoints?.compactMap({ $0 as? Waypoint }) else {
			return []
		}
		
		var waypoints = [GPXWaypoint]()
		
		_waypoints.forEach {
			let waypoint = GPXWaypoint(latitude: $0.latitude, longitude: $0.longitude)
			waypoint.name = $0.name
			waypoint.comment = $0.comment
			waypoint.desc = $0.desc
			waypoint.elevation = Double($0.elevation)
			waypoint.time = Date(timeIntervalSince1970: TimeInterval($0.time))
			
			waypoints.append(waypoint)
		}
		
		return waypoints
	}
	
	private func tracks(for entity: GPXEntity) -> [GPXTrack] {
		guard let _tracks = entity.tracks?.compactMap({ $0 as? Track }) else {
			return []
		}
		
		var tracks = [GPXTrack]()
		
		_tracks.forEach {
			let track = GPXTrack()
			track.name = $0.name
			track.desc = $0.desc
			track.add(trackSegments: self.segments(for: $0.segments))
			
			tracks.append(track)
		}
		
		return tracks
	}
	
	private func segments(for segments: NSOrderedSet?) -> [GPXTrackSegment] {
		guard let _segments = segments.flatMap({ $0.compactMap({ $0 as? TrackSegment }) }) else {
			return []
		}

		var trackSegments = [GPXTrackSegment]()
		
		_segments.forEach {
			let segment = GPXTrackSegment()
			segment.add(trackpoints: self.trackPoints(for: $0))
			
			trackSegments.append(segment)
		}
		
		return trackSegments
	}
	
	private func trackPoints(for segment: TrackSegment) -> [GPXTrackPoint] {
		guard let _trackPoints = segment.trackpoints.flatMap({ $0.compactMap({ $0 as? TrackPoint }) }) else {
			return []
		}
		
		var trackPoints = [GPXTrackPoint]()
		
		_trackPoints.forEach {
			let trackPoint = GPXTrackPoint()
			trackPoint.latitude = $0.latitude
			trackPoint.longitude = $0.longitude
			trackPoint.elevation = Double($0.elevation)
			
			trackPoints.append(trackPoint)
			
		}
		
		return trackPoints
	}
	
	private func metaData(for entity: GPXEntity) -> GPXMetadata {
		let metadata = GPXMetadata()
		metadata.name = entity.name
		metadata.desc = entity.desc
		metadata.time = Date(timeIntervalSince1970: TimeInterval(entity.time))
		
		let author = GPXAuthor()
		author.email?.fullAddress = entity.email
		author.link?.text = entity.url
		metadata.author = author
		
		return metadata
	}
}
