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

	public var persistentContainer: NSPersistentContainer = {
		let bundle = Bundle(identifier: "com.darthroid.GeoTracker-SwiftUI")

		let modelURL = bundle!.url(forResource: "TrackerDataModel", withExtension: "momd")!
		guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
			fatalError("CoreDataManager: Could not create managedObjectModel")
		}

		let persistentContainer = NSPersistentContainer(
			name: "TrackerDataModel",
			managedObjectModel: managedObjectModel
		)
		
		persistentContainer.loadPersistentStores { _, error in
			if let error = error {
				print("CoreDataManager: could not load store \(error.localizedDescription)")
				return
			}
			print("CoreDataManager: store loaded")
		}
		
		return persistentContainer
	}()

	private var observations = [ObjectIdentifier: Observation]()

	init() {
		
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
	
	public func saveContext(_ context: NSManagedObjectContext) {
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}
	
	public func saveContext() {
		let context = persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}

    // MARK: - Create (Insert)
	
	public func insertGpxEntity(_ context: NSManagedObjectContext , _ entity: GPXEntity) throws {
		context.insert(entity)
		self.event(.insert, ids: [entity.id], gpxEntities: [entity])
		self.saveContext(context)
	}
	
	public func insertGpxEntity(_ context: NSManagedObjectContext, with id: String, author: String? = nil, description: String? = nil, email: String? = nil, name: String? = nil, time: Int64? = nil, url: String? = nil, waypoints: [Waypoint] = [], tracks: [Track] = []) throws {
		let entity = GPXEntity(context: context)
		
		entity.id = id
		entity.author = author
		entity.desc = description
		entity.email = email
		entity.name = name
		entity.time = time ?? Int64(Date().timeIntervalSince1970)
		entity.url = url
		
		waypoints.forEach { entity.addToWaypoints($0) }
		tracks.forEach { entity.addToTracks($0) }
		
		try self.insertGpxEntity(context, entity)
	}
	
	public func insertWayPoints(_ context: NSManagedObjectContext, entityId: String, waypoints: [Waypoint]) throws {
		guard let entity = try self.fetchGPXEntites(context, with: entityId).first else { return }
		
		waypoints.forEach {
			entity.addToWaypoints($0)
		}
		
		context.refresh(entity, mergeChanges: true)
//		self.event(.insert, ids: [tracker.id], trackers: [tracker])
		self.saveContext(context)
	}
	
	public func insertTracks(_ context: NSManagedObjectContext, entityId: String, tracks: [Track]) throws {
		guard let entity = try self.fetchGPXEntites(context, with: entityId).first else { return }
		
		tracks.forEach {
			entity.addToTracks($0)
		}
		
		context.refresh(entity, mergeChanges: true)
//		self.event(.insert, ids: [tracker.id], trackers: [tracker])
		self.saveContext(context)
	}
    // MARK: - Read (Fetch)
	
	public func fetchGPXEntities(_ context: NSManagedObjectContext) throws -> [GPXEntity] {
		let request = GPXEntity.fetchRequest() as NSFetchRequest<GPXEntity>
//		request.returnsObjectsAsFaults = false
		let entities = try context.fetch(request)
		return entities
	}
	
	public func fetchGPXEntites(_ context: NSManagedObjectContext, with id: String) throws -> [GPXEntity] {
		let request = NSFetchRequest<GPXEntity>(entityName: "GPXEntity")
		request.predicate = NSPredicate(format: "id == %@", id)
//		request.returnsObjectsAsFaults = false
		let entities = try context.fetch(request)
		return entities
	}
	
	public func fetchGPXEntities(_ context: NSManagedObjectContext, with name: String) throws -> [GPXEntity] {
		let request = NSFetchRequest<GPXEntity>(entityName: "GPXEntity")
		request.predicate = NSPredicate(format: "name == %@", name)
//		request.returnsObjectsAsFaults = false
		let entities = try context.fetch(request)
		return entities
	}

    // MARK: - Delete
	
	public func deleteGPXEntity(_ context: NSManagedObjectContext, entity: GPXEntity) throws {
		context.delete(entity)
		self.event(.delete, ids: [entity.id], gpxEntities: [entity])
		self.saveContext(context)
	}
	
	public func deleteGPXEntity(_ context: NSManagedObjectContext, withId id: String) throws {
		let fetchRequest = GPXEntity.fetchRequest() as NSFetchRequest<NSFetchRequestResult>
		fetchRequest.predicate = NSPredicate(format: "id == %@", id)

		let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
		
		try context.execute(deleteRequest)
		self.event(.delete, ids: [id], gpxEntities: [])
		self.saveContext(context)
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
