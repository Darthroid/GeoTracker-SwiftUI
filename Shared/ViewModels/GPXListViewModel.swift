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

class GPXListViewModel: ObservableObject {
	@Published private(set) var gpxModels = [GPXViewModel]()

	public init() {
		self.subscribeForDbEvents()
		self.fetchEntities()
	}

	public func subscribeForDbEvents() {
		CoreDataManager.shared.addObserver(self)
	}
	
	public func fetchEntities() {
		do {
			let entities = try CoreDataManager.shared.fetchGPXEntities()
			self.gpxModels = entities.map { GPXViewModel(from: $0) }
		} catch {
			assert(false, error.localizedDescription)
		}
	}
	
	public func deleteEntity(_ entity: GPXEntity) throws {
		try CoreDataManager.shared.deleteGPXEntity(entity: entity)
	}

	
	public func delete(atOffset offset: IndexSet) throws {
		guard !self.gpxModels.isEmpty else { return }
		let indexes = Array(offset)
		
		try indexes.forEach {
			try self.deleteEntity(self.gpxModels[$0].gpxEntity)
		}
	}
	
	public func parseGPXFrom(_ url: URL) throws {
		do {
			let entity = try GPXParseManager().parseGPX(fromUrl: url)
			try CoreDataManager.shared.insertGpxEntity(entity)
		}
	}
}

// MARK: - CoreDataObserver methods

extension GPXListViewModel: CoreDataObserver {
	func didInsert(ids: [String], gpxEntities entities: [GPXEntity]) {
		entities.forEach({ entity in
			self.gpxModels.append(GPXViewModel(from: entity))
		})
	}

	func didUpdate(ids: [String], gpxEntities entities: [GPXEntity]) {
		//
	}

	func didDelete(ids: [String], gpxEntities entities: [GPXEntity]) {
		if !entities.isEmpty {
			entities.forEach({ entity in
				self.gpxModels.removeAll(where: { $0.id == entity.id })
			})
		} else {
			ids.forEach({ id in
				self.gpxModels.removeAll(where: { $0.id == id })
			})
		}
	}
}
