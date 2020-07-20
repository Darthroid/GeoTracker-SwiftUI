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
	func didInsert(ids: [String], trackers: [Tracker])
	func didUpdate(ids: [String], trackers: [Tracker]?)
	func didDelete(ids: [String], trackers: [Tracker]?)
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
		
		self.context.insert(entity)
//		self.event(.insert, ids: [tracker.id], trackers: [tracker])
		try self.saveContext()
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

    public func insertTracker(withId id: String, name: String, points: [TrackerPoint] = []) throws {
        let tracker = Tracker(context: self.context)
        tracker.id = id
        tracker.name = name

        points.forEach({ tracker.addToPoints($0)})

        self.context.insert(tracker)
		self.event(.insert, ids: [tracker.id], trackers: [tracker])
		try self.saveContext()
    }

    // MARK: - Read (Fetch)
	
	public func fetchGPXEntities() throws -> [GPXEntity] {
		let request = GPXEntity.fetchRequest() as NSFetchRequest<GPXEntity>
		let entities = try self.context.fetch(request)
		return entities
	}
	
	public func fetchGPXEntites(with id: String) throws -> [GPXEntity] {
		let request = NSFetchRequest<GPXEntity>(entityName: "GPXEntity")
		request.predicate = NSPredicate(format: "id == %@", id)
		
		let entities = try self.context.fetch(request)
		return entities
	}
	
	public func fetchGPXEntities(with name: String) throws -> [GPXEntity] {
		let request = NSFetchRequest<GPXEntity>(entityName: "GPXEntity")
		request.predicate = NSPredicate(format: "name == %@", name)
		
		let entities = try self.context.fetch(request)
		return entities
	}

   public func fetchTrackers() throws -> [Tracker] {
        let request = Tracker.fetchRequest() as NSFetchRequest<Tracker>
        let trackers = try self.context.fetch(request)
        return trackers
    }

    public func fetchTrackers(withId id: String) throws -> [Tracker] {
        let request = NSFetchRequest<Tracker>(entityName: "Tracker")
        request.predicate = NSPredicate(format: "id == %@", id)

        let trackers = try self.context.fetch(request)
        return trackers
    }

    public func fetchTrackers(withName name: String) throws -> [Tracker] {
        let request = NSFetchRequest<Tracker>(entityName: "Tracker")
        request.predicate = NSPredicate(format: "name == %@", name)

        let trackers = try self.context.fetch(request)
        return trackers
    }

    // MARK: - Update
	
    public func update(tracker: Tracker, points: [TrackerPoint]) throws {
        points.forEach({ tracker.addToPoints($0) })
		self.event(.update, ids: [tracker.id], trackers: [tracker])
        if self.context.hasChanges {
            try self.context.save()
        }
    }

    // MARK: - Delete
	
	public func deleteGPXEntity(entity: GPXEntity) throws {
		self.context.delete(entity)
//		self.event(.delete, ids: [tracker.id], trackers: [tracker])
		try self.saveContext()
	}
	
	public func deleteGPXEntity(withId id: String) throws {
		let fetchRequest = GPXEntity.fetchRequest() as NSFetchRequest<NSFetchRequestResult>
		fetchRequest.predicate = NSPredicate(format: "id == %@", id)

		let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
		
		try self.context.execute(deleteRequest)
//		self.event(.delete, ids: [id], trackers: nil)
		try self.saveContext()
	}

    public func delete(tracker: Tracker) throws {
        self.context.delete(tracker)
		self.event(.delete, ids: [tracker.id], trackers: [tracker])
        if self.context.hasChanges {
            try self.context.save()
        }
    }

    public func deleteTrackers(withId id: String) throws {
        let fetchRequest = Tracker.fetchRequest() as NSFetchRequest<NSFetchRequestResult>
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)

        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try self.context.execute(deleteRequest)
		self.event(.delete, ids: [id], trackers: nil)
        if self.context.hasChanges {
            try self.context.save()
        }
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

	func event(_ event: Event, ids: [String], trackers: [Tracker]?) {
		for (id, observation) in observations {
			// If the observer is no longer in memory, we
			// can clean up the observation for its ID
			guard let observer = observation.observer else {
				observations.removeValue(forKey: id)
				continue
			}

			switch event {
			case .insert:
				observer.didInsert(ids: ids, trackers: trackers ?? [])
			case .update:
				observer.didUpdate(ids: ids, trackers: trackers)
			case .delete:
				observer.didDelete(ids: ids, trackers: trackers)
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
