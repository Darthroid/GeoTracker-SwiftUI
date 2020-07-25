//
//  CoreDataManager.swift
//  getlocation
//
//  Created by Oleg Komaristy on 09.09.2019.
//  Copyright © 2019 Darthroid. All rights reserved.
//

import Foundation
import CoreData

public protocol CoreDataObserver: class {
	func didInsert(ids: [String], gpxEntities: [GPXEntity])
	func didUpdate(ids: [String], gpxEntities: [GPXEntity])
	func didDelete(ids: [String], gpxEntities: [GPXEntity])
	
}

public class CoreDataManager {
    public static var shared = CoreDataManager()

	private let persistentContainer: NSPersistentContainer!

	private var observations = [ObjectIdentifier: Observation]()

    public var context: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }

	init() {
		let bundle = Bundle(identifier: "com.darthroid.GeoTracker-SwiftUI")

		let modelURL = bundle!.url(forResource: "TrackerDataModel", withExtension: "momd")!
		guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
			fatalError("Could not create managedObjectModel")
		}

		self.persistentContainer = NSPersistentContainer(name: "TrackerDataModel",
														 managedObjectModel: managedObjectModel)
	}

    public func initalizeStack(completion: @escaping () -> Void) {
        self.persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                print("could not load store \(error.localizedDescription)")
                return
            }
            print(self, #function, "store loaded")
        }
    }

    func setStore(type: String) {
        let description = NSPersistentStoreDescription()
        description.type = type // types: NSInMemoryStoreType, NSSQLiteStoreType, NSBinaryStoreType

        if type == NSSQLiteStoreType || type == NSBinaryStoreType {
            description.url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                .first?.appendingPathComponent("database")
        }

        self.persistentContainer.persistentStoreDescriptions = [description]
    }
	
	private func saveContext() throws {
		if self.context.hasChanges {
			try self.context.save()
		}
	}

    // MARK: - Create (Insert)
	
	public func insertGpxEntity(_ entity: GPXEntity) throws {
		self.context.insert(entity)
		self.event(.insert, ids: [entity.id ?? ""], gpxEntities: [entity])
		try self.saveContext()
	}
	
	public func insertGpxEntity(with id: String, author: String? = nil, description: String? = nil, email: String? = nil, name: String? = nil, time: Int64? = nil, url: String? = nil, waypoints: [Waypoint] = [], tracks: [Track] = []) throws {
		let entity = GPXEntity(context: self.context)
		
		entity.id = id
		entity.author = author
		entity.desc = description
		entity.email = email
		entity.name = name
		entity.time = time ?? Int64(Date().timeIntervalSince1970)
		entity.url = url
		
		waypoints.forEach { entity.addToWaypoints($0) }
		tracks.forEach { entity.addToTracks($0) }
		
		try self.insertGpxEntity(entity)
	}
	
	public func insertWayPoints(entityId: String, waypoints: [Waypoint]) throws {
		guard let entity = try self.fetchGPXEntites(with: entityId).first else { return }
		
		waypoints.forEach {
			entity.addToWaypoints($0)
		}
		
		self.context.refresh(entity, mergeChanges: true)
//		self.event(.insert, ids: [tracker.id], trackers: [tracker])
		try self.saveContext()
	}
	
	public func insertTracks(entityId: String, tracks: [Track]) throws {
		guard let entity = try self.fetchGPXEntites(with: entityId).first else { return }
		
		tracks.forEach {
			entity.addToTracks($0)
		}
		
		self.context.refresh(entity, mergeChanges: true)
//		self.event(.insert, ids: [tracker.id], trackers: [tracker])
		try self.saveContext()
	}
    // MARK: - Read (Fetch)
	
	public func fetchGPXEntities() throws -> [GPXEntity] {
		let request = GPXEntity.fetchRequest() as NSFetchRequest<GPXEntity>
//		request.returnsObjectsAsFaults = false
		let entities = try self.context.fetch(request)
		return entities
	}
	
	public func fetchGPXEntites(with id: String) throws -> [GPXEntity] {
		let request = NSFetchRequest<GPXEntity>(entityName: "GPXEntity")
		request.predicate = NSPredicate(format: "id == %@", id)
//		request.returnsObjectsAsFaults = false
		let entities = try self.context.fetch(request)
		return entities
	}
	
	public func fetchGPXEntities(with name: String) throws -> [GPXEntity] {
		let request = NSFetchRequest<GPXEntity>(entityName: "GPXEntity")
		request.predicate = NSPredicate(format: "name == %@", name)
//		request.returnsObjectsAsFaults = false
		let entities = try self.context.fetch(request)
		return entities
	}

    // MARK: - Delete
	
	public func deleteGPXEntity(entity: GPXEntity) throws {
		self.context.delete(entity)
		self.event(.delete, ids: [entity.id], gpxEntities: [entity])
		try self.saveContext()
	}
	
	public func deleteGPXEntity(withId id: String) throws {
		let fetchRequest = GPXEntity.fetchRequest() as NSFetchRequest<NSFetchRequestResult>
		fetchRequest.predicate = NSPredicate(format: "id == %@", id)

		let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
		
		try self.context.execute(deleteRequest)
		self.event(.delete, ids: [id], gpxEntities: [])
		try self.saveContext()
	}
}

// TODO: - replace observation method with CoreData default tools
private extension CoreDataManager {
	struct Observation {
		weak var observer: CoreDataObserver?
	}

	enum Event {
		case insert
		case delete
		case update
	}

	func event(_ event: Event, ids: [String], gpxEntities: [GPXEntity]) {
		for (id, observation) in observations {
			// If the observer is no longer in memory, we
			// can clean up the observation for its ID
			guard let observer = observation.observer else {
				observations.removeValue(forKey: id)
				continue
			}

			switch event {
			case .insert:
				observer.didInsert(ids: ids, gpxEntities: gpxEntities)
			case .update:
				observer.didUpdate(ids: ids, gpxEntities: gpxEntities)
			case .delete:
				observer.didDelete(ids: ids, gpxEntities: gpxEntities)
			}
		}
	}
}

public extension CoreDataManager {
	func addObserver(_ observer: CoreDataObserver) {
        let id = ObjectIdentifier(observer)
        observations[id] = Observation(observer: observer)
    }

	func removeObserver(_ observer: CoreDataObserver) {
        let id = ObjectIdentifier(observer)
        observations.removeValue(forKey: id)
    }
}
