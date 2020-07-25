//
//  TrackerViewModel.swift
//  Geotracker-SwiftUI
//
//  Created by Oleg Komaristy on 17.06.2020.
//  Copyright © 2020 Oleg Komaristy. All rights reserved.
//

import Foundation

class GPXViewModel: Identifiable {
	private(set) var gpxEntity: GPXEntity
	
	var waypoints: [Waypoint] {
		let waypoints = gpxEntity.waypoints?.compactMap({ $0 as? Waypoint }) ?? []
		return waypoints
	}
	
	var tracks: [Track] {
		let tracks = gpxEntity.tracks?.compactMap({ $0 as? Track }) ?? []
		return tracks
	}
	
	var allSegments: [TrackSegment] {
		let _segments = self.tracks.compactMap({ $0.segments })
		let segments = _segments.flatMap({ $0.compactMap({ $0 as? TrackSegment }) })
		return segments
	}
	
	var allTrackPoints: [TrackPoint] {
		let _trackPoints = self.allSegments.compactMap({ $0.trackpoints })
		let trackPoints = _trackPoints.flatMap({ $0.compactMap({ $0 as? TrackPoint }) })
		return trackPoints
	}

	public var name: String {
		return gpxEntity.name ?? ""
	}

	public var description: String {
		return """
		\(String(describing: waypoints.count)) waypoints
		\(String(describing: tracks.count)) tracks
		\(String(describing: allSegments.count)) segments
		"""
	}

	public var id: String {
		return gpxEntity.id
	}

	public var gpxString = ""
	public var fileUrl: URL?

	public init(from gpxEntity: GPXEntity) {
		self.gpxEntity = gpxEntity
	}
}

extension GPXViewModel {
	public func exportAsGPX(completion: @escaping (() -> Void)) {
		self.exportAsGPX(completionHandler: { gpxString, fileUrl in
			self.gpxString = gpxString
			self.fileUrl = fileUrl
			completion()
		})
	}
	
	private func exportAsGPX(save: Bool = true, completionHandler: @escaping (String, URL?) -> Void) {
//		GPXParseManager.createGPX(fromTracker: self.gpxEntity, save: save, completionHandler: { gpxString, fileUrl in
//			DispatchQueue.main.async {
//				completionHandler(gpxString, fileUrl)
//			}
//		})
	}
}

extension GPXViewModel: Comparable {
	static func < (lhs: GPXViewModel, rhs: GPXViewModel) -> Bool {
		return lhs.gpxEntity.time < rhs.gpxEntity.time
	}

	static func == (lhs: GPXViewModel, rhs: GPXViewModel) -> Bool {
		return lhs.id == rhs.id
	}
}

extension GPXViewModel: Hashable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
		hasher.combine(self.name)
		hasher.combine(self.tracks)
		hasher.combine(self.allSegments)
//		hasher.combine(self.points)
	}
}
