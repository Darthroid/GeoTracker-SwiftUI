//
//  TrackerViewModel.swift
//  Geotracker-SwiftUI
//
//  Created by Oleg Komaristy on 17.06.2020.
//  Copyright © 2020 Oleg Komaristy. All rights reserved.
//

import Foundation
//import GeoTrackerCore

class TrackerViewModel: Identifiable {
	private var tracker: Tracker

	var points: [PointViewModel] {
		let points = Array(tracker.points ?? Set())
		return points.map({ PointViewModel(from: $0) })
	}

	public var name: String {
		return tracker.name ?? ""
	}

	public var description: String {
		"\(String(describing: tracker.points?.count ?? 0)) points"
	}

	public var id: String {
		return tracker.id
	}
	
	public var gpxString = ""
	public var fileUrl: URL?

	public init(from tracker: Tracker) {
		self.tracker = tracker
	}
}

extension TrackerViewModel {
	public func exportAsGPX(completion: @escaping (() -> Void)) {
		self.exportAsGPX(completionHandler: { gpxString, fileUrl in
			self.gpxString = gpxString
			self.fileUrl = fileUrl
			completion()
		})
	}
	
	private func exportAsGPX(save: Bool = true, completionHandler: @escaping (String, URL?) -> Void) {
		GPXParseManager.createGPX(fromTracker: self.tracker, save: save, completionHandler: { gpxString, fileUrl in
			DispatchQueue.main.async {
				completionHandler(gpxString, fileUrl)
			}
		})
	}
}

extension TrackerViewModel: Comparable {
	static func < (lhs: TrackerViewModel, rhs: TrackerViewModel) -> Bool {
		fatalError("not implemented")
	}

	static func == (lhs: TrackerViewModel, rhs: TrackerViewModel) -> Bool {
		return lhs.id == rhs.id
	}
}

extension TrackerViewModel: Hashable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
		hasher.combine(self.name)
		hasher.combine(self.points)
	}
}
