//
//  GPXParseManager.swift
//  getlocation
//
//  Created by Олег Комаристый on 05.01.2020.
//  Copyright © 2020 Darthroid. All rights reserved.
//

import Foundation
import CoreGPX

public class GPXParseManager {
//	public typealias ParseResult = (id: String, name: String, points: [TrackerPoint])
	
	public func parseGPX(fromUrl url: URL) throws -> GPXEntity {
		_ = url.startAccessingSecurityScopedResource()
		guard let gpx = GPXParser(withURL: url)?.parsedData() else {
			throw NSError(domain: "Unable to parse gpx from path: \(url)", code: 1, userInfo: nil)
		}
		let entity = GPXEntity()
		let metadata = gpx.metadata
		
		entity.id = UUID().uuidString
		entity.name = metadata?.name ?? url.deletingPathExtension().lastPathComponent
		entity.author = metadata?.author?.email?.fullAddress ?? metadata?.author?.name
		entity.desc = metadata?.desc
		entity.email = metadata?.author?.email?.fullAddress
		entity.url = metadata?.author?.link?.text
		entity.time = Int64(metadata?.time?.timeIntervalSince1970 ?? Date().timeIntervalSince1970)
		
		entity.waypoints = NSOrderedSet(array: self.parseWaypoints(gpx))
		entity.tracks = NSSet(array: self.parseTracks(gpx))
		
		return entity
	}
	
	private func parseWaypoints(_ gpx: GPXRoot) -> [Waypoint] {
		var waypoints = [Waypoint]()
		gpx.waypoints.forEach {
			let waypoint = Waypoint()
			guard let latitude = $0.latitude, let longitude = $0.longitude else { return }
			
			waypoint.latitude = latitude
			waypoint.longitude = longitude
			waypoint.elevation = Float($0.elevation ?? 0)
			waypoint.comment = $0.comment
			waypoint.name = $0.name
			
			if let time = $0.time {
				waypoint.time = Int64(time.timeIntervalSince1970)
			}
			waypoints.append(waypoint)
		}
		
		return waypoints
	}
	
	private func parseTracks(_ gpx: GPXRoot) -> [Track] {
		var tracks = [Track]()
		gpx.tracks.forEach {
			let track = Track()
			track.name = $0.name
			track.desc = $0.desc
			track.segments = NSOrderedSet(array: self.parseTrackSegments($0.tracksegments))
			
			tracks.append(track)
		}
		
		return tracks
	}
	
	private func parseTrackSegments(_ segments: [GPXTrackSegment]) -> [TrackSegment] {
		var _segments = [TrackSegment]()
		
		segments.forEach {
			let segment = TrackSegment()
			segment.trackpoints = NSOrderedSet(array: self.parseTrackPoints($0.trackpoints))
			
			_segments.append(segment)
		}
		
		return _segments
	}
	
	private func parseTrackPoints(_ trackPoints: [GPXTrackPoint]) -> [TrackPoint] {
		var _trackPoints = [TrackPoint]()
		
		trackPoints.forEach {
			let trackPoint = TrackPoint()
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
	
	// OLD

//	public class func parseGPX(fromUrl url: URL) throws -> ParseResult {
//		_ = url.startAccessingSecurityScopedResource()
//		guard let gpx = GPXParser(withURL: url)?.parsedData() else {
//			throw NSError(domain: "Unable to parse gpx from path: \(url)", code: 1, userInfo: nil)
//		}
//		let trackerName = (url.lastPathComponent as NSString).deletingPathExtension
//
//		url.stopAccessingSecurityScopedResource()
//		return GPXParseManager.parse(trackerName, waypoints: gpx.waypoints)
//	}

	/// Creates gpx formatted string and optionally saves to documents directory
	/// - Parameters:
	///   - tracker: Tracker with points to be processed
	///   - save: Indicates whether tracker needs to be saved to file or not
//	public class func createGPX(fromTracker tracker: Tracker, save: Bool = false, completionHandler: @escaping (String, URL?) -> Void) {
//		DispatchQueue.global(qos: .userInitiated).async {
//			let root = GPXRoot(creator: Bundle.main.displayName)
//			var waypoints: [GPXWaypoint] = []
//
//			tracker.points?.forEach({ point in
//				let waypoint = GPXWaypoint(latitude: point.latitude, longitude: point.longitude)
//				waypoints.append(waypoint)
//			})
//
//			root.add(waypoints: waypoints)
//
//			let gpxString = root.gpx()
//
//			if save {
//				let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
//				do {
//					let date = Date()
//					let dateString = date.stringfromTimeStamp(Int64(date.timeIntervalSince1970))
//
//					let fileName = tracker.name ?? "Tracker_" + dateString
//
//					try root.outputToFile(saveAt: url, fileName: fileName)
//					completionHandler(gpxString, url.appendingPathComponent(fileName).appendingPathExtension("gpx"))
//				} catch {
//					completionHandler(gpxString, nil)
//				}
//			} else {
//				completionHandler(gpxString, nil)
//			}
//		}
//	}
//
//	private class func parse(_ name: String, waypoints: [GPXWaypoint]) -> ParseResult {
//		var trackerPoints: [TrackerPoint] = []
//		let trackerId = UUID().uuidString
//
//		waypoints.forEach({ waypoint in
//			guard let latitude = waypoint.latitude, let longitude = waypoint.longitude else { return }
//			let id = UUID().uuidString	// we need to generate uuid for every waypoint
//
//			let convertedPoint = TrackerPoint()
//			convertedPoint.latitude = latitude
//			convertedPoint.longitude = longitude
//			convertedPoint.id = id
//			convertedPoint.timestamp = Int64(waypoint.time?.timeIntervalSince1970 ?? 0)
//
//			trackerPoints.append(convertedPoint)
//		})
//
//		return (id: trackerId, name: name, points: trackerPoints)
//	}
}
