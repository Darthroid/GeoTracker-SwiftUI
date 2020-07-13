//
//  TrackerListViewModel.swift
//  Geotracker-SwiftUI
//
//  Created by Oleg Komaristy on 17.06.2020.
//  Copyright © 2020 Oleg Komaristy. All rights reserved.
//

import Foundation
import Combine
//import GeoTrackerCore

class TrackerListViewModel: ObservableObject {
	@Published private(set) var trackers = [TrackerViewModel]()

	public init() {
		self.subscribeForDbEvents()
		self.fetchTrackers()
	}

	public func subscribeForDbEvents() {
		CoreDataManager.shared.addObserver(self)
	}

	public func fetchTrackers() {
		print(#function)
		do {
			let trackers = try CoreDataManager.shared.fetchTrackers()
			let trackerViewModels = trackers.map({ TrackerViewModel(from: $0) })
			self.trackers = trackerViewModels
		} catch {
			assert(false, error.localizedDescription)
		}
	}

	public func deleteTracker(_ tracker: TrackerViewModel) throws {
		do {
			try CoreDataManager.shared.deleteTrackers(withId: tracker.id)
		} catch {
			throw error
		}
	}
	
	public func delete(at offset: IndexSet) throws {
		guard !self.trackers.isEmpty else { return }
				
		let indexes = Array(offset)
		
		try indexes.forEach { i in
			do {
				try self.deleteTracker(self.trackers[i])
			} catch {
				throw error
			}
		}
	}

	public func parseGpxFrom(_ url: URL) throws {
		do {
			let parseResult = try GPXParseManager.parseGPX(fromUrl: url)
			try CoreDataManager.shared.insertTracker(withId: parseResult.id,
													 name: parseResult.name,
													 points: parseResult.points)
		} catch {
			throw(error)
		}
	}
}

// MARK: - CoreDataObserver methods

extension TrackerListViewModel: CoreDataObserver {
	func didInsert(ids: [String], trackers: [Tracker]) {
		trackers.forEach({ tracker in
			self.trackers.append(TrackerViewModel(from: tracker))
		})
	}

	func didUpdate(ids: [String], trackers: [Tracker]?) {
		//
	}

	func didDelete(ids: [String], trackers: [Tracker]?) {
		if let trackers = trackers {
			trackers.forEach({ tracker in
				self.trackers.removeAll(where: { $0.id == tracker.id })
			})
		} else {
			ids.forEach({ id in
				self.trackers.removeAll(where: { $0.id == id })
			})
		}
	}
}
