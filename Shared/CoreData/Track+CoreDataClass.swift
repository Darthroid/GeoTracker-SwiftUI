//
//  Track+CoreDataClass.swift
//  
//
//  Created by Oleg Komaristy on 17.07.2020.
//
//

import Foundation
import CoreData

@objc(Track)
public class Track: NSManagedObject {
	convenience public init() {
		let context = CoreDataManager.shared.context
		let entityName = String(describing: Track.self)
		guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
			fatalError("Could not create entity of Track")
		}

		self.init(entity: entity, insertInto: context)
	}
}
